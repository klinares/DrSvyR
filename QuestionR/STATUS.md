# QuestionR: status

Read `DESIGN.md` first. Update this file at the end of every session.

## Where things stand (2026-11-11)

- `DESIGN.md` written in the Claude project. Not yet reviewed by a build.
- `www/skills/`: ten skill files and a README, version 0.1, drafted from the
  IASS/WSS questionnaire design sessions, the papers in the project and the
  SURV632 notes. They follow the reflex structure but no model has run
  against them.
- `tests/openrouter_check.R`: throwaway, written, not yet run.
- `tests/review.R`: written in the Claude project, not yet run (no R there).
  Expect to fix small bugs in it on first run; report them here.
- `PROMPTS.md`: the Claude Code prompt for Phases 0 and 1.
- No app code yet.

## Next task

Phase 0 (scaffold), then Phase 1 (skills loader and prompt assembly).

## Open decisions (default in brackets)

1. Models at home: settled by Kevin 2026-11-11. Workers through OpenRouter:
   `google/gemma-4-31b-it`, `meta-llama/llama-4-maverick`,
   `openai/gpt-6-luna-decisions`. PM: `claude-sonnet-5-5` for now (cheaper
   than Opus), on Anthropic's API, key pasted into the app (not from the
   environment) to rehearse the work setup.
2. Which ellmer function serves the OpenAI-style calls with a custom base
   URL. [Check installed help; record the function and arguments here.]
3. Copy button on tab 4. [Leave it out; select and copy.]
4. Paste cap for Evaluate. [15000 characters.]
5. When to move the PM to Opus. [After Phase 4 passes on Sonnet; rerun the
   gold test on Opus and compare.]
6. Work base URL and model IDs. [Left as placeholders until Phase 6.]

## Log

- **Phase 0 (2026-11-11), branch `questionr` from `main`.** Scaffold built:
  `app.R` (settings, profile block, masking checks, sources `R/`, state, ui,
  server), `R/llm.R` (key box only), `R/ui.R` (Start here, office logo,
  placeholder tabs), `.rscignore`, `README.md`, `tests/smoke.R`, and rows in the
  root `README.md` and `CLAUDE.md`. `tests/smoke.R`: 18 checks, all ok.
  `tests/review.R 0`: no FAIL, all 11 skill checksums match, `review.R` needed no
  fix. `REVIEW.md`'s git section was generated before this commit, so it lists
  `?? ./` as uncommitted and an empty diff against `main`; Phase 1's `REVIEW.md`
  shows this commit. Phase 1 is next; the full report is written at its end.
