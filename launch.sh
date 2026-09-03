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

# ---- 3. the API key --------------------------------------------------------
# Absent is not fatal. Every model call is guarded and the analysis runs
#   without prose, so the app starts and says so rather than refusing.
if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -z "${OPENAI_API_KEY:-}" ]; then
  say "No API key found in the environment. The app will start, and the
methodologist and the drafted names will be unavailable. Paste a key on the
Start here tab to enable them for this session, or set OPENROUTER_API_KEY."
fi

# ---- 4. start --------------------------------------------------------------
# launch.browser is TRUE so the analyst gets a tab rather than a URL to copy,
#   and the port is fixed so a bookmark keeps working. host stays on loopback:
#   this is the desktop route, and binding to 0.0.0.0 would put respondent data
#   on the office network. The server deployment does not use this script.
say "Starting DrSvyR. Leave this window open; closing it stops the app."
cd "${HERE}"
R --quiet --no-save -e "shiny::runApp('.', port = ${PORT}, host = '127.0.0.1', launch.browser = TRUE)"
