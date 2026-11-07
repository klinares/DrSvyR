# smoke.R -- checks inteRn without calling the API.
#
# Run from anywhere:  Rscript --no-init-file <path>/inteRn/tests/smoke.R
# Uses toy objects and palmerpenguins / survey::api only, never project data.

here = local({
  a = commandArgs(FALSE)
  f = sub("^--file=", "", a[grepl("^--file=", a)])
  if (length(f)) dirname(normalizePath(f)) else getwd()
})
Sys.setenv(INTERN_HOME = normalizePath(file.path(here, ".."), winslash = "/"))
options(intern.quiet = TRUE)

results = new.env()
results$n = 0L
results$fail = character(0)
check = function(what, ok) {
  results$n = results$n + 1L
  if (!isTRUE(ok)) results$fail = c(results$fail, what)
  cat(if (isTRUE(ok)) "ok   " else "FAIL ", what, "\n", sep = "")
}

# ---- loading ----------------------------------------------------------------
before = ls(globalenv())
source(file.path(Sys.getenv("INTERN_HOME"), "inteRn.R"))
check("attached as 'inteRn'", "inteRn" %in% search())
check("exports visible", all(c("ask", "%ask%", "intern_reset", "intern_config") %in%
                               ls("inteRn", all.names = TRUE)))
check("workspace untouched", identical(setdiff(ls(globalenv()), "before"), before))
core = environment(get("ask", envir = as.environment("inteRn")))
check("internals stay private", !exists("describe_value", envir = globalenv()))
check("example config has no problems", length(core$intern_config_problems()) == 0L)

# ---- config checks ----------------------------------------------------------
bad_cfg = core$INTERN_LLM
bad_cfg$key_var = "sk-ant-abc123"; bad_cfg$cache = "forever"; bad_cfg$suppress_n = 0
probs = core$intern_config_problems(bad_cfg)
check("bad config caught (key in key_var, cache, suppress_n)",
      length(probs) == 3L && any(grepl("looks like a key", probs)))

# ---- toy data ---------------------------------------------------------------
set.seed(1)
toy = data.frame(
  id = 1:60,
  name = c(rep("Alice Smith", 3), sprintf("person_%02d", 4:60)),
  region = factor(c(rep("North", 25), rep("South", 32), rep("Island", 3))),
  income = round(rnorm(60, 50000, 12000)),
  visit = as.Date("2024-01-01") + 0:59,
  stringsAsFactors = FALSE)
toy$agree = structure(c(rep(1, 30), rep(2, 27), rep(9, 3)),
                      labels = c(Agree = 1, Disagree = 2, Refused = 9),
                      label = "Do you agree?",
                      class = c("haven_labelled", "vctrs_vctr", "double"))
toy$income[c(5, 9)] = NA
toy$mode = sample(c("web", "phone"), 60, replace = TRUE)
assign("toy", toy, envir = globalenv())

d = core$describe_object("toy")
check("describe: names, types, labels", grepl("income <numeric>", d) &&
        grepl("label \"Do you agree?\"", d, fixed = TRUE) && grepl("1=Agree", d) &&
        grepl("3 levels: Island \\| North \\| South", d))
check("describe: no values", !grepl("Alice|person_|50[0-9]{3}|2024", d))

p = core$profile_object("toy")
check("profile: small cell suppressed", grepl("Island <10", p))
check("profile: secondary suppression marked, not shown as small", grepl("North suppressed", p) && !grepl("North <10", p))
check("profile: rare character text hidden", !grepl("Alice", p) &&
        grepl("distinct values \\(not listed\\)", p))
check("profile: short character columns tabulated", grepl("web [0-9]+ \\(", p))
check("profile: missing count suppressed", grepl("income <numeric>: missing <10", p))
check("profile: min and max withheld", grepl("min and max withheld", p) &&
        !grepl(format(max(toy$income, na.rm = TRUE)), p, fixed = TRUE))
check("profile: labelled as categories", grepl("Agree 30 \\(50%\\)", p) &&
        grepl("Refused <10", p))

check("suppress_counts: primary and secondary",
      identical(core$suppress_counts(c(3, 25, 32), 10), c("<10", "suppressed", "32")))
check("suppress_counts: two small cells need no secondary",
      identical(core$suppress_counts(c(3, 4, 32), 10), c("<10", "<10", "32")))
check("suppress_counts: zeros shown", identical(core$suppress_counts(c(0, 30), 10), c("0", "30")))

e = core$env_summary()
check("env_summary lists toy", grepl("- toy <data.frame> 60 x 7", e, fixed = TRUE))

# ---- palmerpenguins and survey designs ---------------------------------------
if (requireNamespace("palmerpenguins", quietly = TRUE)) {
  pg = core$describe_value(palmerpenguins::penguins, "penguins")
  check("penguins described", grepl("species <factor>.*Adelie", pg) &&
          !grepl("39.1", pg, fixed = TRUE))
}
if (requireNamespace("survey", quietly = TRUE)) {
  data(api, package = "survey", envir = environment())
  des = survey::svydesign(ids = ~dnum, weights = ~pw, fpc = ~fpc, data = apiclus1)
  dd = core$describe_value(des, "des")
  check("design described with PSU count", grepl("15 PSUs", dd) && grepl("svydesign", dd))
  sdes = survey::svydesign(ids = ~1, strata = ~stype, weights = ~pw, fpc = ~fpc, data = apistrat)
  check("stratified design: strata counted",
        grepl("3 strata", core$describe_value(sdes, "sdes")))
  rdes = survey::as.svrepdesign(des, type = "JK1")
  check("replicate design described", grepl("15 replicates",
                                            core$describe_value(rdes, "rdes")))
  check("design profile says unweighted", grepl("unweighted",
                                               core$profile_value(des, "des")))
}

# ---- scrubbing --------------------------------------------------------------
s = core$scrub_text(c('key <- "sk-ant-api03-abcdefghijklmnop"',
                      'Authorization: Bearer abc.def.ghijk',
                      'api_key = "hunter2"',
                      'read_csv("D:/projects/secret/data.csv")',
                      'path.expand("~/work/x.R")',
                      'contact jane.doe@example.org'))
check("scrub: keys", !grepl("abcdefghijklmnop|hunter2|abc.def", s))
check("scrub: paths and email", !grepl("D:/projects|~/work|jane.doe", s) &&
        grepl("<path>", s) && grepl("<email>", s))
check("scrub: paths kept when asked", grepl("D:/projects",
                                            core$scrub_text("x <- 'D:/projects/a.R'", paths = FALSE)))

src = core$get_function_source_tool("core_test_fn_missing")
check("function source: missing reported", grepl("No function", src))
assign("my_fn", function(x) { key = "sk-ant-zzzzzzzzzzzzzz"; x + 1 }, envir = globalenv())
check("function source: scrubbed", !grepl("zzzzzz", core$get_function_source_tool("my_fn")))
check("function source: package function", grepl("function",
                                                 core$get_function_source_tool("purrr::map")))

# ---- files ------------------------------------------------------------------
proj = file.path(tempdir(), "intern_proj")
dir.create(proj, showWarnings = FALSE)
outside = file.path(tempdir(), "intern_outside")
dir.create(outside, showWarnings = FALSE)
old_wd = setwd(proj)
writeLines("x <- 1", "a.R")
writeLines("a,b", "d.csv")
writeLines("SECRET=1", ".Renviron")
writeLines("y <- 2", file.path(outside, "b.R"))

fails = function(expr) inherits(tryCatch(expr, error = function(e) e), "error")
check("read inside allow_dirs", grepl("x <- 1", core$read_file_tool("a.R")))
check("read outside refused", fails(core$read_file_tool(file.path(outside, "b.R"))))
check("traversal refused", fails(core$read_file_tool("../intern_outside/b.R")))
check("data file refused", fails(core$read_file_tool("d.csv")))
check(".Renviron refused", fails(core$read_file_tool(".Renviron")))
check("list_files", grepl("a.R", core$list_files_tool()))

options(intern.auto_approve = "Write it")
invisible(utils::capture.output(w <- core$write_file_tool("new.R", "z <- 3\nz")))
check("write after approval", file.exists("new.R") && identical(readLines("new.R"), c("z <- 3", "z")))
check("write refuses placeholders", grepl("Not written",
                                          core$write_file_tool("a.R", "read_csv('<path>')")))
options(intern.auto_approve = NULL)
invisible(utils::capture.output(w2 <- core$write_file_tool("other.R", "q <- 1")))
check("write refused without approval",
      grepl("chose not to write", w2) && !file.exists("other.R"))
check("write outside refused", fails(core$write_file_tool(file.path(outside, "c.R"), "1")))

# ---- run_code ---------------------------------------------------------------
options(intern.auto_approve = "Run")
invisible(utils::capture.output(r <- core$run_code_tool("made <- head(toy, 5); print(made$name)")))
check("run_code: ran and reported new object",
      grepl("Ran without error", r) && grepl("Created: made <data.frame> 5 x 7", r, fixed = TRUE))
check("run_code: output not shared", !grepl("Alice", r) && grepl("not shared", r))
invisible(utils::capture.output(r2 <- core$run_code_tool("stop('boom')")))
check("run_code: error reported", grepl("Error: boom", r2))
options(intern.auto_approve = "Run and share the output with inteRn")
invisible(utils::capture.output(r3 <- core$run_code_tool("nrow(toy)")))
check("run_code: shared output when chosen", grepl("\\[1\\] 60", r3))
options(intern.auto_approve = NULL)
invisible(utils::capture.output(r4 <- core$run_code_tool("bad <- 1")))
check("run_code: refused without approval", grepl("chose not to run", r4) &&
        !exists("bad", envir = globalenv()))
check("run_code: parse error returned", grepl("does not parse", core$run_code_tool("x <- (")))

# ---- approvals through the Viewer (fake socket, no server) -------------------
sent_ws = new.env(); sent_ws$msgs = list()
fake_ws = list(send = function(x) sent_ws$msgs = c(sent_ws$msgs, list(jsonlite::fromJSON(x))))
core$.state$ws = fake_ws
core$.state$channel = "viewer"
core$.state$pending = list()
p = core$run_code_tool("viewer_made <- 1:3")
check("viewer: tool returns a promise", promises::is.promise(p))
appr = Filter(function(m) identical(m$type, "approval"), sent_ws$msgs)
check("viewer: approval sent with the code", length(appr) == 1L &&
        identical(appr[[1]]$detail, "viewer_made <- 1:3") && length(appr[[1]]$choices) == 3L)
check("viewer: nothing ran before the answer", !exists("viewer_made", envir = globalenv()))
res_v = new.env()
promises::then(p, function(v) res_v$value = v)
invisible(utils::capture.output({
  core$viewer_answer(appr[[1]]$id, "Run")
  purrr::walk(1:5, function(i) later::run_now(0.05))
}))
check("viewer: ran after approval", exists("viewer_made", envir = globalenv()) &&
        grepl("Created: viewer_made", res_v$value))
check("viewer: output sent to the page only",
      any(purrr::map_lgl(sent_ws$msgs, function(m) identical(m$type, "output"))) &&
        grepl("not shared", res_v$value))
p2 = core$run_code_tool("never_made <- 1")
res_v$value2 = NULL
promises::then(p2, function(v) res_v$value2 = v)
core$refuse_pending()          # as when the page is closed mid-question
purrr::walk(1:5, function(i) later::run_now(0.05))
check("viewer: closing the page refuses", grepl("chose not to run", res_v$value2) &&
        !exists("never_made", envir = globalenv()))
p3 = core$run_code_tool("forged <- 1")
appr3 = Filter(function(m) identical(m$type, "approval"), sent_ws$msgs)
promises::then(p3, function(v) res_v$value3 = v)
core$viewer_answer(appr3[[length(appr3)]]$id, "Yes please")   # not one of the choices
purrr::walk(1:5, function(i) later::run_now(0.05))
check("viewer: unknown answer refuses", grepl("chose not to run", res_v$value3) &&
        !exists("forged", envir = globalenv()))
core$.state$ws = NULL
core$.state$channel = NULL
setwd(old_wd)

# ---- rendering replies safely ---------------------------------------------------
h = core$render_reply(paste(
  "**Hi** <script>alert(1)</script> [bad](javascript:alert(1)) [ok](https://x.org)",
  "<img src=x onerror=alert(1)> <p onclick=\"x()\">p</p>", "", "```r", "x <- 1", "```",
  sep = "\n"))
check("render: no script, handlers or js links",
      !grepl("<script|<img|<[^>]* on[a-z]+=|href=\"javascript", h))
check("render: markdown kept", grepl("<strong>Hi</strong>", h) &&
        grepl("<code class=\"language-r\">x &lt;- 1", h, fixed = TRUE) &&
        grepl("href=\"https://x.org\"", h, fixed = TRUE))
check("token parsed from query", identical(core$query_token("?t=abc123"), "abc123") &&
        identical(core$query_token("?x=1"), ""))

# ---- tools and chat object (no API call) -------------------------------------
tl = core$intern_tools()
check("9 tools defined", length(tl) == 9L)
check("system prompt read without comments",
      !grepl("<!--", core$intern_system_prompt()) &&
        grepl("never see data values", core$intern_system_prompt()))
Sys.setenv(ANTHROPIC_API_KEY = "sk-ant-not-a-real-key-for-tests")
ch = core$intern_new_chat()
check("chat object built with tools", length(ch$get_tools()) == 9L &&
        identical(ch$get_model(), core$INTERN_LLM$pm))
Sys.unsetenv("ANTHROPIC_API_KEY")

# ---- %ask% sends structure only (intern_send replaced, no API) ---------------
sent = new.env()
assign("intern_send", function(prompt, ...) { sent$prompt = prompt; "stub reply" }, envir = core)
invisible(utils::capture.output(rep <- toy %ask% "Which variables need recoding?"))
check("%ask% sends structure", grepl("`toy`", sent$prompt) && grepl("agree <labelled double>", sent$prompt))
check("%ask% sends no values", !grepl("Alice|person_", sent$prompt))
check("%ask% returns an intern_reply", inherits(rep, "intern_reply"))
invisible(utils::capture.output(ask("hello")))
check("ask() passes the question", identical(sent$prompt, "hello"))
if (requireNamespace("palmerpenguins", quietly = TRUE)) {
  invisible(utils::capture.output(palmerpenguins::penguins %ask% "Missing values?"))
  check("%ask% on an expression: tools can profile it by its label",
        grepl("Profile of `palmerpenguins::penguins`",
              core$profile_object("palmerpenguins::penguins")) &&
          !exists("palmerpenguins::penguins", envir = globalenv()))
  invisible(utils::capture.output(intern_reset()))
  check("intern_reset() forgets pinned objects",
        grepl("no object", core$profile_object("palmerpenguins::penguins")))
}

# ---- lint gate (stand-in model) -------------------------------------------------
if (requireNamespace("lintr", quietly = TRUE)) {
  fence = function(code) paste0("```r\n", code, "\n```")
  bad = paste("Here you go:", fence(paste(
    "for (i in 1:3) print(i)",
    "plot(mtcars$mpg)",
    "cols <- rainbow(3)",
    "ggplot2::scale_fill_manual(values = c('#FF0000', '#E69F00'))",
    "x == NA", sep = "\n")), sep = "\n\n")
  lp = core$lint_reply(bad)
  check("lint: loop, base plot, rainbow, unsafe hex and == NA caught",
        any(grepl("loops", lp$message)) && any(grepl("base graphics", lp$message)) &&
          sum(grepl("colourblind|Okabe", lp$message)) == 2L && any(grepl("NA", lp$message)))
  good_code = paste("library(ggplot2)",
                    "purrr::map_dbl(1:3, \\(i) i^2)",
                    "ggplot(mtcars, aes(wt, mpg, colour = factor(cyl))) +",
                    "  geom_point() +",
                    "  scale_colour_manual(values = c('#0072B2', '#D55E00', '#440154')) +",
                    "  labs(x = 'Weight', y = \"variable\", title = 'red')", sep = "\n")
  check("lint: tidy code with Okabe-Ito and viridis colours passes",
        nrow(core$lint_reply(fence(good_code))) == 0L)
  check("lint: unparseable code is caught", nrow(core$lint_reply(fence("x <- ("))) > 0L)
  check("lint: no code, no problems", nrow(core$lint_reply("Just prose.")) == 0L)
  check("lint: a block marked BAD EXAMPLE is left alone",
        nrow(core$lint_reply(fence("# BAD EXAMPLE: do not use
for (i in 1:3) print(i)"))) == 0L &&
          !grepl("UNTESTED", core$mark_untested(fence("# BAD EXAMPLE
for (i in 1:3) print(i)"))))
  check("lint: # nolint does not switch the gate off",
        nrow(core$lint_reply(fence("for (i in 1:3) print(i) # nolint"))) > 0L)
  check("lint: ordinary strings are not treated as colours",
        nrow(core$lint_reply(fence("x <- c('variable', 'VARIABLE', '#12', 'red')"))) == 0L)
  real_lint_reply = core$lint_reply
  assign("lint_reply", function(text) stop("boom"), envir = core)
  check("gate: a failing linter keeps the reply",
        identical(suppressMessages(core$lint_gate(bad, list(get_turns = function() list()),
                                                  function(p) "x", 0L)), bad))
  assign("lint_reply", real_lint_reply, envir = core)

  check("lint: an empty reply is not an error",
        nrow(core$lint_reply(character(0))) == 0L && nrow(core$lint_reply("")) == 0L &&
          identical(core$lint_gate("", list(get_turns = function() list()), function(p) "x", 0L), ""))
  fake_chat = list(get_turns = function() list())
  sends = new.env(); sends$n = 0L; sends$last = NULL
  fixer = function(p) { sends$n = sends$n + 1L; sends$last = p; paste("Fixed:", fence(good_code)) }
  out = core$lint_gate(bad, fake_chat, fixer, n_before = 0L)
  check("gate: one rewrite requested with the problems listed",
        sends$n == 1L && grepl("did not pass the lint gate", sends$last) && grepl("loops", sends$last))
  check("gate: clean rewrite returned and marked UNTESTED",
        startsWith(out, "Fixed:") && grepl("```r\n# UNTESTED\nlibrary(ggplot2)", out, fixed = TRUE))
  sends$n = 0L
  stubborn = function(p) { sends$n = sends$n + 1L; bad }
  out2 = core$lint_gate(bad, fake_chat, stubborn, n_before = 0L)
  check("gate: at most two rewrites, then problems shown",
        sends$n == 2L && grepl("Lint gate:", out2) && grepl("after 2 rewrites", out2))
  out3 = core$lint_gate(bad, fake_chat, function(p) NULL, n_before = 0L)
  check("gate: a failed rewrite keeps the reply and shows the problems",
        grepl("Here you go", out3) && grepl("Lint gate:", out3))
  check("untested marker not added to code that was run",
        !grepl("UNTESTED", core$mark_untested(fence("x <- 1"), ran = "x <- 1")) &&
          grepl("UNTESTED", core$mark_untested(fence("x <- 2"), ran = "x <- 1")))
  check("untested marker not doubled",
        lengths(regmatches(core$mark_untested(fence("# UNTESTED\nx <- 1")),
                           gregexpr("UNTESTED", core$mark_untested(fence("# UNTESTED\nx <- 1"))))) == 1L)
  cfg_off = core$INTERN_LLM; cfg_off$lint = FALSE
  assign("INTERN_LLM", cfg_off, envir = core)
  check("gate off: reply untouched", identical(core$lint_gate(bad, fake_chat, fixer, 0L), bad))
  cfg_off$lint = TRUE; assign("INTERN_LLM", cfg_off, envir = core)
}

# ---- empty replies (stand-in model) ------------------------------------------------
no_stop = list(last_turn = function() NULL)
nudges = new.env(); nudges$n = 0L
answer = function(p) { nudges$n = nudges$n + 1L; nudges$p = p; "Here is the answer." }
check("empty reply: model asked once to write its answer",
      identical(core$fill_empty_reply("", no_stop, answer), "Here is the answer.") &&
        nudges$n == 1L && grepl("without writing an answer", nudges$p))
check("empty reply twice: a note instead of a blank",
      grepl("empty reply", core$fill_empty_reply(character(0), no_stop, function(p) "")))
check("a real reply is passed through untouched",
      identical(core$fill_empty_reply("Fine.", no_stop, function(p) stop("not called")), "Fine."))
av = new.env()
promises::then(core$fill_empty_reply_async("", no_stop, function(p) promises::promise_resolve("Async answer.")),
               function(v) av$v = v)
purrr::walk(1:5, function(i) later::run_now(0.05))
check("empty reply, async: model asked to write its answer", identical(av$v, "Async answer."))

# ---- the async path the Viewer uses, end to end (stand-in chat) ----------------------
fake_async_chat = list(get_turns = function() list(), set_turns = function(x) NULL,
                       last_turn = function() NULL, get_model = function() "stand-in",
                       chat_async = function(p, tool_mode) promises::promise_resolve("The real answer."))
asv = new.env()
promises::then(core$intern_send_async("Help me explore my data", fake_async_chat),
               function(v) asv$v = v)
purrr::walk(1:10, function(i) later::run_now(0.05))
check("async path returns the model's text (not empty)", identical(asv$v, "The real answer."))

# ---- the Viewer leaves the random stream alone and its token is unpredictable --------
set.seed(42); expected = runif(1)
set.seed(42); u1 = open_intern(launch = FALSE); got = runif(1)
check("open_intern() does not change the user's random numbers", identical(expected, got))
close_intern()
set.seed(42); u2 = open_intern(launch = FALSE); close_intern()
check("the Viewer token differs even after the same set.seed()",
      !identical(sub(".*t=", "", u1), sub(".*t=", "", u2)) && nchar(sub(".*t=", "", u1)) == 32L)

# ---- reflexes (in a temporary skills folder) ---------------------------------------
tmp_skills = file.path(tempdir(), "skills_tmp")
dir.create(tmp_skills, showWarnings = FALSE)
cfg_r = core$INTERN_LLM; real_skills = cfg_r$skills_dir; cfg_r$skills_dir = tmp_skills
assign("INTERN_LLM", cfg_r, envir = core)
sent$prompt = "untouched"
invisible(utils::capture.output(r_out <- ask("/reflex add Weights are not frequency counts; key = \"sk-ant-zzzzzzzzzzzz\"")))
rf = readLines(file.path(tmp_skills, "reflexes.md"))
check("/reflex add appends a dated line, scrubbed", any(grepl(paste0("^- ", Sys.Date(), ": Weights are not"), rf)) &&
        !any(grepl("zzzzzz", rf)) && grepl("# Reflexes", rf[1]))
check("/reflex add is not sent to the model", identical(sent$prompt, "untouched"))
core$reflex_add("Second lesson.")
check("reflexes append in order", grepl("Second lesson", utils::tail(readLines(file.path(tmp_skills, "reflexes.md")), 1)))
check("reflexes go into the system prompt", grepl("Lessons learned", core$intern_system_prompt()) &&
        grepl("Second lesson", core$intern_system_prompt()))
check("/reflex list and /help answered locally",
      grepl("Second lesson", core$slash_command("/reflex list")) &&
        grepl("Commands", core$slash_command("/help")) &&
        grepl("Unknown command", core$slash_command("/nope")) &&
        is.null(core$slash_command("not a command")))
cfg_r$skills_dir = real_skills; assign("INTERN_LLM", cfg_r, envir = core)

cat("\n", results$n - length(results$fail), " of ", results$n, " checks passed\n", sep = "")
if (length(results$fail)) quit(status = 1)
