"""LLM Council: ask several models, let them blind-rank each other, then a chairman writes the final answer.

Original implementation for lyopz's degen-skill library (idea from karpathy/llm-council).
Talks to any OpenAI-compatible endpoint; defaults to a local OmniRoute gateway. Standard library only.

Usage:
    python council.py "your question"            # uses council.json next to this file if present
    python council.py "question" --models auto/coding auto/cheap gemini/gemini-2.5-pro --chairman auto
    python council.py --list-models

Settings (command line beats environment, environment beats council.json):
    COUNCIL_BASE_URL   default http://localhost:20128/v1   (OmniRoute)
    COUNCIL_API_KEY    your OmniRoute key (Dashboard -> Endpoints). Never put it in a file in the repo.
"""
import argparse
import concurrent.futures as cf
import json
import os
import re
import string
import sys
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULTS = {
    "base_url": "http://localhost:20128/v1",
    "models": ["auto/coding", "auto/smart", "auto/cheap"],
    "chairman": "auto/smart",
    "timeout": 180,
}


def load_settings(a):
    cfg = dict(DEFAULTS)
    path = os.path.join(HERE, "council.json")
    if os.path.exists(path):
        cfg.update({k: v for k, v in json.load(open(path, encoding="utf-8")).items() if k in DEFAULTS})
    cfg["base_url"] = os.environ.get("COUNCIL_BASE_URL", cfg["base_url"])
    if a.base_url:
        cfg["base_url"] = a.base_url
    if a.models:
        cfg["models"] = a.models
    if a.chairman:
        cfg["chairman"] = a.chairman
    cfg["api_key"] = os.environ.get("COUNCIL_API_KEY") or os.environ.get("OMNIROUTE_KEY") or ""
    return cfg


def _request(cfg, path, body=None):
    url = cfg["base_url"].rstrip("/") + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method="POST" if body is not None else "GET")
    req.add_header("Content-Type", "application/json")
    if cfg["api_key"]:
        req.add_header("Authorization", "Bearer " + cfg["api_key"])
    with urllib.request.urlopen(req, timeout=cfg["timeout"]) as r:
        return json.loads(r.read().decode("utf-8"))


def ask(cfg, model, prompt):
    try:
        out = _request(cfg, "/chat/completions", {"model": model, "messages": [{"role": "user", "content": prompt}]})
        return out["choices"][0]["message"]["content"] or "", None
    except urllib.error.HTTPError as e:
        return None, f"HTTP {e.code}: {e.read().decode('utf-8', 'replace')[:200]}"
    except Exception as e:  # network down, gateway not running, bad JSON
        return None, str(e)[:200]


def ask_all(cfg, models, prompt_for):
    with cf.ThreadPoolExecutor(max_workers=len(models)) as ex:
        futs = {m: ex.submit(ask, cfg, m, prompt_for(m)) for m in models}
        return {m: f.result() for m, f in futs.items()}


def rank_prompt(question, labelled):
    answers = "\n\n".join(f"### Answer {k}\n{v}" for k, v in labelled.items())
    keys = ", ".join(labelled)
    return (
        "Several assistants answered the same question. You don't know who wrote which.\n\n"
        f"QUESTION:\n{question}\n\n{answers}\n\n"
        "Judge them only on correctness, usefulness and clarity. Give each answer two or three sentences of "
        "critique, naming concrete mistakes or strengths. Then, on the very last line, write exactly:\n"
        f"RANKING: <the letters {keys}, best first, separated by ' > '>"
    )


def parse_ranking(text, keys):
    m = re.findall(r"RANKING:\s*(.+)", text or "")
    if not m:
        return []
    found = re.findall(r"\b([A-Z])\b", m[-1])
    seen = []
    for k in found:
        if k in keys and k not in seen:
            seen.append(k)
    return seen


def chair_prompt(question, labelled, scores, critiques):
    answers = "\n\n".join(f"### Answer {k} (average rank {scores.get(k, '-')})\n{v}" for k, v in labelled.items())
    reviews = "\n\n".join(f"### Review {i + 1}\n{c}" for i, c in enumerate(critiques))
    return (
        "You chair a council of assistants. Below are their answers to one question, the peer reviews "
        "(written blind), and each answer's average rank (1 = best).\n\n"
        f"QUESTION:\n{question}\n\n{answers}\n\n{reviews}\n\n"
        "Write the single best final answer for the user. Keep what the council got right, fix what the "
        "reviews showed was wrong, and say plainly where the answers disagreed and which view you trust. "
        "Don't mention answer letters or the council process unless it helps the user."
    )


def run(question, cfg, out=sys.stderr):
    models = cfg["models"]
    print(f"Stage 1: asking {len(models)} models...", file=out)
    first = ask_all(cfg, models, lambda m: question)
    good = {m: r for m, (r, err) in first.items() if r}
    failed = {m: err for m, (r, err) in first.items() if not r}
    if not good:
        raise SystemExit("No model answered. Is OmniRoute running and is COUNCIL_API_KEY set?\n" +
                         "\n".join(f"  {m}: {e}" for m, e in failed.items()))

    letters = list(string.ascii_uppercase[:len(good)])
    label_of = dict(zip(good, letters))
    labelled = {label_of[m]: good[m] for m in good}

    print(f"Stage 2: {len(good)} models review each other blind...", file=out)
    reviews = ask_all(cfg, list(good), lambda m: rank_prompt(question, labelled))
    totals, counts, critiques = {k: 0 for k in letters}, {k: 0 for k in letters}, []
    for m, (text, err) in reviews.items():
        if not text:
            continue
        critiques.append(re.sub(r"\n?RANKING:.*$", "", text, flags=re.S).strip())
        for pos, k in enumerate(parse_ranking(text, letters), 1):
            totals[k] += pos
            counts[k] += 1
    scores = {k: round(totals[k] / counts[k], 2) for k in letters if counts[k]}

    print("Stage 3: chairman writes the final answer...", file=out)
    final, err = ask(cfg, cfg["chairman"], chair_prompt(question, labelled, scores, critiques))
    if not final:
        best = min(scores, key=scores.get) if scores else letters[0]
        final = f"(Chairman failed: {err}. Showing the council's top-ranked answer.)\n\n{labelled[best]}"

    board = sorted(good, key=lambda m: scores.get(label_of[m], 99))
    return {
        "final": final,
        "leaderboard": [{"model": m, "avg_rank": scores.get(label_of[m])} for m in board],
        "answers": {m: good[m] for m in good},
        "failed": failed,
    }


def main():
    ap = argparse.ArgumentParser(description="Ask a council of models, then synthesize one answer.")
    ap.add_argument("question", nargs="?")
    ap.add_argument("--models", nargs="+")
    ap.add_argument("--chairman")
    ap.add_argument("--base-url")
    ap.add_argument("--json", action="store_true", help="print the full result as JSON")
    ap.add_argument("--list-models", action="store_true")
    a = ap.parse_args()
    cfg = load_settings(a)

    if a.list_models:
        try:
            for m in _request(cfg, "/models").get("data", []):
                print(m.get("id"))
        except Exception as e:
            sys.exit(f"Couldn't list models from {cfg['base_url']}: {e}")
        return
    if not a.question:
        ap.error("give a question in quotes")

    res = run(a.question, cfg)
    if a.json:
        print(json.dumps(res, indent=2, ensure_ascii=False))
        return
    print("\n=== FINAL ANSWER ===\n" + res["final"])
    print("\n=== LEADERBOARD (avg rank, lower is better) ===")
    for row in res["leaderboard"]:
        print(f"  {row['avg_rank'] if row['avg_rank'] is not None else '-':>5}  {row['model']}")
    for m, e in res["failed"].items():
        print(f"  skipped {m}: {e}")


if __name__ == "__main__":
    main()
