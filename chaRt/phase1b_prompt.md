# chaRt, Phase 1b: four fixes to the data layer (no model calls)

Phase 1 was reviewed in the Claude project. These fixes come from running it on real files.

## Read first

`CLAUDE.md`, `chaRt/STATUS.md`, `chaRt/R/data.R`, and the Data and Codebook parts of
`chaRt/R/ui.R`.

## Rules

As in Phase 1: branch `chart`, small commits, no push, nothing outside `chaRt/`, no file outside
the repository, no model calls, no new packages, no new files. Confirm every function and
argument in the installed package. No em-dashes in prose.

## Fix 1: values that mean missing

`FH_disaggregated.csv` writes missing as `..`, so 23 of its 25 columns were read as text. The
analyst must be able to say which values mean missing, and R must never decide it for them.

- `read_data(path, name, missing = character())`. The values in `missing` are added to
  `DATA_NA`. They match a whole cell only (after trimming), never part of one.
- **Data tab:** under the file input, a text input "Values that mean missing, one per line"
  (a `textAreaInput`) and a "Read again" button. Reading again re-reads the same upload with
  those values, rebuilds the profile, and keeps what the analyst has already entered in the
  codebook (labels, their sources, roles, the row sentence) for every column whose name is
  unchanged. A type or order the data can no longer be is dropped, with a sentence saying so.
- The sentence from `mostly_numbers_note()` now ends by telling the analyst to enter the value
  under "Values that mean missing" and read again, in place of recoding the file.
- **Codebook:** a top-level `missing_codes:` list (empty when none), written and read with the
  rest. When a saved codebook with `missing_codes` is uploaded, the file is re-read with them
  before `check_codebook()` runs, and the Data tab's box shows them.

## Fix 2: a whole-number measure is not an id

Under the Phase 1 rule a column of distinct whole numbers (a population, a revenue in dollars)
is typed `id` and its facts are hidden. New rule in `detect_type()`:

- A character or factor column whose non-missing values are all distinct, in a file of more than
  `CODEBOOK_MAX_LEVELS` rows, is `id`. Unchanged.
- A whole-number column whose values are all distinct is `id` only when its values are an
  unbroken run (`max - min + 1 == distinct`) or its name, lower-cased, matches
  `(^|_)(id|key|code)($|_)`. Otherwise it is `integer`, with the note
  "every value is different; may be an identifier". Nothing is converted on a guess.

Put the pattern and the note in constants at the top of the file.

## Fix 3: roles follow the type

The role select offered every role for every column, so a text column could be made a measure.
`role_choices(entry)` returns the roles a column's current type allows:

| Type | Roles |
|---|---|
| `number` | `measure`, `ignore` |
| `integer` | `measure`, `time`, `ignore` |
| `category`, `ordered`, `flag` | `group`, `ignore` |
| `date` | `time`, `ignore` |
| `id` | `id`, `ignore` |
| `text` | `text`, `ignore` |

The select offers only these. When the analyst changes a type, a role the new type does not
allow becomes that type's default. `check_codebook()` refuses a role outside `role_choices()`,
naming the column.

## Fix 4: ordered levels, one per line

The order box split on commas, so a level containing a comma could not be ordered. Make it a
`textAreaInput` with one level per line. It is accepted only when the lines are exactly the
column's levels.

## Also

In `README.md`, under the tests: run them from PowerShell or the RStudio terminal, not Git Bash.
Git Bash sets `HOME`, so R looks for `.Renviron` in the wrong folder and the live check finds no
key.

## Tests (`tests/smoke.R`)

Keep all 39. Add:

- FH read with `missing = ".."`: at least 20 of its 25 columns are `integer` or `number`, and no
  "mostly numbers" sentence remains for them.
- The messy file with `-99` planted in a number column: read plainly, `-99` is that column's
  minimum; read with `missing = "-99"`, it is not, and the share missing rises.
- A missing value given as `9` does not turn `99` or `19` into missing.
- A codebook with `missing_codes` survives a write and a read unchanged.
- A made column of 200 distinct large whole numbers named `population` is `integer` with the new
  note; a run 1 to 200 named `row` is `id`; 200 distinct whole numbers named `order_id` is `id`;
  200 distinct words is `id`.
- `role_choices()` for each type is the table above; a codebook giving a `text` column the role
  `measure` is refused with a sentence naming the column.
- An ordered column with a comma inside a level accepts its order from lines.
- After "Read again" (call the server-side function directly), an edited label and the row
  sentence are still there.

Show that the new checks can fail.

## Verify, then report back

1. Files changed, with line counts.
2. The smoke test's output.
3. `codebook_index()` for FH read with `missing = ".."`, and `codebook_detail()` for `Country`,
   `pr_2003`, `pr_2014`, `cl_2003` and `cl_2014`.
4. `codebook_index()` for `footballdata-1.csv`, the first 15 lines.
5. Everything you could not confirm, and every departure from this prompt and why.
