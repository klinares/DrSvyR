# ask.R -- asking from the console: ask() and the %ask% pipe.
# Function definitions only.

# Exported. One question in the session's ongoing conversation. Blocks the
#   console while the model replies; tools it calls run here and ask for
#   approval in the console. new = TRUE starts a fresh conversation first.
ask <- function(prompt, new = FALSE) {
  if (!is_string(prompt)) stop("ask() takes one question as a string.", call. = FALSE)
  # /reflex add ..., /help: handled here, never sent to the model.
  sc = slash_command(prompt)
  if (!is.null(sc)) {
    cat(sc, "\n", sep = "")
    return(invisible(sc))
  }
  if (isTRUE(.state$busy))
    stop("inteRn is still answering in the Viewer; wait for it to finish.", call. = FALSE)
  if (isTRUE(new)) intern_reset()
  .state$channel = "console"
  on.exit(.state$channel <- NULL, add = TRUE)
  reply = intern_send(prompt)
  if (is.null(reply)) return(invisible(NULL))
  out = structure(reply, class = "intern_reply")
  print(out)
  invisible(out)
}

# Exported. obj %ask% "question" sends the object's structure (never its
#   values) with the question. %ask% binds tighter than |>, so put a pipeline
#   in parentheses: (df |> filter(x > 1)) %ask% "...".
`%ask%` <- function(x, prompt) {
  label = paste(deparse(substitute(x), width.cutoff = 60L), collapse = " ")
  if (nchar(label) > 80L) label = paste0(substr(label, 1, 77), "...")
  # Not a workspace object (a pkg::data reference, a pipeline): keep the
  #   value for this conversation, so describe_object and profile_object can
  #   reach it by its label instead of the model guessing.
  if (!exists(label, envir = globalenv(), inherits = FALSE))
    .state$pinned[[label]] = x
  meta = describe_value(x, label)
  ask(paste0("This question is about `", label, "`. Its structure (no values):\n\n",
             meta, "\n\nThe tools describe_object and profile_object accept the name `",
             label, "`.\n\nQuestion: ", prompt))
}

print.intern_reply <- function(x, ...) {
  cat("\n", unclass(x), "\n\n", sep = "")
  invisible(x)
}
