options(
  repos = c(CRAN = "https://cloud.r-project.org/"),
  usethis.full_name = "András Svraka",
  usethis.description = list(
    `Authors@R` = 'person("András", "Svraka", email = "svraka.andras@gmail.com", role = c("aut", "cre"))'
  )
)

if (interactive()) {
  options(
    # Printing options
    scipen = 3,
    digits = 4,
    max.print = 999,
    datatable.print.class = TRUE,
    datatable.print.keys = TRUE,

    # Load some packages in interactive sessions and make sure they are loaded
    # after base packages (see https://stackoverflow.com/q/10300769)
    tidyverse.quiet = TRUE,
    defaultPackages = c(getOption("defaultPackages"), "tidyverse", "fstplyr")
  )
}
