# DrSvyR as a Shiny app, run straight from the package source.

# This replaces the separate Shiny branch. The app runs from main's source
#   without the analyst installing anything: at startup the source is
#   installed into a private library that belongs to this script, and the app
#   runs from that copy.
#
# Why install at all, rather than pkgload::load_all(): the search, the
#   bootstrap and the replicate refits run on future multisession workers.
#   Those are fresh R processes. Every function they are handed lives in the
#   drsvyr namespace, so each worker has to load drsvyr, and load_all() exists
#   only in the main process. The workers fail with "there is no package
#   called 'drsvyr'". An installed copy is something a worker can load.
#   The private library goes on .libPaths() and R_LIBS, and future starts its
#   workers with both.
#
# Run it from the repository root:
#   shiny::runApp("shiny_app.R")
# Deploy it:
#   rsconnect::deployApp(appPrimaryDoc = "shiny_app.R")
#
# For everyday analysis use drsvyr::run_drsvyr(). This file is for running
#   uninstalled source and for deploying to a server.


# ---- 1. find the package ----------------------------------------------------

# Found by walking up from the working directory rather than assumed to be the
#   working directory. The folder a session starts in differs between
#   runApp(), RStudio's Run App button, and a deployment server.
find_pkg_root <- function(start = getwd()) {
  is_root = function(d) {
    f = file.path(d, "DESCRIPTION")
    file.exists(f) && identical(unname(read.dcf(f, "Package")[1, 1]), "drsvyr")
  }
  parents = purrr::accumulate(seq_len(10), function(d, i) dirname(d),
                              .init = normalizePath(start, mustWork = TRUE))
  hit = purrr::detect(unique(parents), is_root)
  if (is.null(hit))
    stop("No drsvyr DESCRIPTION found at or above ", start, ". ",
         "Run shiny_app.R from the repository root.", call. = FALSE)
  hit
}

PKG_ROOT <- find_pkg_root()


# ---- 2. install the source privately, then load it ------------------------

# Reading DESCRIPTION's Imports here means a missing dependency stops the app
#   at startup with its name. Otherwise it would fail later, from inside a
#   module, with an error that does not name the package.
local({
  imports = read.dcf(file.path(PKG_ROOT, "DESCRIPTION"), "Imports")[1, 1]
  pkgs = trimws(sub("\\(.*\\)", "", strsplit(imports, ",")[[1]]))
  missing = purrr::discard(pkgs[nzchar(pkgs)], requireNamespace, quietly = TRUE)
  if (length(missing))
    stop("Not installed, so the app cannot start:\n  ",
         paste(missing, collapse = ", "), call. = FALSE)
})

# Reinstalled only when the source has changed since the last start, judged by
#   a checksum over everything that ends up in the package. An unchanged
#   source starts in a second or two, and an edited one can never run stale.
# The library sits in the user's R cache directory, not in the repository, so
#   it is never committed and never lands in a release tarball.
local({
  lib = file.path(tools::R_user_dir("drsvyr", "cache"), "app-lib")
  dir.create(lib, recursive = TRUE, showWarnings = FALSE)

  src = c(file.path(PKG_ROOT, c("DESCRIPTION", "NAMESPACE")),
          list.files(file.path(PKG_ROOT, c("R", "inst")), recursive = TRUE,
                     full.names = TRUE))
  hash_file = tempfile()
  writeLines(unname(tools::md5sum(src)), hash_file)
  hash = unname(tools::md5sum(hash_file))
  stamp = file.path(lib, "source.md5")
  current = file.exists(file.path(lib, "drsvyr", "DESCRIPTION")) &&
    file.exists(stamp) && identical(readLines(stamp, warn = FALSE), hash)

  # A drsvyr already loaded in this R session (an earlier runApp(), or an
  #   installed copy) would be used in place of the new one.
  if ("drsvyr" %in% loadedNamespaces()) unloadNamespace("drsvyr")

  if (!current) {
    message("Installing the drsvyr source for this app (source changed) ...")
    utils::install.packages(PKG_ROOT, lib = lib, repos = NULL,
                            type = "source", quiet = TRUE)
    if (!file.exists(file.path(lib, "drsvyr", "DESCRIPTION")))
      stop("Installing the source into ", lib, " failed; see the output ",
           "above.", call. = FALSE)
    writeLines(hash, stamp)
  }

  # First on the path, so this copy wins over any installed drsvyr. R_LIBS
  #   as well, for any worker that is started from a fresh environment.
  .libPaths(c(lib, .libPaths()))
  Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep))
})

ns <- loadNamespace("drsvyr")
stopifnot(is.function(ns$app_ui), is.function(ns$app_server))


# ---- 3. process settings ----------------------------------------------------

# The same settings run_drsvyr() makes. They are set here because runApp() on
#   this file never calls run_drsvyr(). Help figures are served from
#   inst/app/figures, which the private install puts in the package's app/ folder.
local({
  figs = system.file("app", "figures", package = "drsvyr")
  if (nzchar(figs)) shiny::addResourcePath("figures", figs)
  else warning("inst/app/figures not found; Help figures will not show.",
               call. = FALSE)
})

# Upload ceiling matches run_drsvyr(). future's globals ceiling is raised
#   because the item matrix on a large survey clears its 500 MB default, and
#   the resulting error names a byte count but no variable.
options(
  shiny.maxRequestSize   = getOption("drsvyr.max_upload", 300 * 1024^2),
  future.globals.maxSize = getOption("drsvyr.globals_max", 1024^3))


# ---- 4. the app -------------------------------------------------------------

# The last value is what runApp() and rsconnect serve.
shiny::shinyApp(ns$app_ui(), ns$app_server)
