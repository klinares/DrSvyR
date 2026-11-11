# Smoke test for QuestionR. No API calls. Not deployed (tests/ is in .rscignore).
# Run from inside QuestionR/, without the user profile so it is closer to Connect:
#   Rscript --no-init-file tests/smoke.R
# Each check prints "ok" or stops the script with "FAIL" and the check's name.

stopifnot("Run from inside QuestionR/" = file.exists("DESIGN.md"))

ok <- function(what, cond) {
  if (!isTRUE(cond)) stop("FAIL: ", what, call. = FALSE)
  cat("ok  ", what, "\n", sep = "")
}

# Run R code in a fresh process, with QUESTIONR_PROFILE set inside it, and
#   return what it printed and how it ended. A fresh process because the
#   profile is read once, when app.R is sourced.
rscript <- file.path(R.home("bin"), "Rscript")
in_child <- function(profile, code) {
  f = tempfile(fileext = ".R")
  on.exit(unlink(f))
  writeLines(c(sprintf("Sys.setenv(QUESTIONR_PROFILE = '%s')", profile), code), f)
  out = suppressWarnings(system2(rscript, c("--no-init-file", shQuote(f)),
                                 stdout = TRUE, stderr = TRUE))
  list(out = paste(out, collapse = "\n"), status = attr(out, "status") %||% 0L)
}


# ---- Phase 0: the app loads, and its parts are in place --------------------

# Loaded the way Connect loads it. source("app.R") would hide an object that
#   R/ cannot see, because it evaluates in the global environment.
app <- shiny::shinyAppDir(".")
ok("shinyAppDir() returns a shiny.appobj", inherits(app, "shiny.appobj"))
ok("app.R sources without error", is.function(app$serverFuncSource()))

ok("the settings R/ reads are in the global environment",
   all(c("APP_CLASSIFICATION", "APP_PROFILE", "APP_MODELS", "APP_MAX_PASTE_CHARS") %in%
         ls(globalenv())))
ok("the Cairo bitmap type is set", identical(getOption("bitmapType"), "cairo"))

# The page, as the browser would get it.
page <- local({
  req = list(REQUEST_METHOD = "GET", PATH_INFO = "/", QUERY_STRING = "",
             SCRIPT_NAME = "", SERVER_NAME = "localhost", SERVER_PORT = "80",
             HTTP_HOST = "localhost", HTTP_ACCEPT_ENCODING = "",
             rook.url_scheme = "http")
  resp = app$httpHandler(req)
  list(status = resp$status,
       html = if (is.character(resp$content)) resp$content
              else paste(readLines(resp$content$file, warn = FALSE), collapse = "\n"))
})
has <- function(s) grepl(s, page$html, fixed = TRUE)

ok("the page is served", isTRUE(page$status == 200))
ok("the classification banner shows", has(APP_CLASSIFICATION))
# APP_LOGO is app.R's own setting and is not in the global environment, so the
#   default file name is written out here.
logo_file <- "office_logo.png"
ok("the logo shows, or its placeholder box does",
   if (file.exists(file.path("www", "logo", logo_file))) has(file.path("logo", logo_file))
   else has("Office logo"))
ok("every tab is in the navlist", all(purrr::map_lgl(QUESTIONR_TABS, has)))
ok("the key box is on Start here", has("Use this key") && has("type=\"password\""))
ok("the not-yet-built tabs say so",
   lengths(regmatches(page$html, gregexpr("Not built yet", page$html, fixed = TRUE))) ==
     length(QUESTIONR_TABS) - 1L)

# The profile block. Each profile in its own process.
home <- in_child("home", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
  "cat('PM=', APP_MODELS$pm$id, ' KEY=', APP_MODELS$pm$key_source,",
  "    ' WORKERS=', length(APP_MODELS$workers), sep = '')"))
ok("home profile: PM on a pasted key, three workers",
   home$status == 0 && grepl("PM=claude-sonnet-5-5 KEY=analyst WORKERS=3", home$out, fixed = TRUE))

work <- in_child("work", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())",
  "cat('PROFILE=', APP_PROFILE, ' WORKERS=', length(APP_MODELS$workers), sep = '')"))
ok("work profile loads", work$status == 0 && grepl("PROFILE=work WORKERS=1", work$out, fixed = TRUE))

bogus <- in_child("nonsense", c(
  "app <- shiny::shinyAppDir('.'); invisible(app$serverFuncSource())"))
ok("an unknown profile stops the app and names the choices",
   bogus$status != 0 && grepl("must be one of: home, work", bogus$out, fixed = TRUE))

# The key box. A key is held for the session, never put in the environment, and
#   forgotten on request.
key_state <- shiny::reactiveValues(key_version = 0L)
shiny::testServer(mod_key_server, args = list(state = key_state), {
  ok("no key is held before one is pasted", is.null(llm_session_key()))
  session$setInputs(key = "  smoke-test-key  ", save = 1)
  ok("a pasted key is held for the session, trimmed", identical(llm_session_key(), "smoke-test-key"))
  ok("the key is not in the environment", !any(Sys.getenv() == "smoke-test-key"))
  ok("saving the key bumps key_version", shiny::isolate(key_state$key_version) == 1L)
  session$setInputs(clear = 1)
  ok("a forgotten key is gone", is.null(llm_session_key()))
})
