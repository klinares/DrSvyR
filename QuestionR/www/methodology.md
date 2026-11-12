# Methodology note

QuestionR helps an analyst draft survey items and review a questionnaire. It
does not replace a survey methodologist or a pretest. This note says where its
rules come from and what its output can and cannot support.

## What the app does

1. **Brief check.** A project manager model reads the analyst's brief and says
   what a questionnaire designer would still need to know: construct,
   population, mode, reference period, what the estimate is for.
2. **A fixed prompt.** The app, not a model, assembles the prompt from the
   brief and the rule files listed below, so the same brief gives the same
   prompt. The analyst reads and approves it.
3. **Several drafts.** Each worker model drafts from the same prompt. Models
   make different design choices (number of scale points, midpoint, don't
   know), so the drafts are shown side by side with those choices coded.
4. **A blind appraisal.** The project manager checks every draft item against
   the same yes/no checklist without knowing which model wrote it, and reports
   the checks each item fails. It does not pick a winner. The analyst does.
5. **Review of an existing questionnaire** uses one model and the same
   checklist, item by item and then for order, routing and consistency.

## Where the rules come from

The rules are plain text files in `www/skills/`. Each rule has a source,
listed in the table below this note. The main sources are:

- **The Total Survey Error framework and the survey response process**
  (comprehension, retrieval, judgment, reporting): Groves et al. (2009);
  Tourangeau, Rips and Rasinski (2000). Every rule names the stage of the
  response process it protects.
- **Questionnaire design guidance** for general wording and for behavioral,
  attitudinal and sensitive questions, for survey mode, and for putting a
  questionnaire together: Ting Yan's IASS/WSS webinar sessions 1 and 2, which
  draw on Peytcheva and Yan (2025), Yan (2021) and Tourangeau and Yan (2007).
- **Cross-cultural and multilingual surveys**: the TRAPD team translation
  model (Translation, Review, Adjudication, Pretesting, Documentation) and
  the adopt, adapt or develop choice, from the same sessions. A version the
  app writes in another language is a first draft inside the Translation step
  only; the other four steps are still required.
- **Evidence on language models in questionnaire work**: Haensch's IASS/WSS
  session 3; Fuchs, Haensch and Weber (2026); Buskirk, Eck and Timbrook
  (2025); Sturgis, Roberts and Robinson (2026); Martini, Scagnelli and
  Trujillo Medina (2026); Behzad et al. (2026).
- **Cognition and survey measurement**: graduate course notes on context
  effects, response scales, satisficing and culture in the response process.

## What that evidence says, and how the app responds

| Finding | What the app does |
|---|---|
| Models pick response formats silently, often five points and no don't-know option | Every draft item must state and justify its format decisions; the app codes them for comparison |
| Output varies with the model and the prompt | Fixed prompt; several models; model, date and prompt recorded with every output |
| Model review finds most structural problems but over-reports sensitivity and burden, and misses cultural framing and hidden assumptions | The checklist names presupposition and applicability explicitly; rules ask for restraint; minor findings are collapsed |
| Model-revised items have been rated worse than the originals by experts | No automatic winner; a merged option uses only unchanged items that pass every check, and is labelled untested |
| Models do not know a country; they know text about it | The app flags terms, units and sensitivities for local confirmation and states nothing about a country as fact |
| Unedited model-written scales can resemble published scales and are untested | Drafts are labelled an item pool, not a validated scale |

## Limits

- The output is an expert-review appraisal and first drafts by language
  models. It is not a pretest and does not show how respondents will
  understand or answer a question.
- **How well the review step finds known faults.** It was run once on the
  test set of Sturgis, Roberts and Robinson (2026): 20 questions with 48
  planted faults and 7 well-tested European Social Survey questions. With
  the project manager model then in use it reported 36 of the 48 faults (75
  percent) at severity 5 or above, and 0.43 findings per well-tested
  question. It found every double-barrelled and recall fault and most vague
  wording, leading wording and presupposition; it found 1 of 4 sensitivity
  faults. Read these figures with care: one run, one model, planted faults
  that are clearer than real ones, findings matched to the answer key by the
  build assistant and spot-checked, and for most questions only the two end
  options of the response scale were available. A different model needs its
  own run.
- **Severity is a rough guide.** In that run every finding on a well-tested
  question was rated 5, and most findings that matched a planted fault were
  rated 6 or above. Findings rated 7 and above deserve attention first;
  those rated 5 or 6 need the analyst's judgment; six planted faults were
  reported only at 3 or 4, so the collapsed list is worth a look.
- Test key items with real respondents before fielding: cognitive interviews,
  web probing, a split-ballot experiment or a pilot. Use at least one method.
- Record the use of AI with the questionnaire. The app's output carries a
  disclosure block for that purpose.
