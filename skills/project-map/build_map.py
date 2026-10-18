"""Turn a Graphify graph (graphify-out/graph.json) into the interactive Project Map page.

Usage (from the project root):
    python <skill-dir>/build_map.py [graphify-out/graph.json] [-o graphify-out/project-map.html] [--name "My Project"]

Standard library only. Groups Graphify's code entities by the file they live in,
then draws one node per file and one link per pair of files that reference each other.
"""
import argparse
import collections
import datetime
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))

# Graphify relation -> map link kind (imports, calls, types, tests, docs)
KIND_OF = {
    "imports": "imports", "imports_from": "imports", "re_exports": "imports", "includes": "imports",
    "calls": "calls", "indirect_call": "calls", "method": "calls",
    "uses": "types", "inherits": "types", "implements": "types", "references": "types", "defines": "types",
    "cites": "docs", "rationale_for": "docs", "documents": "docs", "mentions": "docs",
}
VERB = {"imports": "imports", "calls": "calls", "types": "uses", "tests": "tests", "docs": "references"}
SKIP_RELATIONS = {"contains"}  # file -> its own symbols; not a link between files

ROLE_RULES = [
    (r"(^|/)(tests?|__tests__|spec)(/|$)|[._-](test|spec)\.", "Test suite"),
    (r"\.(md|mdx|rst|txt)$", "Documentation"),
    (r"(^|/)(package\.json|tsconfig.*\.json|pyproject\.toml|setup\.(py|cfg)|.*\.config\.[jt]s|.*\.ya?ml|.*\.toml|Cargo\.toml|go\.mod)$", "Config"),
    (r"\.(css|scss|sass|less)$", "Styles"),
    (r"(^|/)(main|index|app|__main__)\.[a-z]+$", "Entry point"),
    (r"(^|/)(server|api|routes?)(/|$)", "Server"),
    (r"(^|/)(components?|ui|views?|pages?)(/|$)|\.(tsx|jsx|vue|svelte)$", "Interface"),
    (r"(^|/)(models?|schema|types?)(/|$)|(types|schema|models?)\.[a-z]+$", "Data model"),
]


def role_for(path):
    for rx, role in ROLE_RULES:
        if re.search(rx, path, re.I):
            return role
    return "Source"


def common_root(paths):
    parts = [p.split("/")[:-1] for p in paths if p]
    if not parts:
        return ""
    root = parts[0]
    for p in parts[1:]:
        i = 0
        while i < len(root) and i < len(p) and root[i] == p[i]:
            i += 1
        root = root[:i]
    return "/".join(root)


def count_lines(path):
    try:
        with open(path, "rb") as f:
            return sum(1 for _ in f)
    except OSError:
        return 0


def git_commit(cwd):
    try:
        return subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=cwd, capture_output=True,
                              text=True, timeout=5).stdout.strip()
    except Exception:
        return ""


def build(graph, name, base_dir):
    nodes = graph.get("nodes", [])
    edges = graph.get("links") or graph.get("edges") or []
    labels = graph.get("graph", {}).get("community_labels") or {}

    file_of = {}
    for n in nodes:
        sf = (n.get("source_file") or "").replace("\\", "/")
        if sf:
            file_of[n["id"]] = sf
    root = common_root(list(set(file_of.values())))
    rel = lambda p: p[len(root) + 1:] if root and p.startswith(root + "/") else p

    files = collections.OrderedDict()
    for n in nodes:
        sf = file_of.get(n["id"])
        if not sf:
            continue
        rp = rel(sf)
        f = files.setdefault(rp, {"id": rp, "abs": sf, "symbols": [], "communities": collections.Counter()})
        label = str(n.get("label") or n["id"])
        if label != os.path.basename(rp) and not n.get("type") == "module":
            f["symbols"].append(label + ("()" if n.get("kind") in ("function", "method") else ""))
        if n.get("community") is not None:
            f["communities"][n["community"]] += 1

    pair = collections.defaultdict(lambda: {"kinds": collections.Counter(), "why": collections.defaultdict(list)})
    for e in edges:
        rel_name = (e.get("relation") or "").lower()
        if rel_name in SKIP_RELATIONS:
            continue
        s = e.get("_src", e.get("source"))
        t = e.get("_tgt", e.get("target"))
        fs, ft = file_of.get(s), file_of.get(t)
        if not fs or not ft or fs == ft:
            continue
        fs, ft = rel(fs), rel(ft)
        kind = KIND_OF.get(rel_name, "types")
        if role_for(fs) == "Test suite":
            kind = "tests"
        elif role_for(fs) == "Documentation":
            kind = "docs"
        p = pair[(fs, ft)]
        p["kinds"][kind] += 1
        tgt = next((n for n in nodes if n["id"] == t), None)
        if tgt is not None:
            lbl = str(tgt.get("label") or t)
            if lbl not in p["why"][kind] and len(p["why"][kind]) < 5:
                p["why"][kind].append(lbl)

    links = []
    nbr_out, nbr_in = collections.defaultdict(set), collections.defaultdict(set)
    for (s, t), p in pair.items():
        primary = p["kinds"].most_common(1)[0][0]
        why = [f"{VERB[k]} {', '.join(v)}" for k, v in p["why"].items() if v]
        links.append({"s": s, "t": t, "kinds": dict(p["kinds"]), "primary": primary,
                      "w": sum(p["kinds"].values()), "why": why[:3]})
        nbr_out[s].add(t)
        nbr_in[t].add(s)

    out_files = []
    group_count = collections.Counter()
    for rp, f in files.items():
        group = rp.split("/")[0] if "/" in rp else "root"
        group_count[group] += 1
        comm = f["communities"].most_common(1)[0][0] if f["communities"] else None
        cluster = labels.get(str(comm), labels.get(comm, f"Community {comm}")) if comm is not None else ""
        abs_path = f["abs"] if os.path.isabs(f["abs"]) else os.path.join(base_dir, f["abs"])
        syms = list(dict.fromkeys(f["symbols"]))
        out_files.append({
            "id": rp, "name": os.path.basename(rp), "group": group, "role": role_for(rp), "purpose": "",
            "lines": count_lines(abs_path), "symbols": syms[:14], "symbolCount": len(syms), "external": [],
            "cluster": cluster, "in": len(nbr_in[rp]), "out": len(nbr_out[rp]),
            "degree": len(nbr_in[rp] | nbr_out[rp]),
        })

    return {
        "project": name, "generated": datetime.date.today().isoformat(), "commit": git_commit(base_dir),
        "groups": [{"id": g, "count": c} for g, c in group_count.most_common()],
        "files": out_files, "links": links,
    }


def apply_purposes(data, path):
    """Optional: a JSON file {"relative/path": "one-line purpose"} written by Claude."""
    if path and os.path.exists(path):
        purposes = json.load(open(path, encoding="utf-8"))
        for f in data["files"]:
            if purposes.get(f["id"]):
                f["purpose"] = purposes[f["id"]]


def render(data, out_path):
    tpl = open(os.path.join(HERE, "template.html"), encoding="utf-8").read()
    blob = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    name = data["project"].replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    html = tpl.replace("__GRAPH_DATA__", blob).replace("__PROJECT__", name)
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    open(out_path, "w", encoding="utf-8").write(html)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("graph", nargs="?", default="graphify-out/graph.json")
    ap.add_argument("-o", "--out", default="graphify-out/project-map.html")
    ap.add_argument("--name", default=None, help="project name shown in the header (default: folder name)")
    ap.add_argument("--purposes", default="graphify-out/purposes.json", help="optional one-line purpose per file")
    a = ap.parse_args()
    if not os.path.exists(a.graph):
        sys.exit(f"No graph at {a.graph}. Map the project with graphify first.")
    graph = json.load(open(a.graph, encoding="utf-8"))
    base = os.getcwd()
    data = build(graph, a.name or os.path.basename(base) or "Project", base)
    if not data["files"]:
        sys.exit("The graph has no file-backed nodes to draw.")
    apply_purposes(data, a.purposes)
    render(data, a.out)
    print(f"Wrote {a.out}: {len(data['files'])} files, {len(data['links'])} links, {len(data['groups'])} folders")


if __name__ == "__main__":
    main()
