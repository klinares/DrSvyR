# output.R for QuestionR
# What the Output tab and the Methodology tab are made of (DESIGN.md sections 8
#   and 14), as plain functions with no Shiny and no model call in them, so a test
#   can build every output without a browser: the skills as a table, the kept items
#   or the review as HTML that pastes into Word and as plain text, the disclosure
#   block, the TRAPD block, and the run log. The screens that show them are in
#   ui_output.R's place, the last part of ui_generate.R. Function definitions and
#   constants only.


# ---- the skills as a table (Methodology tab) -----------------------------------------------

# One row per reflex of every skill file, in the order of SKILL_FILES: file, id, when
#   it applies, and its source ("" when a reflex gives none). Read from the files as
#   the prompts are, so the table cannot say something the prompts do not.
skills_table <- function(dir = SKILLS_DIR) {
  skills = purrr::map(purrr::set_names(SKILL_FILES), function(f) read_skill(f, dir))
  rows = purrr::list_flatten(unname(purrr::imap(skills, function(s, file)
    purrr::map(unname(s$reflexes), function(r)
      list(file = file, id = r$id, when = r$when, source = if (is.na(r$source)) "" else r$source)))))
  data.frame(file = purrr::map_chr(rows, "file"), id = purrr::map_chr(rows, "id"),
             when = purrr::map_chr(rows, "when"), source = purrr::map_chr(rows, "source"),
             stringsAsFactors = FALSE)
}
