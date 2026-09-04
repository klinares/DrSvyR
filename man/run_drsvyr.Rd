% Written by hand. roxygen would mean a @-block above run_drsvyr() and a
% Roxygen line in DESCRIPTION, for one page.
\name{run_drsvyr}
\alias{run_drsvyr}
\alias{drsvyr}
\alias{drsvyr-package}
\title{Run the DrSvyR application}

\description{
Starts the DrSvyR Shiny application: a guided workflow that fits a weighted
latent class model to a battery of survey items on complex survey data, with
every standard error derived from the survey's own stratified jackknife
replicate design.

The analyst uploads an SPSS or Stata file, names the design variables, chooses
the battery and the number of segments, and leaves with a self-contained HTML
report and their survey file with segment membership added. Nothing is written
outside a temporary folder, and everything produced is handed back as a single
archive.
}

\usage{
run_drsvyr(
  port = getOption("drsvyr.port", 7817L),
  host = "127.0.0.1",
  launch.browser = interactive()
)
}

\arguments{
  \item{port}{Port to serve on. Fixed by default so a bookmark keeps working.}

  \item{host}{Address to bind to. Loopback by default: the survey file and the
    scored data reach the machine running this, and binding to \code{0.0.0.0}
    would put them on the network. Change it only for a deliberate server
    deployment.}

  \item{launch.browser}{Whether to open a browser. May be \code{TRUE},
    \code{FALSE}, or a function taking the URL. The URL is printed either way,
    since not every environment has a browser to open, and \code{TRUE} is not
    a reason to lose a server that started correctly.}
}

\value{
Called for its side effect. Does not return until the application stops.
}

\section{What it needs}{
A survey file in SPSS (\code{.sav}, \code{.zsav}) or Stata (\code{.dta})
format, containing a weight, a stratum, a primary sampling unit and a
respondent identifier. This is for stratified clustered designs; weights alone
are not enough. A few hundred completed interviews or more.

A demonstration survey ships with the package and is offered on the first
screen, so the workflow can be run end to end without supplying anything.
}

\section{The language model}{
A model drafts segment names, reads the diagnostics and the domain tables, and
writes the report summary. In every case R computes the conclusion and the
model translates it: it never sees a respondent record and never decides
significance.

It is optional. \pkg{ellmer} is a suggested dependency, and without it the
analysis runs and the report is written with those passages absent rather than
failing. Supply a key through \code{OPENROUTER_API_KEY} or
\code{OPENAI_API_KEY}, or paste one on the first screen for the session only.
}

\section{Options}{
\describe{
  \item{\code{drsvyr.port}}{Default port.}
  \item{\code{drsvyr.workers}}{Parallel workers for the model search. Capped
    at four, so several analysts can share one server without one of them
    taking it. Changes how long the search takes and not what it produces.}
  \item{\code{drsvyr.max_upload}}{Upload ceiling in bytes. Defaults to 300 MB;
    Shiny's own default of 5 MB is below the size of an ordinary survey file.}
  \item{\code{drsvyr.debug}}{If \code{TRUE}, leaves a snapshot of the session
    state in the global environment when the session ends.}
}
}

\section{Limitations}{
The analysis assumes each question works the same way in every group being
compared, and does not test it. Domain intervals hold the measurement model
fixed, which is standard three-step practice and makes them optimistic.
Diagnostics rank rather than test: under a design-weighted pseudo-likelihood
none of them has a reference distribution, and no threshold is attached to any
of them. The report states all of this beside the numbers it applies to.
}

\examples{
\dontrun{
run_drsvyr()

# a different port, and no attempt to open a browser
run_drsvyr(port = 8080, launch.browser = FALSE)
}
}
