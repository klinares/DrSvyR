# Cheapest possible check that the app is still syntactically whole. Runs in
#   under a second, needs nothing installed, and is the right thing to run
#   after any edit before spending two minutes on the full pipeline.
files <- c(list.files("R", full.names = TRUE, pattern = "[.][Rr]$"),
           "app.R", "setup.R")

bad <- Filter(function(f) inherits(try(parse(f), silent = TRUE), "try-error"),
              files)

if (length(bad)) {
  for (f in bad) {
    e <- try(parse(f), silent = TRUE)
    cat("PARSE FAIL", f, ":", conditionMessage(attr(e, "condition")), "\n")
  }
  quit(status = 1)
}
cat("all", length(files), "files parse\n")
