#!/usr/bin/env Rscript

library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(purrr, quietly = TRUE, warn.conflicts = FALSE)
library(rvest, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE, warn.conflicts = FALSE)

args <- commandArgs(TRUE)

edition <- args[1]
baseurl <- "https://www.economist.com/"
url <- paste0(baseurl, "eu/printedition/", edition)
html <- read_html(url)
articles <- html %>%
  html_node(".print-edition__content") %>%
  html_node(".list") %>%
  html_nodes(".list__item")

articles_by_section <- function(html) {
  # Helper function to pull node text
  column <- function(html, node) html %>% html_nodes(node) %>% html_text()

  # Helper function to get all info on a single article.  We need to use a list
  # because some artcles have different attributes (e.g. "The world this week"
  # section only has subtitles).
  article_properties <- function(articles) {
    list(
      flytitle = column(articles, ".print-edition__link-flytitle"),
      title    = column(articles, ".print-edition__link-title"),
      subtitle = column(articles, ".print-edition__link-title-sub"),
      url      = html_attr(articles, "href")
    ) %>%
      map_dfr(function(x) if(identical(x, character(0))) NA_character_ else x)
  }

  html_nodes(html, "a") %>%
    map_dfr(article_properties) %>%
    mutate(
      section = column(html, ".list__title"),
      url = paste0(baseurl, sub("/", "", url))
    ) %>%
    select(section, everything())
}

articles %>%
  map_dfr(articles_by_section) %>%
  write_csv(path = paste0("economist_", edition, ".csv"))
