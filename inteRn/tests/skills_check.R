# skills_check.R -- checks the shared skills: their frontmatter, loading
#   through inteRn, the scripts, and every runnable R example in the skill
#   files. Public data only (palmerpenguins, survey::api). No API calls.
#
#   Rscript --no-init-file inteRn/tests/skills_check.R

here = local({
  a = commandArgs(FALSE)
  f = sub("^--file=", "", a[grepl("^--file=", a)])
  if (length(f)) dirname(normalizePath(f)) else getwd()
})
Sys.setenv(INTERN_HOME = normalizePath(file.path(here, ".."), winslash = "/"))
options(intern.quiet = TRUE)
grDevices::pdf(NULL)   # ggplot_build() opens a device; keep Rplots.pdf out of the working folder
source(file.path(Sys.getenv("INTERN_HOME"), "inteRn.R"))
core = environment(open_intern)
skills_dir = core$intern_skills_dir()

results = new.env(); results$n = 0L; results$fail = character(0)
check = function(what, ok) {
  results$n = results$n + 1L
  if (!isTRUE(ok)) results$fail = c(results$fail, what)
  cat(if (isTRUE(ok)) "ok   " else "FAIL ", what, "\n", sep = "")
}

# ---- discovery and loading ----------------------------------------------------
sk = core$list_skills()
nms = purrr::map_chr(sk, "name")
check("three skills found", all(c("tidyverse-style", "dataviz", "survey-design") %in% nms))
check("names match folders", all(purrr::map_lgl(sk, function(s) identical(s$name, s$folder))))
check("every skill has when_to_use", all(nzchar(purrr::map_chr(sk, "when_to_use"))))
sp = core$intern_system_prompt()
check("system prompt lists skills", grepl("## Skills", sp) && grepl("- dataviz:", sp, fixed = TRUE))
body = core$load_skill_tool("dataviz")
check("load_skill returns the body without frontmatter",
      grepl("# Data visualisation", body) && !grepl("^---", body) && !grepl("when_to_use:", body))
check("load_skill lists files and how to source scripts",
      grepl("references/principles.md", body) && grepl("intern_source_skill", body))
check("load_skill reads a reference",
      grepl("Gestalt", core$load_skill_tool("dataviz", "references/principles.md")))
check("load_skill refuses paths outside the skill",
      grepl("no readable file", core$load_skill_tool("dataviz", "../../inteRn/config.example.R")))
check("load_skill refuses unknown skills", grepl("no skill called", core$load_skill_tool("nope")))
check("load_skill refuses odd names", grepl("no skill called", core$load_skill_tool("../dataviz")))

# ---- scripts -------------------------------------------------------------------
before = ls(globalenv())
intern_source_skill("dataviz", "theme_intern.R")
intern_source_skill("dataviz", "palette_check.R")
intern_source_skill("survey-design", "design_check.R")
check("scripts define their functions",
      all(c("theme_intern", "plot_estimates", "palette_check", "check_design_inputs",
            "build_design", "design_summary") %in% ls(globalenv())))
check("scripts define functions and constants only",
      all(purrr::map_lgl(setdiff(ls(globalenv()), before), function(n) {
        x = get(n, envir = globalenv())
        is.function(x) || is.character(x)
      })))

suppressPackageStartupMessages({ library(dplyr); library(srvyr); library(ggplot2) })
data(api, package = "survey")
est = apistrat |>
  as_survey_design(strata = stype, weights = pw, fpc = fpc) |>
  group_by(stype) |>
  summarise(api00 = survey_mean(api00, vartype = "ci"), n = unweighted(n()))
p = plot_estimates(est, x = api00, y = stype, lower = api00_low, upper = api00_upp,
                   title = "High schools score lowest", caption = "survey::apistrat")
png_file = file.path(tempdir(), "plot_estimates.png")
ggsave(png_file, p, width = 6, height = 3, dpi = 100)
check("plot_estimates draws", file.exists(png_file) && inherits(p, "ggplot"))
check("plot_estimates sorts by estimate",
      identical(levels(ggplot_build(p)$plot$data$.y)[1], as.character(est$stype[which.min(est$api00)])))
both = bind_rows(mutate(est, kind = "Weighted"),
                 mutate(est, kind = "Unweighted", api00 = api00 - 10,
                        api00_low = api00_low - 10, api00_upp = api00_upp - 10))
p2 = plot_estimates(both, x = api00, y = stype, lower = api00_low, upper = api00_upp, colour = kind)
ggsave(file.path(tempdir(), "plot_estimates2.png"), p2, width = 6, height = 3, dpi = 100)
check("plot_estimates with groups draws", inherits(p2, "ggplot"))

pc_ok = suppressMessages(palette_check(okabe_ito[1:6]))
pc_vir = suppressMessages(palette_check(viridisLite::viridis(5)))
pc_bad = suppressMessages(palette_check(c("red", "green", "#00FF00")))
cat("     Okabe-Ito min Delta E:", round(attr(pc_ok, "min_delta_e"), 1), "\n")
check("palette_check: Okabe-Ito is safe", identical(attr(pc_ok, "verdict"), "safe"))
check("palette_check: viridis is safe", identical(attr(pc_vir, "verdict"), "safe"))
check("palette_check: red/green is unsafe", startsWith(attr(pc_bad, "verdict"), "unsafe"))

spec1 = design_spec(ids = "dnum", weights = "pw", fpc = "fpc")
c1 = check_design_inputs(apiclus1, spec1)
check("design check: clean cluster design passes", !any(c1$status == "fail"))
d1 = build_design(apiclus1, spec1)
check("build_design matches svydesign",
      isTRUE(all.equal(survey::SE(survey::svymean(~api00, d1)),
                       survey::SE(survey::svymean(~api00, survey::svydesign(
                         ids = ~dnum, weights = ~pw, fpc = ~fpc, data = apiclus1))))))
s1 = design_summary(d1)
check("design_summary counts PSUs", s1$psus == 15 && s1$design_df == 14)

c_missing = check_design_inputs(apiclus1, design_spec(ids = "district", weights = "pw"))
check("design check: absent variable fails", c_missing$status[1] == "fail")

reused = apistrat |> mutate(psu = rep(1:50, 4)[seq_len(n())])
c2 = check_design_inputs(reused, design_spec(ids = "psu", strata = "stype", weights = "pw"))
check("design check: PSU codes reused across strata need nest",
      c2$status[c2$check == "PSUs nested in strata"] == "fail")
c3 = check_design_inputs(reused, design_spec(ids = "psu", strata = "stype", weights = "pw",
                                             nest = TRUE))
check("design check: nest = TRUE accepted", c3$status[c3$check == "PSUs nested in strata"] == "ok")
lonely = apiclus2 |> mutate(stratum = if_else(dnum == dnum[1], "solo", "rest"))
c4 = check_design_inputs(lonely, design_spec(ids = "dnum", strata = "stratum", weights = "pw"))
check("design check: singleton stratum warned",
      c4$status[c4$check == "strata with one PSU"] == "warn")
badw = apiclus1 |> mutate(pw = replace(pw, 1:2, c(NA, -1)))
c5 = check_design_inputs(badw, spec1)
check("design check: missing and negative weights fail",
      all(c5$status[c5$check %in% c("weights missing", "weights positive")] == "fail"))

rdes = survey::as.svrepdesign(d1, type = "JK1")
repw = stats::weights(rdes, "analysis")             # full replicate weights, n x R
colnames(repw) = paste0("repwt", seq_len(ncol(repw)))
repdat = bind_cols(apiclus1, as_tibble(repw))
spec_r = design_spec(weights = "pw", repweights = "^repwt[0-9]+$", type = "JK1",
                     scale = rdes$scale, rscales = rdes$rscales, mse = rdes$mse)
check("design check: replicate weights found",
      all(check_design_inputs(repdat, spec_r)$status != "fail"))
d_r = suppressWarnings(build_design(repdat, spec_r))
check("build_design with replicate weights reproduces the SE",
      isTRUE(all.equal(unname(survey::SE(survey::svymean(~api00, d_r))),
                       unname(survey::SE(survey::svymean(~api00, rdes))), tolerance = 1e-6)))

# ---- R examples inside the skill files -------------------------------------------
# Every ```r block is run in order, per file, in one environment. Blocks that
#   are templates on purpose (placeholder data `d`, `files`, `x`, `a`/`b`, or
#   a personal path to show what not to do) are listed and skipped.
TEMPLATE = paste0("data = d\\b|\\bd \\|>|\\bd\\$|\\bfiles\\b|\\bx\\[|sum\\(x\\)|merge\\(a|",
                  "^a \\|>|C:/Users|here::here|<- c\\(\\)|data.frame\\(\\)")
run_blocks = function(file) {
  txt = readLines(file, encoding = "UTF-8", warn = FALSE)
  starts = which(txt == "```r")
  ends = which(txt == "```")
  blocks = purrr::map(starts, function(s) txt[(s + 1):(min(ends[ends > s]) - 1)])
  env = new.env(parent = globalenv())
  purrr::map_chr(blocks, function(b) {
    code = paste(b, collapse = "\n")
    if (grepl(TEMPLATE, code)) return("template")
    r = tryCatch({
      utils::capture.output(withCallingHandlers(
        eval(parse(text = code), envir = env),
        warning = function(w) {
          if (grepl("deprecat|superseded", conditionMessage(w), ignore.case = TRUE))
            stop("deprecated: ", conditionMessage(w))
          invokeRestart("muffleWarning")
        }))
      "ok"
    }, error = function(e) paste("error:", conditionMessage(e)))
    r
  })
}
# ---- codebook, end to end (stand-in model) --------------------------------------
intern_source_skill("codebook", "codebook.R")
has_cli = tryCatch(nzchar(dd_cli()), error = function(e) FALSE)
check("data-dict CLI found", has_cli)
pen = palmerpenguins::penguins
prof = codebook_profile(pen, 10)
pt = profile_text(prof, "penguins")
check("profile text: suppressed, no min or max",
      grepl("fewer than 10 missing", pt) && !grepl("32.1|59.6|2,700|6,300|172|231", pt))

stub_reply = paste(
  "Here is the proposal.", "", "```yaml",
  "dataset:", "  label: Palmer penguins",
  "  description: One row per penguin observed near Palmer Station, Antarctica.",
  "columns:",
  "  - name: species", "    label: Species", "    type: enum",
  "    values: [Adelie, Chinstrap, Gentoo]", "    description: Penguin species.",
  "  - name: island", "    label: Island", "    type: enum",
  "    values: [Biscoe, Dream, Torgersen, Anvers]", "    description: Island of observation.",
  "  - name: bill_length_mm", "    label: Bill length", "    type: number(quantity)",
  "    units: mm", "    description: Length of the bill.",
  "  - name: bill_depth_mm", "    label: Bill depth", "    type: number(quantity)", "    units: mm",
  "  - name: flipper_length_mm", "    label: Flipper length", "    type: number(quantity)", "    units: mm",
  "  - name: body_mass_g", "    label: Body mass", "    type: number(quantity)", "    units: g",
  "  - name: sex", "    label: Sex", "    type: enum", "    values: [female, male]",
  "    todo: How was sex determined, and why are some missing?",
  "  - name: year", "    label: Year", "    type: number(ordinal)",
  "```", sep = "\n")
seen = new.env()
stub = function(prompt, system) { seen$prompt = prompt; seen$system = system; stub_reply }
cbdir = file.path(tempdir(), "cb_penguins")
unlink(cbdir, recursive = TRUE)
dict_path = codebook_draft(pen, cbdir, table = "penguins", describe = stub,
                           context = "The palmerpenguins R package.")
sent = seen$prompt
check("draft: what was sent is saved for audit",
      identical(paste(readLines(file.path(cbdir, "sent_to_model.txt")), collapse = "\n"), sent))
check("draft: no examples, ranges or source path sent",
      !grepl("examples:|range:|penguins.parquet|32.1|59.6|2700|6300", sent))
d = yaml::read_yaml(dict_path)
dc = rlang::set_names(d$tables[[1]]$columns, purrr::map_chr(d$tables[[1]]$columns, "name"))
check("merge: enum accepted when values match the data",
      identical(dc$species$type, "enum") && length(dc$species$values) == 3L)
check("merge: enum refused when values do not match, with a todo",
      identical(dc$island$type, "string") && grepl("do not match", dc$island$todo))
check("merge: quantity keeps the local range and gets units",
      identical(dc$body_mass_g$type, "number(quantity)") && identical(dc$body_mass_g$units, "g") &&
        length(dc$body_mass_g$range) == 2L)
check("merge: model todo kept", grepl("How was sex determined", dc$sex$todo))
check("merge: dataset description set", grepl("Palmer Station", d$description))

v = dd_validate(cbdir)
check("validate-data runs and has no errors", v$status %in% c("pass", "warning") &&
        !any(v$problems$severity == "error"))
cat("     validate status:", v$status, "-", nrow(v$problems), "problem(s):",
    paste(unique(v$problems$code), collapse = ", "), "\n")

# A toy survey file with a name column (restricted) and a labelled item.
set.seed(2)
toy_svy = tibble::tibble(
  resp_id = 1:40,
  full_name = sprintf("Person %02d", 1:40),
  agree = structure(sample(c(1, 2, 9), 40, replace = TRUE, prob = c(.5, .4, .1)),
                    labels = c(Agree = 1, Disagree = 2, Refused = 9),
                    label = "Do you agree?",
                    class = c("haven_labelled", "vctrs_vctr", "double")),
  wt = round(runif(40, 0.5, 2), 3))
stub2 = function(prompt, system) {
  seen$prompt2 = prompt
  paste("```yaml", "dataset:", "  description: Toy survey.", "columns:",
        "  - name: resp_id", "    type: number(id)", "    description: Respondent identifier.",
        "  - name: full_name", "    display: restricted", "    description: Respondent name.",
        "  - name: agree", "    type: enum", "    values: [Agree, Disagree, Refused]",
        "  - name: wt", "    type: number(quantity)", "    description: Final survey weight.",
        "```", sep = "\n")
}
tdir = file.path(tempdir(), "cb_toy")
unlink(tdir, recursive = TRUE)
codebook_draft(toy_svy, tdir, table = "toy", describe = stub2)
check("draft: names never sent", !grepl("Person [0-9]", seen$prompt2))
td = yaml::read_yaml(file.path(tdir, "data-dict.yaml"))
tc = rlang::set_names(td$tables[[1]]$columns, purrr::map_chr(td$tables[[1]]$columns, "name"))
check("restricted column: real examples replaced",
      identical(tc$full_name$display, "restricted") &&
        !any(grepl("Person", unlist(tc$full_name$examples))) &&
        !any(grepl("Person", readLines(file.path(tdir, "data-dict.yaml")))))
check("labelled codes documented as their labels", identical(tc$agree$type, "enum"))
tv = dd_validate(tdir)
check("toy dictionary validates without errors", !any(tv$problems$severity == "error"))

# inteRn's file tools and the dictionary
old_wd = setwd(cbdir)
rf = core$read_file_tool("data-dict.yaml")
check("read_file shows the dictionary without examples or ranges",
      grepl("examples, ranges and source removed", rf) && !grepl("range:|examples:|2700", rf))
check("write_file will not overwrite a dictionary",
      grepl("does not overwrite a data dictionary", core$write_file_tool("data-dict.yaml", "x: 1")))
check("read_file refuses rendered reports", inherits(tryCatch(
  { writeLines("<html></html>", "r.html"); core$read_file_tool("r.html") },
  error = function(e) e), "error"))
setwd(old_wd)

if (nzchar(Sys.which("quarto"))) {
  html = codebook_render(cbdir, title = "Palmer penguins")
  page = paste(readLines(html, warn = FALSE), collapse = "\n")
  check("codebook renders", file.exists(html) && grepl("Open questions", page) &&
          grepl("Palmer Station", page))
  check("codebook: small missing counts suppressed in the table", grepl("&lt;10|<10", page))
  cat("     rendered:", html, "\n")
}

md = c(list.files(skills_dir, pattern = "[.]md$", recursive = TRUE, full.names = TRUE))
md = md[!grepl("README|SKILL", md)]
purrr::walk(md, function(f) {
  r = run_blocks(f)
  rel = sub(paste0(skills_dir, "/"), "", f, fixed = TRUE)
  bad = r[startsWith(r, "error")]
  check(sprintf("examples in %s run (%d ok, %d templates skipped)", rel, sum(r == "ok"),
                sum(r == "template")), !length(bad))
  if (length(bad)) cat(paste0("       ", bad, collapse = "\n"), "\n")
})

cat("\n", results$n - length(results$fail), " of ", results$n, " checks passed\n", sep = "")
if (length(results$fail)) quit(status = 1)
