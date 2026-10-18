#!/usr/bin/env python3
"""Build the glowing "neural" file-relationship graph from a graphify graph.json.

graphify's graph.json is symbol-level (functions, types, README concepts).
This script folds it into one node per file and one link per file pair, keeps
the reason for every link (which symbols are imported, called or typed), and
writes a single self-contained HTML page from templates/neural-graph.html.

Usage:
  python3 neural_graph.py --graph graphify-out/graph.json --root . \
      --out graphify-out/neural-graph.html [--purposes purposes.json] [--title NAME]

--purposes is an optional JSON object {"src/app.ts": "one-line purpose"}.
Files without an entry fall back to their leading comment, then to a role.
Standard library only.
"""
import argparse
import json
import math
import re
import subprocess
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_TEMPLATE = HERE.parent / "templates" / "neural-graph.html"

# graphify relation -> link kind shown in the page
KIND_OF = {
    "imports": "imports", "imports_from": "imports", "re_exports": "imports",
    "dynamic_import": "imports",
    "calls": "calls", "indirect_call": "calls",
    "references": "types", "implements": "types", "inherits": "types",
    "conceptually_related_to": "docs", "rationale_for": "docs",
    "semantically_similar_to": "docs",
}
SKIP_RELATIONS = {"contains", "method"}

# Folder name -> role shown on selection. Unknown folders get a title-cased name.
ROLES = {
    "ui": "Interface panel", "components": "UI component", "pages": "Page",
    "views": "View", "viewport": "Canvas rendering", "render": "Rendering",
    "engine": "Core engine", "core": "Core logic", "lib": "Library code",
    "utils": "Utility", "helpers": "Utility", "model": "Data model",
    "models": "Data model", "types": "Type definitions", "schema": "Schema",
    "store": "App state", "state": "App state", "hooks": "React hook",
    "ai": "AI layer", "api": "API layer", "server": "Server",
    "services": "Service", "persistence": "Storage", "db": "Database",
    "characters": "Character art", "styles": "Styles", "assets": "Asset",
    "tests": "Test suite", "test": "Test suite", "__tests__": "Test suite",
    "scripts": "Script", "docs": "Documentation", "config": "Config",
}
CODE_SUFFIXES = {".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".py", ".go",
                 ".rs", ".java", ".kt", ".rb", ".php", ".cs", ".swift", ".c",
                 ".cpp", ".h", ".vue", ".svelte", ".css", ".scss", ".html"}
SOURCE_ROOTS = {"src", "lib", "app", "packages", "source"}


def norm(s):
    return re.sub(r"[^a-z0-9]+", "_", s.lower()).strip("_")


def group_of(path):
    parts = path.split("/")
    if len(parts) > 2 and parts[0] in SOURCE_ROOTS:
        return parts[1]
    if len(parts) > 1:
        return parts[0]
    return "root"


def is_test(path):
    p = path.lower()
    return "/tests/" in "/" + p or "/__tests__/" in "/" + p or re.search(r"\.(test|spec)\.", p) is not None


def is_doc(path):
    return path.lower().endswith((".md", ".mdx", ".txt", ".rst"))


def role_of(path, group):
    name = path.rsplit("/", 1)[-1].lower()
    stem = name.split(".")[0]
    if is_test(path):
        return "Test suite"
    if is_doc(path):
        return "Documentation"
    if stem in {"main", "index", "app"} and group in {"src", "root", "app"}:
        return "Entry point"
    if name.endswith((".json", ".toml", ".yaml", ".yml")) or ".config." in name:
        return "Config"
    return ROLES.get(group, group.replace("-", " ").replace("_", " ").title())


def leading_comment(text):
    """First comment block of a file, as one sentence-ish line."""
    lines = text.splitlines()
    out, in_block = [], False
    for raw in lines[:40]:
        line = raw.strip()
        if not out and (not line or line.startswith("#!")):
            continue
        if in_block:
            end = "*/" in line
            out.append(line.split("*/")[0].lstrip("* ").strip())
            if end:
                break
            continue
        if line.startswith("/*"):
            in_block = "*/" not in line[2:]
            body = line[2:].split("*/")[0].lstrip("*").strip()
            if body:
                out.append(body)
            if not in_block:
                break
            continue
        if line.startswith("//") or (line.startswith("#") and not line.startswith("#!")):
            out.append(line.lstrip("/#").strip())
            continue
        if line.startswith('"""') or line.startswith("'''"):
            q = line[:3]
            body = line[3:]
            if q in body:
                out.append(body.split(q)[0])
                break
            out.append(body)
            for nxt in lines[lines.index(raw) + 1: 40]:
                if q in nxt:
                    out.append(nxt.split(q)[0].strip())
                    break
                out.append(nxt.strip())
            break
        break
    text = " ".join(x for x in out if x).strip()
    text = re.sub(r"\s+", " ", text)
    if len(text) > 320:
        cut = text[:320]
        text = cut[: cut.rfind(". ") + 1] if ". " in cut else cut.rsplit(" ", 1)[0] + "…"
    return text


def git_commit(root):
    try:
        return subprocess.run(["git", "-C", str(root), "rev-parse", "--short", "HEAD"],
                              capture_output=True, text=True, timeout=10).stdout.strip() or None
    except Exception:
        return None


def build(graph, root, purposes):
    nodes = graph["nodes"]
    links = graph.get("links") or graph.get("edges") or []
    real = {p.relative_to(root).as_posix() for p in root.rglob("*")
            if p.is_file() and ".git" not in p.parts and "node_modules" not in p.parts
            and "graphify-out" not in p.parts}
    stem_to_file = {}
    for f in real:
        stem_to_file.setdefault(norm(f.rsplit(".", 1)[0]), f)

    def resolve(n):
        sf = (n.get("source_file") or "").replace("\\", "/")
        if sf.startswith(str(root)):
            sf = sf[len(str(root)):].lstrip("/")
        if sf in real:
            return sf
        # Fall back to the id prefix (graphify ids start with the file stem).
        nid = n["id"]
        best = None
        for stem, f in stem_to_file.items():
            if (nid == stem or nid.startswith(stem + "_")) and (best is None or len(stem) > len(best[0])):
                best = (stem, f)
        return best[1] if best else None

    file_of, label_of, external_ids = {}, {}, set()
    symbols = defaultdict(list)
    for n in nodes:
        label_of[n["id"]] = n.get("label") or n["id"]
        if n["id"].startswith("ref_"):
            external_ids.add(n["id"])
            continue
        f = resolve(n)
        if not f:
            continue
        file_of[n["id"]] = f
        lab = n.get("label") or ""
        if lab and lab != f.rsplit("/", 1)[-1] and n.get("file_type") == "code":
            symbols[f].append(lab)

    community = defaultdict(Counter)
    for n in nodes:
        f = file_of.get(n["id"])
        if f and n.get("community_name"):
            community[f][n["community_name"]] += 1

    pair = defaultdict(lambda: {"kinds": Counter(), "why": defaultdict(list)})
    external = defaultdict(set)
    for e in links:
        rel = e.get("relation")
        if rel in SKIP_RELATIONS:
            continue
        s, t = e["source"], e["target"]
        sf = file_of.get(s)
        if not sf:
            continue
        if t in external_ids:
            external[sf].add(label_of[t])
            continue
        tf = file_of.get(t)
        if not tf or tf == sf or tf.endswith("package.json") and not sf.endswith("package.json"):
            continue
        kind = KIND_OF.get(rel)
        if not kind:
            continue
        if is_doc(sf) or is_doc(tf):
            kind = "docs"
            # Keep doc links pointing from the doc to the code it describes.
            if is_doc(tf) and not is_doc(sf):
                sf, tf, s, t = tf, sf, t, s
        elif is_test(sf):
            kind = "tests"
        p = pair[(sf, tf)]
        p["kinds"][kind] += 1
        tl = label_of.get(t, t)
        if tl != tf.rsplit("/", 1)[-1]:
            if kind == "docs":
                note = f"“{label_of.get(s, s)}” → {tl}"
            else:
                note = tl
            if note not in p["why"][kind]:
                p["why"][kind].append(note)

    files = sorted({f for f in file_of.values()})
    involved = {f for k in pair for f in k} | set(files)
    deg_in, deg_out, nbrs = Counter(), Counter(), defaultdict(set)
    out_links = []
    verbs = {"imports": "imports", "calls": "calls", "types": "uses types",
             "tests": "tests", "docs": "documents"}
    for (sf, tf), p in pair.items():
        weight = sum(p["kinds"].values())
        primary = max(p["kinds"], key=lambda k: (p["kinds"][k], k == "calls"))
        why = []
        # A symbol that is both imported and called reads once, under "calls".
        called = {x.rstrip("()").lstrip(".") for x in p["why"].get("calls", [])}
        if called and "imports" in p["why"]:
            p["why"]["imports"] = [x for x in p["why"]["imports"] if x.rstrip("()") not in called]
            if not p["why"]["imports"]:
                del p["why"]["imports"]
        for k, items in sorted(p["why"].items(), key=lambda kv: -p["kinds"][kv[0]]):
            shown = items[:6]
            more = f" +{len(items) - 6} more" if len(items) > 6 else ""
            why.append(f"{verbs[k]} {', '.join(shown)}{more}")
        out_links.append({"s": sf, "t": tf, "kinds": dict(p["kinds"]),
                          "primary": primary, "w": weight, "why": why})
        deg_out[sf] += 1
        deg_in[tf] += 1
        nbrs[sf].add(tf)
        nbrs[tf].add(sf)

    out_files = []
    for f in sorted(involved):
        path = root / f
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            text = ""
        g = group_of(f)
        purpose = purposes.get(f) or leading_comment(text) or ""
        syms = list(dict.fromkeys(symbols.get(f, [])))
        out_files.append({
            "id": f, "name": f.rsplit("/", 1)[-1], "group": g, "role": role_of(f, g),
            "purpose": purpose, "lines": text.count("\n") + (1 if text and not text.endswith("\n") else 0),
            "symbols": syms[:14], "symbolCount": len(syms),
            "external": sorted(external.get(f, [])),
            "cluster": community[f].most_common(1)[0][0] if community[f] else None,
            "in": deg_in[f], "out": deg_out[f], "degree": len(nbrs[f]),
        })

    gcount = Counter(f["group"] for f in out_files)
    groups = [{"id": g, "count": c} for g, c in gcount.most_common()]
    return out_files, out_links, groups


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--graph", default="graphify-out/graph.json")
    ap.add_argument("--root", default=".")
    ap.add_argument("--out", default="graphify-out/neural-graph.html")
    ap.add_argument("--purposes")
    ap.add_argument("--title")
    ap.add_argument("--template", default=str(DEFAULT_TEMPLATE))
    ap.add_argument("--json-only", action="store_true", help="write the data JSON instead of HTML")
    a = ap.parse_args()

    root = Path(a.root).resolve()
    graph = json.loads(Path(a.graph).read_text(encoding="utf-8"))
    purposes = json.loads(Path(a.purposes).read_text(encoding="utf-8")) if a.purposes else {}
    files, links, groups = build(graph, root, purposes)
    data = {
        "project": a.title or root.name,
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
        "commit": git_commit(root),
        "groups": groups, "files": files, "links": links,
    }
    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    if a.json_only:
        out.write_text(payload, encoding="utf-8")
    else:
        tpl = Path(a.template).read_text(encoding="utf-8")
        if "__GRAPH_DATA__" not in tpl:
            raise SystemExit("template is missing the __GRAPH_DATA__ placeholder")
        html = tpl.replace("__GRAPH_DATA__", payload).replace("__PROJECT_NAME__", data["project"])
        out.write_text(html, encoding="utf-8")
    print(f"neural graph: {len(files)} files, {len(links)} links, {len(groups)} groups -> {out}")


if __name__ == "__main__":
    main()
