options(
  repos = c(CRAN = "https://cloud.r-project.org/"),
  Ncpus = parallel::detectCores(),
  usethis.full_name = "András Svraka",
  usethis.description = list(
    `Authors@R` = 'person("András", "Svraka", email = "svraka.andras@gmail.com", role = c("aut", "cre"))'
  ),
  tinytex.latexmk.emulation = FALSE,
  tinytex.clean = FALSE
)

if (interactive()) {
  options(
    scipen = 3,
    digits = 4,
    max.print = 999,
    datatable.print.class = TRUE,
    datatable.print.keys = TRUE,
    tidyverse.quiet = TRUE
  )

  # Always save graphics history, see:
  # <https://stat.ethz.ch/pipermail/r-help/2008-April/160078.html>.
  # After some testing it lloks like, this needs to be done before
  # messing with default pacakges.
  if (Sys.info()[["sysname"]] == "Windows") {
    setHook(
      packageEvent("grDevices", "onLoad"),
      function(...) grDevices::windows.options(record = TRUE)
    )
  }

  # Load some packages in interactive sessions and make sure they are loaded
  # after base packages (see https://stackoverflow.com/q/10300769)
  packages_to_attach <- c("tidyverse", "fstplyr")
  packages_available <- sapply(
    packages_to_attach,
    function(x) requireNamespace(x, quietly = TRUE)
  )
  packages_to_attach <- packages_to_attach[packages_available]

  options(
    defaultPackages = c(getOption("defaultPackages"), packages_to_attach)
  )

  rm(packages_to_attach, packages_available)
}

# ESS
if (Sys.getenv("INSIDE_EMACS") != "") {
  options(
    # Settings to open help pages in Emacs buffers with clickable links
    help_type = "text",
    useFancyQuotes = TRUE
  )
}

# Load OS-spcific env
if (Sys.info()[["sysname"]] == "Windows") {
  readRenviron("~/.Renviron.windows")
} else {
  readRenviron("~/.Renviron.unix")
}
