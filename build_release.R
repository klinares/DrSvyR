# Builds the zip that analysts download and install from.
#
# Run from the repository root:
#   Rscript build_release.R              package + installer
#   Rscript build_release.R --with-deps  also bundles Windows binaries of every
#                                        dependency, for machines that cannot
#                                        reach CRAN at all
#
# Output, both in dist/:
#   drsvyr_<version>.tar.gz  the plain source tarball -- for you, or for
#                           install.packages(that_path, repos = NULL,
#                           type = "source")
#   drsvyr_<version>.zip     the tarball plus install_drsvyr.R together, for
#                           an analyst: they unzip it, open R, and run
#                           source("install_drsvyr.R", chdir = TRUE)

# The package goes in as a tarball from R CMD build, not as a zip of the
#   folder. R CMD build applies .Rbuildignore, so work folders, .git and any
#   stray respondent data stay out of it. install.packages(type = "source")
#   also expects a tarball: on Windows it reads a .zip as a binary package and
#   fails.

local({
  if (!file.exists("DESCRIPTION"))
    stop("Run this from the repository root.", call. = FALSE)
  desc = read.dcf("DESCRIPTION")
  pkg = desc[1, "Package"]
  ver = desc[1, "Version"]
  with_deps = "--with-deps" %in% commandArgs(trailingOnly = TRUE)

  stage = file.path(tempdir(), paste0(pkg, "_", ver))
  unlink(stage, recursive = TRUE)
  dir.create(stage, recursive = TRUE)
  dir.create("dist", showWarnings = FALSE)
  root = normalizePath(".")

  # ---- 1. the package tarball ----------------------------------------------
  old = setwd(stage)
  on.exit(setwd(old), add = TRUE)
  status = system2(file.path(R.home("bin"), "R"),
                   c("CMD", "build", "--no-build-vignettes", "--no-manual",
                     shQuote(root)))
  setwd(old)
  tarball = list.files(stage, paste0("^", pkg, "_.*[.]tar[.]gz$"),
                       full.names = TRUE)
  if (status != 0 || length(tarball) != 1)
    stop("R CMD build failed; see the output above.", call. = FALSE)

  # These files make the app work but are not code, so neither parse() nor
  #   R CMD build notices when one is missing. The .gitignore note on
  #   inst/extdata describes exactly that happening once already.
  inside = utils::untar(tarball, list = TRUE)
  need = paste0(pkg, "/inst/app/help.md")
  if (!need %in% inside)
    stop("The tarball has no ", need, ". The Help tab would fail.",
         call. = FALSE)
  if (!any(grepl(paste0("^", pkg, "/inst/extdata/.+[.](sav|dta)$"), inside)))
    warning("No demonstration survey in inst/extdata. The demo button will ",
            "not work.", call. = FALSE)

  # ---- 2. dependencies, optionally -----------------------------------------
  # A local CRAN-style repository inside the zip. install_drsvyr.R looks here
  #   first and falls back to the analyst's usual repository.
  # These are binaries for the R version THIS machine runs (for example
  #   4.4.x). They only install on an analyst's R with the same major.minor
  #   version, so build on the version your organisation deploys.
  if (with_deps) {
    cran = "https://cloud.r-project.org"
    db = utils::available.packages(repos = cran, type = "win.binary")
    imports = trimws(sub("\\(.*\\)", "",
                         strsplit(desc[1, "Imports"], ",")[[1]]))
    base_pkgs = rownames(utils::installed.packages(priority = "base"))
    all_deps = tools::package_dependencies(
      imports, db = db, which = c("Depends", "Imports", "LinkingTo"),
      recursive = TRUE) |>
      unlist(use.names = FALSE) |>
      c(imports) |>
      unique() |>
      setdiff(c(base_pkgs, "R"))
    contrib = file.path(stage, "repo",
                        sub(".*/(bin/windows/contrib/.*)$", "\\1",
                            utils::contrib.url(cran, "win.binary")))
    dir.create(contrib, recursive = TRUE)
    got = utils::download.packages(all_deps, destdir = contrib, repos = cran,
                                   type = "win.binary", quiet = TRUE)
    tools::write_PACKAGES(contrib, type = "win.binary")
    message(nrow(got), " of ", length(all_deps), " dependencies bundled.")
  }

  # ---- 3. copy the plain tarball out of tempdir() ---------------------------
  # R CMD build only ever writes inside `stage`, which is under tempdir() --
  #   never under the repository -- so up to here the tarball does not exist
  #   anywhere you would think to look for it. This is the file dir() was
  #   missing.
  tar_out = file.path(root, "dist", basename(tarball))
  file.copy(tarball, tar_out, overwrite = TRUE)

  # ---- 4. the zip, tarball + installer together -----------------------------
  file.copy(file.path(root, "install_drsvyr.R"), stage)
  zipfile = file.path(root, "dist", paste0(pkg, "_", ver, ".zip"))
  unlink(zipfile)
  zip::zip(zipfile, files = list.files(stage, recursive = TRUE),
           root = stage)

  message("Built:\n  ", tar_out, "\n  ", zipfile)
})
