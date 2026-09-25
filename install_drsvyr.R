# Installs DrSvyR from the unzipped release folder.
#
# 1. Unzip drsvyr_<version>.zip anywhere.
# 2. Open R or RStudio and run, pointing at that folder:
#      source("C:/path/to/drsvyr_0.1.0/install_drsvyr.R", chdir = TRUE)
# 3. Start the app:
#      drsvyr::run_drsvyr()

local({
  tarball = list.files(".", "^drsvyr_.*[.]tar[.]gz$")
  if (length(tarball) != 1)
    stop("No drsvyr_*.tar.gz next to this script. Did you source it with ",
         "chdir = TRUE from the unzipped folder?", call. = FALSE)

  # The bundled repository first, if this release has one. After that, the
  #   repository R is already set up to use: at work that is often an internal
  #   mirror, and it should be respected rather than overridden.
  usual = getOption("repos")
  usual[usual == "@CRAN@"] = "https://cloud.r-project.org"
  bundled = if (dir.exists("repo"))
    paste0("file:///", sub("^/", "", normalizePath("repo", winslash = "/")))
  repos = c(bundled, usual)

  # install.packages() on a local tarball with repos = NULL does not install
  #   dependencies, so they are installed first, by name, from the repos
  #   above. It resolves their own dependencies itself.
  ex = tempfile()
  utils::untar(tarball, files = "drsvyr/DESCRIPTION", exdir = ex)
  d = read.dcf(file.path(ex, "drsvyr", "DESCRIPTION"))
  imports = trimws(sub("\\(.*\\)", "", strsplit(d[1, "Imports"], ",")[[1]]))
  missing = setdiff(imports[nzchar(imports)],
                    rownames(utils::installed.packages()))
  if (length(missing)) {
    message("Installing ", length(missing), " dependencies: ",
            paste(missing, collapse = ", "))
    utils::install.packages(missing, repos = repos)
  }
  still = setdiff(missing, rownames(utils::installed.packages()))
  if (length(still))
    stop("These could not be installed: ", paste(still, collapse = ", "),
         ". Send this message to whoever manages R on your machine.",
         call. = FALSE)

  # drsvyr is pure R, so installing from source needs no Rtools.
  utils::install.packages(tarball, repos = NULL, type = "source")
  message("\nInstalled. Start the app with:  drsvyr::run_drsvyr()")
})
