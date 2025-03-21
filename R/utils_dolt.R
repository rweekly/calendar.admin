create_dolt_conn <- function(
  dolt_local = FALSE,
  repo = "rweekly-org/curation-schedule",
  username = "rpodcast",
  password = "",
  full_name = "Eric Nantz",
  email = "theRcast@gmail.com",
  dir = NULL
) {
  if (!requireNamespace("doltr", quietly = TRUE)) {
    stop(
      "Package \"doltr\" must be installed to use this function.",
      call. = FALSE
    )
  }

  if (is.null(dir)) {
    dir <- fs::path(fs::path_temp(), "dolt_tmpdir")
    if (fs::dir_exists(dir)) fs::dir_delete(dir)
    fs::dir_create(dir)
  }
  if (dolt_local) {
    doltr::dolt_init(dir = dir)
  } else {
    # clone repository
    doltr::dolt_clone(
      remote_url = repo,
      new_dir = dir
    )
  }
  
  doltr::dolt_config_set(
    params = list(
      user.name = full_name,
      user.email = email
    ),
    local_dir = dir
  )

  dolthub_jwk <- stringr::str_replace_all(Sys.getenv("DOLTHUB_JWK"), "\\'", "")
  cmd <- glue::glue("echo '{dolthub_jwk}' | dolt creds import")
  system(cmd)
  local_conn <- doltr::dolt(dir = dir, username = username)
  return(local_conn)
}

create_dolt_pr <- function(
  title,
  description,
  from_branch_name,
  to_branch_name = "main",
  from_branch_owner_name = "rpodcast",
  from_branch_repo_name = "curation-schedule",
  to_branch_owner_name = "rweekly-org",
  to_branch_repo_name = "curation-schedule",
  base_url = "https://www.dolthub.com/api/v1alpha1"
) {
  req <- httr2::request(base_url) |>
    httr2::req_url_path_append(to_branch_owner_name, to_branch_repo_name, "pulls") |>
    httr2::req_headers(Authorization = paste("token", Sys.getenv("DOLTHUB_TOKEN"))) |>
    httr2::req_body_json(
      list(
        title = title,
        description = description,
        fromBranchOwnerName = from_branch_owner_name,
        fromBranchRepoName = from_branch_repo_name,
        fromBranchName = from_branch_name,
        toBranchOwnerName = to_branch_owner_name,
        toBranchRepoName = to_branch_repo_name,
        toBranchName = to_branch_name
      )
    )

  resp <- httr2::req_perform(req)
  resp_obj <- httr2::resp_body_json(resp)
  return(resp_obj)
}

dolt_push <- function(conn, branch_name = "testbranch") {
  query <- glue::glue("CALL DOLT_PUSH('--set-upstream', 'origin', '{branch_name}')")
  DBI::dbGetQuery(conn, query)
  invisible(TRUE)
}

