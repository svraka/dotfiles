# Load somme packages in interactive sessions and make sure they are loaded
# after base packages.  See https://stackoverflow.com/q/10300769

if (interactive()) {
  options(
    tidyverse.quiet = TRUE,
    defaultPackages = c(getOption("defaultPackages"), "tidyverse", "fstplyr")
  )
}
