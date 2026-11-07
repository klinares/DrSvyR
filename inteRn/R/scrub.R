# scrub.R -- removes credentials, personal paths and e-mail addresses from
#   text before it can reach the model. Function definitions and constants
#   only.

# Credentials: replaced wherever they appear.
SCRUB_SECRETS <- c(
  "sk-ant-[A-Za-z0-9_-]{8,}",                 # Anthropic
  "sk-[A-Za-z0-9_-]{20,}",                    # OpenAI-style
  "gh[pousr]_[A-Za-z0-9]{20,}",               # GitHub
  "AKIA[0-9A-Z]{16}",                         # AWS access key ID
  "xox[abprs]-[A-Za-z0-9-]{10,}",             # Slack
  "(?i)bearer\\s+[A-Za-z0-9._~+/=-]{8,}")      # Authorization headers

# key = "value" style assignments: the name is kept, the value is not.
SCRUB_ASSIGN <- paste0(
  "(?i)\\b([A-Za-z0-9_.]*(api[_.-]?key|token|secret|passw(or)?d|pwd|credential)",
  "[A-Za-z0-9_.]*)(\\s*(=|<-|:)\\s*)([\"'])[^\"'\\n]+\\6")

# Paths that name a machine or a person.
SCRUB_PATHS <- c(
  "(?i)\\b[a-z]:[\\\\/][^\"'\\s,)]*",          # C:\..., D:/...
  "\\\\\\\\[^\"'\\s,)]+",                     # \\server\share
  "/(home|Users)/[^\"'\\s,)]+",                # /home/me, /Users/me
  "~/[^\"'\\s,)]*")                            # ~/...

SCRUB_EMAIL <- "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

# paths = FALSE for file contents the model may edit and write back: a path
#   replaced by "<path>" there would be written into the user's file.
scrub_text <- function(x, paths = TRUE) {
  x = paste(x, collapse = "\n")
  x = purrr::reduce(SCRUB_SECRETS, function(t, p) gsub(p, "<redacted>", t, perl = TRUE),
                    .init = x)
  x = gsub(SCRUB_ASSIGN, "\\1\\4\\6<redacted>\\6", x, perl = TRUE)
  x = gsub(SCRUB_EMAIL, "<email>", x, perl = TRUE)
  if (paths)
    x = purrr::reduce(SCRUB_PATHS, function(t, p) gsub(p, "<path>", t, perl = TRUE),
                      .init = x)
  x
}

# Whether text carries one of the placeholders scrub_text() writes. Used to
#   refuse a write that would put "<redacted>" into a real file.
has_scrub_marks <- function(x) grepl("<redacted>|<path>|<email>", paste(x, collapse = "\n"))
