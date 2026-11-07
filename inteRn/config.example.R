# config.example.R -- template for inteRn's settings.
#
# Copy this file to config.R in the same folder and edit the copy. config.R is
#   ignored by git, so your endpoint, models and folders stay on your machine.
#   This file and .Renviron are the only two things a user changes.
#
# The key itself never goes here. Put one line in your user .Renviron
#   (usethis::edit_r_environ() opens it), e.g.
#       ANTHROPIC_API_KEY=sk-ant-...
#   and restart R. key_var below names that variable.

INTERN_LLM <- list(
  # Anthropic's public API. At work, the server's base URL, ending where
  #   Anthropic's ends (the part before /messages).
  base_url = "https://api.anthropic.com/v1",
  # The name of the environment variable that holds the key -- not the key.
  key_var  = "ANTHROPIC_API_KEY",

  # The model IDs exactly as the endpoint names them. Check against
  #   ellmer::models_anthropic() or the work server's model list: a wrong ID
  #   fails every call with "model not found". The intern talks with "pm";
  #   "worker" is for short one-shot jobs (drafting labels, fixing lint).
  pm          = "claude-sonnet-5",
  worker      = "claude-sonnet-5",
  # Tried once after the main model fails with a server-side error. NULL for
  #   none.
  pm_fallback = NULL,

  # "server" reads key_var from the environment. "analyst" ignores the
  #   environment and asks for the key once per R session (kept in memory
  #   only, never written anywhere).
  key_source = "server",
  # Seconds to wait for one reply.
  timeout    = 120,

  # Ceiling for each reply, including the model's internal reasoning.
  #   Too low and a long answer is cut off before it is written.
  max_tokens  = 8000,
  # NULL sends no temperature. Recent Claude models refuse the setting
  #   ("temperature is deprecated for this model"); set a number only for a
  #   model that accepts one.
  temperature = NULL,

  # Prompt caching: the system prompt and skills are resent every turn, so a
  #   five-minute cache saves cost across a session. "1h", or "none" if the
  #   endpoint rejects cache instructions.
  cache = "5m",

  # Folder of shared skills (one sub-folder per skill, each with SKILL.md).
  #   NULL means the ai_skills folder next to the inteRn folder.
  skills_dir = NULL,

  # The only folders read_file() and write_file() may touch. "." means the
  #   working directory at the time of the call (your current project), so
  #   it follows you from project to project.
  allow_dirs = c("."),

  # Any count below this is shown as "<n" and never sent to the model.
  suppress_n = 10,

  # The lint gate: R code in a reply is checked with lintr (no loops, no base
  #   graphics, colourblind-safe colours) and sent back for a rewrite up to
  #   lint_retries times before you see it. FALSE turns it off.
  lint = TRUE,
  lint_retries = 2)
