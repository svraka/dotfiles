# Set CRAN repo to automatic redirection. Using `getOption()` keeps
# any Rstudio Package Manager Setup from the site Rprofile.
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org/"
  options(repos = r)
})

options(
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

  # Make graphics windows nicer
  setHook(
    packageEvent("grDevices", "onLoad"),
    function(...) {
      if (Sys.info()[["sysname"]] == "Windows") {
        grDevices::windows.options(
          width = 7, height = 5,
          # Put the window near the top left corner. With default values the
          # taskbar on the top would obscure some the window.
          xpos = 10, ypos = 50,
          # Always save graphics history with `record = TRUE`, see:
          # <https://stat.ethz.ch/pipermail/r-help/2008-April/160078.html>.
          # It is done automatically on Mac. After some testing it
          # looks like, this needs to be set before messing with
          # default packages.
          record = TRUE
        )
      } else if (Sys.info()["sysname"] == "Darwin") {
        grDevices::quartz.options(
          width = 7, height = 5
        )
      }
    }
  )

  # Load some packages in interactive sessions and make sure they are loaded
  # after base packages (see https://stackoverflow.com/q/10300769)
  packages_to_attach <- c("arrow", "tidyverse", "readxl")
  packages_available <- sapply(
    packages_to_attach,
    function(x) requireNamespace(x, quietly = TRUE)
  )
  packages_to_attach <- packages_to_attach[packages_available]

  options(
    defaultPackages = c(getOption("defaultPackages"), packages_to_attach)
  )

  rm(packages_to_attach, packages_available)

  # Nicer error reporting with rlang
  if (requireNamespace("rlang", quietly = TRUE)) {
    options(
      rlang_backtrace_on_error = "branch",
      error = rlang::entrace
    )
  }
}

# ESS
if (Sys.getenv("INSIDE_EMACS") != "") {
  options(
    # Settings to open help pages in Emacs buffers with clickable links
    help_type = "text",
    useFancyQuotes = TRUE
  )
}
