# make_llm_openai.R for DrSvyR
# Regenerates llm-openai.R from R/llm.R. Run it from the repository root after
# any change to R/llm.R:
#
#   source("make_llm_openai.R")
#
# The two endpoint files share every line except three blocks: the header note,
# the WISE_LLM configuration, and the branch in llm_chat() that builds the
# client. Keeping them in step by hand is the kind of job that looks done and
# is not -- llm-openai.R had already fallen behind on model_key() by two
# fields, which would have keyed the cache differently at work than at home
# without anything saying so. This makes the OpenRouter file the source of
# truth and derives the other one from it.

# ---- the three blocks that differ ---------------------------------------

HEADER <- '# llm.R for DrSvyR -- OpenAI-compatible endpoint
# Endpoint, models, and every model call in the workflow.

# THIS IS THE WORK VARIANT. It reaches one OpenAI-compatible endpoint through
#   ellmer\'s chat_openai_compatible() and knows nothing about any other
#   provider. The home variant that reaches OpenRouter is R/llm.R; exactly one
#   of the two belongs in R/ at a time, and app.R stops if it finds both.

# Generated from R/llm.R by make_llm_openai.R. Edit R/llm.R and re-run that
#   script rather than editing this file, or the two will drift apart in ways
#   that only show up on the machine you edited least recently.
'

CONFIG <- 'WISE_LLM <- list(
  base_url = "https://api.openai.com/v1",
  key_var  = "OPENAI_API_KEY",

  # TODO -- fill these in from the models your organisation actually exposes.
  #   Do not take them from anywhere else: what a key can reach is an account
  #   property, and a name that is wrong fails on the first call.
  #
  #   pm     reads the analysis and writes prose. The larger model.
  #   worker names one segment, many times over. The smaller and cheaper one,
  #          split off so the prose work keeps its quota.
  pm     = "TODO-pm-model",
  worker = "TODO-worker-model",

  # A fallback on the same endpoint does not survive the failure it exists
  #   for. With one provider it helps only when a single model is unavailable
  #   rather than the endpoint. Set it to a smaller model, or leave it equal
  #   to pm and accept that it adds nothing here.
  pm_fallback = "TODO-fallback-model",

  # "server" reads key_var from the environment. "analyst" ignores the
  #   environment entirely and requires a key pasted into the app -- which on
  #   a shared server is what stops a stray environment variable being spent
  #   by people who never knew it was there.
  key_source = "server",
  timeout    = 120,

  # A reply cut off by the token ceiling is not a parse failure the analyst can
  #   do anything about: the JSON simply stops mid-string. Raise it if your
  #   endpoint bills by the call rather than the token and the replies are
  #   still being truncated.
  max_tokens = 4000)'

CLIENT <- '  # One endpoint, one client. credentials must be a function; api_key is
  #   deprecated as of ellmer 0.4.0. The closure is also what lets a key typed
  #   into the app work at all, since it never reaches the process
  #   environment, and it is why this variant needs no branch: there is
  #   nothing to fall back to.
  {
    key = llm_api_key()
    url = WISE_LLM$base_url'

# ---- the rewrite --------------------------------------------------------

# Anchors rather than line numbers, so an edit anywhere else in llm.R moves
#   nothing here.
swap <- function(lines, from, to, replacement, what) {
  i <- grep(from, lines, fixed = TRUE)
  j <- grep(to, lines, fixed = TRUE)
  j <- j[j >= i[1]]
  if (length(i) != 1L || !length(j))
    stop("make_llm_openai.R: could not locate the ", what, " block in R/llm.R. ",
         "The anchors in this script need updating.", call. = FALSE)
  c(lines[seq_len(i - 1L)], strsplit(replacement, "\n")[[1]],
    lines[(j[1] + 1L):length(lines)])
}

# Read the terminator off the source rather than trusting writeLines to guess.
#   R/llm.R is CRLF in this repository; a generated file with bare LF would
#   show every line as changed the first time git looked at it.
raw <- readBin("R/llm.R", "raw", file.size("R/llm.R"))
eol <- if (length(grepRaw("\r\n", rawToChar(raw), fixed = TRUE))) "\r\n" else "\n"

src <- readLines("R/llm.R", warn = FALSE)

out <- swap(src, "# llm.R for DrSvyR", "# ---- configuration ---",
            paste0(HEADER, "\n# ---- configuration -----------------------------------------------------"),
            "header")
out <- swap(out, "WISE_LLM <- list(", "  max_tokens = 4000)", CONFIG, "configuration")
out <- swap(out, "  # ellmer's OpenRouter client reads the key from the process",
            "  } else {", CLIENT, "client")

con <- file("llm-openai.R", open = "wb")
writeLines(out, con, sep = eol)
close(con)

# ---- what actually differs, printed rather than assumed ------------------

d <- setdiff(seq_along(src), NULL)
n_same <- sum(src %in% out)
message("llm-openai.R written: ", length(out), " lines from ", length(src),
        " in R/llm.R; ", n_same, " lines identical.")

# Comments may name the other variant -- the header does, deliberately. Only
#   executable lines are checked, because only those can reach an endpoint.
code <- out[!grepl("^\\s*#", out)]
leftover <- grep("openrouter", code, value = TRUE, ignore.case = TRUE)
if (length(leftover))
  stop("llm-openai.R still reaches OpenRouter:\n",
       paste0("  ", leftover, collapse = "\n"), call. = FALSE)
message("No executable line in llm-openai.R mentions OpenRouter.")

shared <- c("llm_session_key", "llm_set_session_key", "llm_clear_session_key",
            "llm_api_key", "llm_model", "llm_json", "validate_fields",
            "parse_json_block", "model_key", "llm_calls_used",
            "llm_reset_count")
missing <- shared[!vapply(shared, function(f)
  any(grepl(paste0("^", f, " <- function"), out)), logical(1))]
if (length(missing))
  stop("Missing from llm-openai.R: ", paste(missing, collapse = ", "),
       call. = FALSE)
message("All ", length(shared), " shared functions present.")
