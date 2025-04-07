#' Import R Weekly curation schedule data
#' 
#' Obtain the current version of the R Weekly curation schedule metadata
#' from the R Weekly Dolthub repository
#' 
#' @param query String with the SQL querty to execute on Dolthub. Default is
#'   the string `SELECT * FROM schedule` which simply returns all rows of the 
#'   table.
#' @param from_owner String with the Dolthub owner of the database. Default is
#'   `rweekly-org`.
#' @param from_repo_name String with the name of the repository containing the
#'   database. Default is `curation-schedule`.
#' @return data frame of the R Weekly schedule data
#' @export
import_schedule_data <- function(
  query = "SELECT * FROM schedule",
  from_owner = "rweekly-org",
  from_repo_name = "curation-schedule"
) {
  if (get_golem_config("dolt_local")) {
    result_df <- tibble::as_tibble(schedule_df)
    return(result_df)
  } else {
    result_raw <- httr2::request("https://www.dolthub.com") |>
    httr2::req_url_path_append(
      "api",
      "v1alpha1",
      from_owner,
      from_repo_name
    ) |>
      httr2::req_url_query(
        q = query
      ) |>
      httr2::req_perform()
  
    result_json <- httr2::resp_body_json(result_raw)

    result_df <- purrr::map_df(
      purrr::pluck(result_json, "rows"),
      ~{
        data_row <- purrr::map_depth(.x, 1, ~ifelse(is.null(.x), NA, .x))
        return(tibble::as_tibble_row(data_row))
      }
    ) |>
      dplyr::mutate(
        issue_index = as.numeric(issue_index),
        from = as.Date(from),
        to = as.Date(to)
      )
    return(result_df)
  }
}

#' Import R Weekly curator team data
#' 
#' Obtain the current version of the R Weekly curator team metadata
#' from the R Weekly Dolthub repository
#' 
#' @param query String with the SQL querty to execute on Dolthub. Default is
#'   the string `SELECT * FROM curator_df` which simply returns all rows of the 
#'   table.
#' @param from_owner String with the Dolthub owner of the database. Default is
#'   `rweekly-org`.
#' @param from_repo_name String with the name of the repository containing the
#'   database. Default is `curation-schedule`.
#' @return data frame of the R Weekly curator data
#' @export
import_curator_data <- function(
  query = "SELECT * FROM curator_df",
  from_owner = "rweekly-org",
  from_repo_name = "curation-schedule"
) {
  if (get_golem_config("dolt_local")) {
    result_df <- tibble::as_tibble(curator_df)
    return(result_df)
  } else {
    result_raw <- httr2::request("https://www.dolthub.com") |>
      httr2::req_url_path_append(
        "api",
        "v1alpha1",
        from_owner,
        from_repo_name
      ) |>
        httr2::req_url_query(
          q = query
        ) |>
        httr2::req_perform()
    
    result_json <- httr2::resp_body_json(result_raw)
  
    result_df <- purrr::map_df(
      purrr::pluck(result_json, "rows"),
      ~tibble::as_tibble_row(.x)
    ) 
    return(result_df)
  }
}
