#https://gist.github.com/b-rodrigues/d427703e76a112847616c864551d96a1
library(rix)

if (nzchar(Sys.getenv("INSTALL_APP_PACKAGE"))) {
  local_r_pkgs <- list.files(path = getwd(), pattern = "calendar.admin_*")[1]
} else {
  local_r_pkgs <- NULL
}

rix(
  date = "2025-01-14",
  project_path = getwd(),
  r_pkgs = c(
    "tibble",
    "lubridate",
    "stringr",
    "dplyr",
    "clock",
    "httr2",
    "jsonlite",
    "openxlsx2",
    "fs",
    "dbplyr",
    "shiny",
    "toastui",
    "pool",
    "bslib",
    "reactable",
    "DT",
    "golem",
    "devtools",
    "dockerfiler",
    "renv",
    "auth0",
    "attachment",
    "testthat",
    "slackr",
    "markdown",
    "dotenv"
  ),
  git_pkgs = list(
    list(
      package_name = "doltr",
      repo_url = "https://github.com/ecohealthalliance/doltr/",
      commit = "ffb5bc68003e83ebdb9f352654bab2515ca6bf3a"
    )
  ),
  local_r_pkgs = local_r_pkgs,
  system_pkgs = c("dolt", "flyctl"),
  ide = "none",
  overwrite = TRUE
)
