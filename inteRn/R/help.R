# help.R -- the quick start shown when inteRn loads, and intern_help().
# Function definitions only.

# Exported. How to use inteRn, in one screen. Shown at startup; call it any
#   time. options(intern.quiet = TRUE) in .Rprofile stops the startup copy.
intern_help <- function() {
  key_ok = identical(INTERN_LLM$key_source, "analyst") || nzchar(Sys.getenv(INTERN_LLM$key_var))
  cat(
    "\n-- inteRn: your AI coding intern ------------------------------------\n",
    "  It sees the names, types and labels of your objects, never their values.\n\n",
    "  ask(\"How do I set up a survey design for my data?\")   ask a question\n",
    "  my_data %ask% \"Which variables need recoding?\"        ask about an object\n",
    "  open_intern()                                          chat in the Viewer\n",
    "  /reflex add <lesson>      (inside ask() or the Viewer) save a team lesson\n",
    "  intern_reset()   start over      intern_help()   show this again\n\n",
    "  It asks before running code or writing files. Code it hasn't run is\n",
    "  marked # UNTESTED: run it yourself before trusting it.\n",
    if (!key_ok) paste0("\n  ! No API key found. Add ", INTERN_LLM$key_var,
                        "=... with usethis::edit_r_environ(), then restart R.\n"),
    "---------------------------------------------------------------------\n\n",
    sep = "")
  invisible(NULL)
}
