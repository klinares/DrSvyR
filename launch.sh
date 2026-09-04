#!/usr/bin/env bash
# Build the environment if it is not there, then start DrSvyR.
#
# Runs in Git Bash on Windows and in a shell on the Linux server, which is why
#   it is bash and not a .bat and not a PowerShell script. The analyst installs
#   miniconda and Git Bash from the software centre, clones this repository,
#   and runs:
#       ./launch.sh
#
# Every failure below is caught and named. An analyst who has never used conda
#   cannot act on a solver traceback, and "it didn't work" is the support
#   ticket this script exists to prevent.

set -euo pipefail

ENV_NAME="drsvyr"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${DRSVYR_PORT:-7817}"

say()  { printf '\n%s\n' "$*"; }
die()  { printf '\nStopped: %s\n\n' "$*" >&2; exit 1; }

# ---- 1. conda has to be on the PATH ----------------------------------------
# Git Bash does not pick up the conda hook that the Anaconda Prompt sets, so
#   the usual symptom is "conda: command not found" on a machine where conda is
#   installed and working. The common install locations are checked before
#   giving up, because telling the analyst to "initialise conda" is telling
#   them to do the thing they came here to avoid.
if ! command -v conda >/dev/null 2>&1; then
  for guess in \
      "$HOME/miniconda3" "$HOME/Miniconda3" \
      "$HOME/AppData/Local/miniconda3" \
      "/c/ProgramData/miniconda3" "/opt/miniconda3"; do
    if [ -f "$guess/etc/profile.d/conda.sh" ]; then
      # shellcheck disable=SC1091
      . "$guess/etc/profile.d/conda.sh"
      break
    fi
  done
fi

command -v conda >/dev/null 2>&1 || die \
"conda is not on the PATH.

If Miniconda is installed, open the Anaconda Prompt once and run
    conda init bash
then close this window and run ./launch.sh again.

If it is not installed, get Miniconda from the software centre first."

eval "$(conda shell.bash hook)"

# ---- 2. build the environment, once ----------------------------------------
# Existence is tested rather than assumed, so a second run is fast. To rebuild
#   after environment.yml changes, delete it first:
#       conda env remove -n drsvyr
if conda env list | grep -qE "^${ENV_NAME}[[:space:]]"; then
  say "Environment '${ENV_NAME}' is already built."
else
  say "Building '${ENV_NAME}'. This takes a few minutes the first time only."
  conda env create -f "${HERE}/environment.yml" -n "${ENV_NAME}" \
    || die "The environment could not be built. Send the output above for help."
fi

conda activate "${ENV_NAME}"

# ---- 2b. install the package itself ----------------------------------------
# The environment supplies the dependencies; the package is installed into it
#   from this checkout. Reinstalled whenever the source is newer than what is
#   installed, so a git pull is enough to update -- the analyst never runs
#   R CMD INSTALL themselves.
NEED_INSTALL=1
if R --quiet --no-save -e "q(status = !requireNamespace('drsvyr', quietly = TRUE))" >/dev/null 2>&1; then
  NEWEST=$(find "${HERE}/R" "${HERE}/DESCRIPTION" -newer \
    "$(R --quiet --no-save -e "cat(system.file('DESCRIPTION', package='drsvyr'))" 2>/dev/null | tail -1)" \
    2>/dev/null | head -1)
  [ -z "${NEWEST}" ] && NEED_INSTALL=0
fi
if [ "${NEED_INSTALL}" = "1" ]; then
  say "Installing DrSvyR into the environment."
  R CMD INSTALL "${HERE}" \
    || die "The package could not be installed. Send the output above for help."
fi

# ---- 3. the API key --------------------------------------------------------
# Absent is not fatal. Every model call is guarded and the analysis runs
#   without prose, so the app starts and says so rather than refusing.
if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -z "${OPENAI_API_KEY:-}" ]; then
  say "No API key found in the environment. The app will start, and the
methodologist and the drafted names will be unavailable. Paste a key on the
Start here tab to enable them for this session, or set OPENROUTER_API_KEY."
fi

# ---- 4. start --------------------------------------------------------------
# launch.browser opens a tab automatically wherever that is possible, so a
#   desktop analyst never has to know a URL exists. It is not TRUE, though:
#   Shiny's default there is utils::browseURL(), which throws
#   "'browser' must be a non-empty character string" and takes the whole
#   session down whenever nothing is registered to open one -- which is
#   ordinary and expected inside WSL2, since a Linux subsystem with no desktop
#   of its own has no browser to hand the URL to and no bridge to Windows'
#   unless something has been configured for it. A closed browser is not a
#   reason to lose a server that started correctly.
# A function is passed instead: try the real opener, and if that fails for any
#   reason -- WSL2 with nothing configured, a locked-down desktop, a headless
#   box -- print the URL and keep the server running. This is not
#   WSL-specific; it is the right fallback on every platform, and it only
#   changes behaviour on the ones where the automatic open would have failed
#   anyway.
say "Starting DrSvyR. Leave this window open; closing it stops the app."
R --quiet --no-save -e "
  # browseURL() on Linux shells out with wait = FALSE, so it returns
  #   immediately -- before the opener it launched has had any chance to
  #   fail. There is no reliable way to detect success from here: this was
  #   tried with both error/warning handlers and an exit-status check, and
  #   neither caught the WSL2 case where xdg-open exists but has nothing
  #   registered behind it.
  # So detection is abandoned rather than attempted unreliably. The URL is
  #   always printed, and opening a browser is attempted as a bonus on top of
  #   that guarantee rather than as the only way the analyst learns it.
  open_browser <- function(url) {
    cat('\nDrSvyR is running at:\n\n    ', url, '\n\n',
       'Open that address in a browser if one did not open automatically.\n\n',
       sep = '')
    try(utils::browseURL(url), silent = TRUE)
    invisible(NULL)
  }
  drsvyr::run_drsvyr(port = ${PORT}, host = '127.0.0.1',
                     launch.browser = open_browser)
"
