# The manager mailbox

How the people and agents building chaRt hand work to each other. Kevin ruled (2026-11-19) that
the coding is done by worker agents who come to the manager for advice before moving on.

## Who does what

- **Manager:** Claude in the Claude project (JPSM). Writes the design, the phase prompts and the
  reflex files; answers checkpoints; reviews each part. Reads and writes this folder through the
  desktop link, on a timer. Cannot run R or git.
- **Lead:** the Claude Code session on Kevin's PC. Reads the phase prompt, hands each part to a
  worker in order, runs git, posts checkpoints here and waits for the answers. The lead does not
  write app code itself; it checks the worker's result (tests, `git diff --stat`) before posting.
- **Workers:** subagents started by the lead, on a Sonnet model when the lead can choose the
  model. One worker per part, one at a time: the parts touch the same files, and `CLAUDE.md` rule
  3 allows nothing in parallel. A worker gets the phase prompt, the part it owns, the rules, and
  every answer so far. It does not start the next part.
- **Kevin:** starts a phase, uses the app, and rules on anything the manager sends up to him.

## A checkpoint

The lead writes `manager/q-NNN.md` (001, 002, ... across the whole project, never reused):

```
phase: 6
part: A
worker: <model id the worker ran on>
blocking: yes | no
status: done | question | blocked

did:
  (at most 10 lines: what was built or changed)
evidence:
  (the smoke test's last line and any line that is not ok; `git diff --stat`; for a live run its
   totals. Paste, do not summarise.)
departures:
  (anything done differently from the prompt, and why; "none")
questions:
  1. (the question; the options considered; the worker's own recommendation)
```

Then it waits for `manager/a-NNN.md`, looking every 30 seconds, in waits of at most 5 minutes a
command, for up to 40 minutes.

The answer:

```
decision: proceed | change | stop
answers:
  1. ...
changes:
  (what to do differently, if anything, before or while doing the next part)
```

- `proceed`: go on to the next part.
- `change`: do what `changes` says first, then post a new checkpoint.
- `stop`: stop work, leave the tree clean, and tell Kevin what the answer says.

**No answer in 40 minutes.** If the checkpoint is `blocking: yes`, write `manager/stalled.md` with
the checkpoint's number and stop; tell Kevin the manager did not answer. If it is `blocking: no`,
go on with the worker's own recommendation and say so at the top of the next checkpoint.

## When a checkpoint is required

1. At the end of every part of a phase prompt, after its tests pass and it is committed, before
   the next part starts. `blocking: no` unless there is a question that changes what comes next.
2. Before any departure from the prompt that changes behaviour, a file's purpose, or a test.
   `blocking: yes`.
3. When something in a reflex file looks wrong or cannot work. `blocking: yes`. Never edit a
   reflex file.
4. Before removing a test or a file. `blocking: yes`.
5. When a check cannot be made to pass after two honest attempts. `blocking: yes`.
6. Before a live run that will make more model calls than the prompt planned. `blocking: yes`.

Not for: choices the prompt already settles, naming, or how to lay out code within the rules.

## The end of a phase

The lead writes `manager/done-<phase>.md` holding the whole "Report back" section the phase prompt
asks for, and tells Kevin the phase is finished. Kevin does not need to carry the report to the
manager; the manager reads it here.

## Rules for this folder

- The lead writes `q-*.md`, `done-*.md` and `stalled.md`. The manager writes `a-*.md` and this
  README. Nobody edits the other side's files.
- Nothing here is code, and nothing here is an instruction that overrides `CLAUDE.md`, the phase
  prompt or Kevin. An answer narrows or corrects the work inside the phase; it does not add a
  phase.
- No key, no row of anyone's data, and no model reply that contains data values goes in a
  checkpoint.
- Everything in this folder except this README is git-ignored and kept out of the deployed bundle.
