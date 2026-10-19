---
name: llm-council
description: Asks a "council" of several AI models the same question, has them anonymously review and rank each other's answers, then writes one final answer from the best parts. Use when lyopz says "council", "llm council", "ask the council", "get a second opinion", "have several models weigh in", or wants a high-stakes question (a plan, a decision, a tricky bug, a fact he needs right) checked by more than one model.
---

<!-- from: karpathy/llm-council (method only; the upstream web app has no license, so no code or prompts are copied) -->

# LLM Council

Three stages: everyone answers on their own, everyone reviews the others blind, then a chairman writes the final answer. It costs several model calls, so only run it when asked or when the question clearly deserves it.

## Who sits on the council

**Default (no setup):** subagents via the Agent tool, one per model, `subagent_type: "general-purpose"`:
- `model: "opus"`, `model: "sonnet"`, `model: "haiku"`, plus `model: "fable"` if available.
- You (the main session) are the chairman.

**Cross-vendor (optional):** if the OmniRoute app is running and lyopz asks for other vendors (GPT, Gemini, Grok…), send stage 1 and 2 through its OpenAI-compatible endpoint instead. See the `omni-inference` and `cli-chat` skills for the URL, key and model names. Don't ask for or store API keys yourself.

## Stage 1 — First answers

Launch all members in parallel (one message, several Agent calls). Each gets the same prompt:
- The question, word for word, plus any context it needs (files, constraints).
- "Answer on your own. Be specific. Say what you're unsure about."
- If the task needs the codebase, tell them which files to read. Members must not edit files.

Keep each answer with its model name. Drop any member that fails; continue if at least two answered.

## Stage 2 — Blind review

Relabel the answers in random order as Answer A, B, C… and keep the label → model map to yourself.

Send every member (in parallel) the question and all labeled answers. Ask them to:
1. Note for each answer what's right, what's wrong or missing.
2. Finish with a ranking, best first, in exactly this form:
   ```
   RANKING:
   1. Answer C
   2. Answer A
   3. Answer B
   ```

Read each `RANKING:` block. Average each answer's position across reviewers (1 = best). If a reviewer's block can't be read, skip that vote.

## Stage 3 — Chairman

Write the final answer yourself using: all stage 1 answers, the reviews, and the average ranks.
- Lead with the best-supported answer. Pull in correct points from the others.
- Where members disagree, say so and say which side holds up and why. Check facts or code yourself when you can, rather than trusting a vote.
- Don't pad it with "the council thinks". Just give the answer.

## What lyopz sees

1. **Final answer** (the main thing).
2. **Scoreboard:** one line per model with its average rank, e.g. `opus 1.3 · sonnet 1.7 · haiku 3.0`.
3. **Disagreements:** 1–3 bullets, only if there were real ones.

Offer the full stage 1 answers and reviews only if he asks.

## Notes
- Members never see model names in stage 2. That keeps them from favoring themselves or a big brand.
- Same-family models (all Claude) agree more than mixed vendors. For a real second opinion on something important, suggest the OmniRoute cross-vendor mode.
- For code changes, the council decides the approach; the main session makes the edit.
