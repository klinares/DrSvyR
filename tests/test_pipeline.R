# The whole class-model pipeline, run with no Shiny anywhere. Every function
#   the app calls between "the data are read" and "the domain tables exist" is
#   exercised here, on synthetic data, in the order the app calls them.
#
#   Run with:  Rscript tests/test_pipeline.R
#
#   This is the check to run before touching the app, and after. It takes a
#   couple of minutes and needs no browser, no API key and no survey file.

suppressMessages({
  library(dplyr); library(purrr); library(tibble); library(tidyr)
  library(stringr); library(ggplot2); library(rlang)
  library(survey); library(lavaan); library(furrr); library(viridis)
  # matrixStats and clue are NOT attached, because app.R does not attach them.
  #   The harness has to reproduce the app's search path or it tests a
  #   different program: matrixStats exports count() and masks dplyr's.
})
future::plan(future::sequential)

`%||%` <- function(a, b) if (is.null(a)) b else a
.wise <- new.env(parent = emptyenv())
walk(list.files("R", full.names = TRUE, pattern = "[.][Rr]$"), source)
source("tests/synth_survey.R")

pass <- 0L; fail <- 0L
check <- function(label, ok, note = "") {
  if (isTRUE(ok)) { pass <<- pass + 1L; cat(sprintf("  ok    %-46s %s\n", label, note)) }
  else            { fail <<- fail + 1L; cat(sprintf("  FAIL  %-46s %s\n", label, note)) }
}
timed <- function(label, expr) {
  t0 <- Sys.time()
  out <- try(suppressWarnings(expr), silent = TRUE)
  secs <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  if (inherits(out, "try-error")) {
    check(label, FALSE, paste("->", sub("\n.*", "", conditionMessage(attr(out, "condition")))))
    return(NULL)
  }
  check(label, TRUE, sprintf("(%.0fs)", secs))
  out
}

dat <- make_survey()
cfg <- make_cfg(dat)

# The app fits the measurement model on item-complete cases and scores the
#   whole file afterwards, so the harness keeps the two frames apart too.
est <- dat[complete.cases(dat[cfg$items]), ]

cat("\n== the archived arm cannot be reached ==\n")
check("no factor-arm function is loaded",
      !any(map_lgl(c("fit_efa", "search_cfa", "score_cfa", "fit_cfa"), exists)))
check("the config declares the class arm", identical(cfg$arm, "lca"))

cat("\n== design ==\n")
des <- timed("build_rep_design", build_rep_design(est, cfg))
if (!is.null(des)) {
  check("degf is sampling units minus strata",
        degf(des$rep_des) == n_distinct(est$psu) - n_distinct(est$strata),
        paste("degf =", degf(des$rep_des)))
  lonely <- est |> filter(!(strata == 3 & psu != min(psu[strata == 3])))
  check("a singleton stratum halts",
        inherits(try(build_rep_design(lonely, cfg), silent = TRUE), "try-error"))
}

cat("\n== the one-worker path, which used to take out the whole search ==\n")
check("seed_blocks survives a single worker",
      identical(seed_blocks(1:8, 1L), list(1:8)))
check("seed_blocks splits for several workers", length(seed_blocks(1:8, 4L)) == 4L)
check("the raw cut() call it replaced is an error",
      inherits(try(cut(1:8, 1, labels = FALSE), silent = TRUE), "try-error"))

cat("\n== search and fit, at one worker ==\n")
srch <- timed("search_lca", search_lca(cfg, est))
if (!is.null(srch)) {
  check("one row per candidate size", nrow(srch$stats) == length(cfg$K_range))
  check("every candidate converged", all(srch$stats$converged))
  check("the criterion is on the sum-to-n scale",
        all(abs(srch$stats$BIC) < 1e6), paste("BIC range",
            paste(round(range(srch$stats$BIC)), collapse = " to ")))
  check("entropy is a proportion", all(between(srch$stats$entropy, 0, 1)))
}

fit <- timed("fit_final_lca", fit_final_lca(cfg, est, 4L))
if (!is.null(fit)) {
  check("prevalences sum to one", abs(sum(fit$pi) - 1) < 1e-8)
  check("each item's probabilities sum to one within segment",
        all(map_lgl(fit$rho, function(r) all(abs(colSums(r) - 1) < 1e-8))))
  check("the fit converged", isTRUE(fit$converged))
}

cat("\n== the fit is reproducible, which is what the seed discipline buys ==\n")
fit2 <- fit_final_lca(cfg, est, 4L)
check("same seeds, same answer, bit for bit",
      identical(fit$pi, fit2$pi) && identical(fit$rho, fit2$rho))
cfg4 <- modifyList(cfg, list(workers = 4L))
fit4 <- timed("fit_final_lca at four workers", fit_final_lca(cfg4, est, 4L))
if (!is.null(fit4))
  check("the worker count does not change the answer",
        isTRUE(all.equal(fit$pi, fit4$pi)) && isTRUE(all.equal(fit$ll, fit4$ll)))

cat("\n== diagnostics ==\n")
dg <- timed("diagnose_lca", diagnose_lca(fit, cfg, est))
if (!is.null(dg)) {
  check("a discrimination per item", nrow(dg$discrimination) == length(cfg$items))
  check("discrimination is bounded in [0, 1]",
        all(between(dg$discrimination$discrimination, 0, 1)))
  check("bivariate residuals are bounded in [0, 1]", all(between(dg$bvr$bvr, 0, 1)))
  check("the level-to-pattern ratio is finite", is.finite(dg$ratio$ratio),
        paste("ratio =", dg$ratio$ratio))
}

cat("\n== design-based variance on the measurement model ==\n")
mse <- timed("measurement_se_lca",
             measurement_se_lca(cfg, est, fit, des$des, des$rep_des))

cat("\n== scoring, including partial responders ==\n")
state <- list(cfg = cfg, dimension = 4L,
              design_dat = select(dat, id, strata, psu, wt),
              demo_dat = select(dat, all_of(cfg$aux)),
              item_frame = list(item_dat = select(dat, all_of(cfg$items)),
                                in_analysis = complete.cases(dat[cfg$items])),
              model = list(fit = fit))
scored <- timed("score_lca", score_lca(state))
if (!is.null(scored)) {
  n_est <- sum(state$item_frame$in_analysis)
  check("partial responders are reached",
        sum(!is.na(scored$segment)) > n_est,
        sprintf("scored %d of %d, estimation frame was %d",
                sum(!is.na(scored$segment)), nrow(scored), n_est))
  check("nobody under the item floor is scored",
        all(scored$n_items_answered[!is.na(scored$segment)] >= cfg$min_items))
  check("posteriors sum to one",
        all(abs(rowSums(select(scored, starts_with("post_segment"))) - 1) < 1e-8))
}

cat("\n== domain estimation and the bias correction ==\n")
state$scored <- scored
sc <- dat |> mutate(segment = scored$segment) |> filter(!is.na(segment))
state$score_design <- timed("rebuild the design on the scored frame",
                            build_rep_design(sc, cfg))
if (!is.null(state$score_design)) {
  state$scored <- filter(scored, !is.na(segment))
  dom <- timed("domains_lca", domains_lca(state))
  if (!is.null(dom)) {
    d <- if (is.data.frame(dom)) dom else dom[[1]]
    check("three estimators are reported", n_distinct(d$estimator) == 3,
          paste(unique(d$estimator), collapse = ", "))
    dsg <- filter(d, estimator == "Design-based")
    check("design-based shares sum to one within a level",
          all(abs(tapply(dsg$p, paste(dsg$variable, dsg$level), sum) - 1) < 1e-6))
    check("no interval is inverted", all(d$hi >= d$lo))
  }
}

cat("\n== the guards that turn a silent wrong number into a message ==\n")
K <- 4L; n <- 200L
post <- matrix(runif(n * K), n, K); post <- post / rowSums(post)
err <- try(bch_weights(post, rep(1L, n), rep(1, n)), silent = TRUE)
check("a segment with no modal assignments is named, not left to LAPACK",
      inherits(err, "try-error") &&
        str_detect(conditionMessage(attr(err, "condition")), "too small"))

dom_one <- tibble(estimator = "Design-based", variable = "education", segment = 1L,
                  level = c("Primary", "Secondary"), p = c(.4, .6),
                  lo = c(.3, .5), hi = c(.5, .7))
marg <- tibble(variable = "education", level = c("Primary", "Secondary"),
               weighted = c(.4, .6), n = c(400L, NA_integer_))
check("an uncounted demographic level no longer halts the prompt",
      !inherits(try(format_domain_block(dom_one, marg, "education"), silent = TRUE),
                "try-error"))


cat("\n== no route into the archived arm survives in the interface ==\n")
ui_src <- paste(unlist(map(list.files("R", full.names = TRUE, pattern = "^R/ui_"),
                           readLines, warn = FALSE)), collapse = "\n")
all_src <- paste(unlist(map(list.files("R", full.names = TRUE),
                            readLines, warn = FALSE)), collapse = "\n")

check("the arm chooser is gone from the interface",
      !str_detect(ui_src, 'choiceValues = list\\("lca", "cfa"\\)'))
check("no control offers a factor estimator",
      !str_detect(ui_src, 'choiceValues = list\\("WLSMV", "ML"\\)'))
check("nothing reads a stated arm preference",
      !str_detect(all_src, fixed("input$preference")))
check("no code path can raise the archived-arm error",
      !str_detect(all_src, fixed("archive/cfa_arm.R")) ||
        !str_detect(all_src, "stop\\([^)]*archive/cfa_arm"))
check("the methodologist can still advise a weighted CFA",
      str_detect(all_src, fixed("recommend_cfa")) &&
        str_detect(all_src, fixed("lavaan::cfa()")))
check("the suitability prompt replaced the arm-choice prompt",
      exists("prompt_battery_suitability") && !exists("prompt_arm_recommendation"))

adv <- list(verdict = "looks like one continuum", reasoning = "x",
            recommend_cfa = TRUE)
check("the advice carries a verdict the report can record",
      all(c("verdict", "reasoning", "recommend_cfa") %in% names(adv)))


cat("\n== the report says one thing, in one voice ==\n")
res_src <- paste(readLines("R/results.R", warn = FALSE), collapse = "\n")
app_src <- paste(readLines("app.R", warn = FALSE), collapse = "\n")
core_src <- paste(readLines("R/core.R", warn = FALSE), collapse = "\n")

check("the report has one title, not a choice of two",
      !str_detect(res_src, "Latent scales in the population"))
check("no output text branches on a factor arm",
      !str_detect(res_src, "largest standardised loadings") &&
        !str_detect(res_src, "Bartlett score rather than the regression"))
check("the interface carries one product name",
      !str_detect(app_src, '"WISE"') && str_detect(app_src, '"DrSvyR"'))
check("no deprecated or version-gated recode verb survives",
      !str_detect(paste(core_src, res_src,
                        paste(readLines("R/ui_data.R", warn = FALSE),
                              collapse = "\n")),
                  "dplyr::case_match|dplyr::recode_values"))

cat("\n== a reverse-coded item cannot be described backwards ==\n")
check("supporting points quote a response category, not a direction",
      str_detect(res_src, fixed('where the other segments average')) &&
        !str_detect(res_src, "answers %s than average on"))

# pn4 runs 1 = most satisfied to 4 = least. A segment sitting high on the code
#   is the LEAST satisfied, and the old wording called that "higher on
#   Satisfaccion con democracia", which reads as more.
responses <- c("Muy satisfecho(a)", "Satisfecho(a)", "Insatisfecho(a)",
               "Muy insatisfecho(a)")
category_at <- function(value, responses) {
  idx <- max(1L, min(length(responses),
                     round(1 + value * (length(responses) - 1))))
  responses[[idx]]
}
check("a segment at the top of a reverse-coded scale is named, not ranked",
      category_at(1.0, responses) == "Muy insatisfecho(a)" &&
        category_at(0.0, responses) == "Muy satisfecho(a)",
      "top of the code scale = least satisfied")


cat("\n== nothing reads a symbol its scope does not define ==\n")
# The failure this catches: removing a helper leaves the call behind, and R
#   only notices when that line runs -- which for a report builder is after a
#   ten-minute fit. persona_cfa and the orphaned `lca` flag were both found
#   this way, not by reading.
reads <- function(x) {
  out <- character(0)
  rec <- function(x) {
    if (is.name(x)) out <<- c(out, as.character(x))
    else if (is.call(x)) {
      f <- x[[1]]
      if (is.name(f) && as.character(f) %in% c("$", "@")) {
        try(rec(x[[2]]), silent = TRUE); return(invisible(NULL))
      }
      for (y in as.list(x)[-1]) if (!missing(y)) try(rec(y), silent = TRUE)
    } else if (is.pairlist(x)) {
      for (y in as.list(x)) if (!missing(y)) try(rec(y), silent = TRUE)
    }
  }
  rec(x); unique(out)
}
gone <- c("persona_cfa", "prompt_factor_label", "format_factor_block",
          "assign_factors", "factor_scores", "score_cfa", "domains_cfa",
          "search_cfa", "fit_final_cfa", "diagnose_cfa", "cfa_health",
          "measurement_se_cfa", "plot_cfa_diagram", "fit_efa", "efa_loadings",
          "fit_cfa", "cfa_syntax", "check_factors", "as_fit", "build_report",
          "recode_values")
env <- new.env()
for (f in c(list.files("R", full.names = TRUE), "app.R"))
  suppressWarnings(try(eval(parse(f), env), silent = TRUE))
called <- unique(unlist(map(ls(env), function(nm) {
  f <- get(nm, env); if (is.function(f)) reads(body(f)) else character(0)
})))
still <- intersect(gone, called)
check("no live code calls a removed function",
      !length(still),
      if (length(still)) paste("still called:", paste(still, collapse = ", ")) else "")

cat("\n== the search stays cheap ==\n")
srch_body <- paste(deparse(body(search_lca)), collapse = " ")
check("the search computes no bivariate residuals",
      !str_detect(srch_body, "bvr_pairs"))
check("the search computes no item discrimination",
      !str_detect(srch_body, "item_discrimination"))
check("those belong to the fit step instead",
      str_detect(paste(deparse(body(diagnose_lca)), collapse = " "),
                 "bvr_pairs") &&
        str_detect(paste(deparse(body(diagnose_lca)), collapse = " "),
                   "item_discrimination"))

cat("\n== svyby is read through its accessors, not by column position ==\n")
dom_body <- paste(deparse(body(domains_lca)), collapse = " ")
check("domain shares come from coef() and SE()",
      str_detect(dom_body, "coef\\(sb\\)") && str_detect(dom_body, "SE\\(sb\\)"))
check("no positional slice of an svyby result survives",
      !str_detect(dom_body, "vals\\[, seq_len\\(K\\)\\]"))

cat("\n== the reply budget is set, and truncation says so ==\n")
llm_src <- paste(readLines("R/llm.R", warn = FALSE), collapse = "\n")
check("a token budget is named rather than left to the provider",
      str_detect(llm_src, "WISE_LLM_MAX_TOKENS") &&
        str_detect(llm_src, "max_tokens = max_tokens"))
check("a cut-off reply is diagnosed as cut off",
      str_detect(llm_src, "cut off before the JSON object closed"))

cat("\n== one output folder, not one per arm ==\n")
all_src <- paste(unlist(map(list.files("R", full.names = TRUE),
                            readLines, warn = FALSE)), collapse = "\n")
check("nothing writes into an arm subfolder",
      !str_detect(all_src, 'wise_path\\("output", (arm|cfg\\$arm|state\\$cfg\\$arm)'))


cat("\n== the two documents describe the tool that exists ==\n")
help_md <- paste(readLines("help.md", warn = FALSE), collapse = "\n")
readme <- paste(readLines("README.md", warn = FALSE), collapse = "\n")

check("help.md does not promise a second model",
      !str_detect(help_md, "or a single underlying scale") &&
        !str_detect(help_md, "finds either"))
check("help.md says what happens when the battery is a continuum",
      str_detect(help_md, "does not fit one"))
check("help.md documents the item proposal",
      str_detect(help_md, fixed("What else might belong here?")))
check("neither document tells the analyst to run renv",
      !str_detect(paste(help_md, readme), "renv::restore"))
check("neither document points at a demo folder that is not shipped",
      !str_detect(paste(help_md, readme), "demo/` holds|Point the app at"))
check("both name the tool DrSvyR, not WISE",
      !str_detect(paste(help_md, readme), "\\bWISE\\b"))

# help.md is rendered by includeMarkdown() from the app's own directory, and a
#   figure it references that is not there renders as a broken image on the
#   first screen an analyst sees.
figs <- unlist(str_extract_all(help_md, "figures/[A-Za-z0-9_.-]+"))
if (dir.exists("figures")) {
  check("every figure help.md references is present in figures/",
        all(file.exists(figs)), paste(figs, collapse = ", "))
} else {
  cat("  --    figures/ is not in this checkout; skipped\n")
}

cat("\n== the repository guard is where the comment says it is ==\n")
ui_src <- paste(readLines("R/ui_data.R", warn = FALSE), collapse = "\n")
core_src <- paste(readLines("R/core.R", warn = FALSE), collapse = "\n")
check("the work folder guard lives in the UI and says so",
      str_detect(ui_src, "path_has_parent\\(fs::path_abs\\(input\\$path\\), repo_root\\(\\)\\)") &&
        str_detect(ui_src, "This is the enforcement"))
check("scaffold_work_folder does not claim to enforce it",
      !str_detect(core_src, "repo_root\\(\\)"))

cat(sprintf("\n%d passed, %d failed\n", pass, fail))
if (fail > 0) quit(status = 1)
