# viewer_demo.R -- the Viewer page with a stand-in model, for checking the UI
#   without a key or any API call. Every question gets the same scripted turn:
#   a run_code call that needs approval, then a markdown reply.
#
#   Rscript --no-init-file inteRn/tests/viewer_demo.R [minutes]
#
# Prints the URL; open it in a browser. Serves for `minutes` (default 10).

here = local({
  a = commandArgs(FALSE)
  f = sub("^--file=", "", a[grepl("^--file=", a)])
  if (length(f)) dirname(normalizePath(f)) else getwd()
})
Sys.setenv(INTERN_HOME = normalizePath(file.path(here, ".."), winslash = "/"))
options(intern.quiet = TRUE)
source(file.path(Sys.getenv("INTERN_HOME"), "inteRn.R"))
core = environment(open_intern)

assign("intern_get_chat", function() core$.state, envir = core)   # no key needed
assign("intern_send_async", function(prompt, chat) {
  core$viewer_send(list(type = "tool", text = "describe_object(name = mtcars)"))
  promises::promise_resolve(NULL) |>
    promises::then(function(x)
      core$run_code_tool("demo_obj <- head(mtcars, 3)\nprint(demo_obj)")) |>
    promises::then(function(r) paste0(
      "You asked: *", prompt, "*\n\nThe tool said:\n\n> ", gsub("\n", "\n> ", r),
      "\n\nCounting cylinders with **dplyr**:\n\n```r\n# UNTESTED\nmtcars |>\n  dplyr::count(cyl)\n```\n\n",
      "| cyl | meaning |\n|---:|---|\n| 4 | small |\n| 8 | large |\n\n",
      "<img src=x onerror=alert(1)> should show as text."))
}, envir = core)

url = open_intern(launch = FALSE)
writeLines(url, file.path(tempdir(), "intern_demo_url.txt"))
cat("inteRn demo at", url, "\n")
flush(stdout())
mins = suppressWarnings(as.numeric(commandArgs(TRUE)[1]))
if (is.na(mins)) mins = 10
purrr::walk(seq_len(ceiling(mins * 60 / 0.2)), function(i) later::run_now(0.2))
close_intern()
