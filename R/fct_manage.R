process_decline_df <- function(schedule_df, issue_selected_df) {
  # obtain issue ID of selected issue
  issue_id <- issue_selected_df$issue_id

  schedule_df |>
    dplyr::mutate(
      curator = ifelse(issue_id == !!issue_id, NA, curator)
    )
}

process_switch_df <- function(schedule_df, issue_selected_df, switch_issue_selected_df) {
  # obtain issue ID of selected issue
  issue_id <- issue_selected_df$issue_id

  # obtain curator of selected issue
  issue_curator <- issue_selected_df$curator

  # obtain issue ID of switch selected issue
  switch_issue_id <- switch_issue_selected_df$issue_id

  # obtain curator of switch selected issue
  switch_issue_curator <- switch_issue_selected_df$curator

  schedule_df |>
    dplyr::mutate(
      curator = ifelse(issue_id == !!switch_issue_id, issue_curator, curator),
    ) |>
    dplyr::mutate(
      curator = ifelse(issue_id == !!issue_id, switch_issue_curator, curator),
    )
}

submit_decline <- function(
  conn, 
  schedule_df, 
  curator_df,
  issue_selected_df,
  to_branch_name = "main",
  from_branch_owner_name = "rpodcast",
  from_branch_repo_name = "curation-schedule",
  to_branch_owner_name = "rweekly-org",
  to_branch_repo_name = "curation-schedule",
  submit_pr = TRUE,
  notify_slack_channel = FALSE,
  slack_channel = "#random",
  notify_user = TRUE
) {
  
  if (!requireNamespace("doltr", quietly = TRUE)) {
    stop(
      "Package \"doltr\" must be installed to use this function.",
      call. = FALSE
    )
  }

  # initialize variables
  branch_name <- glue::glue("decline_{issue_selected_df$issue_id}")
  pr_title <- glue::glue("Decline {issue_selected_df$issue_id} from {issue_selected_df$curator}")
  pr_description <- glue::glue("declined {issue_selected_df$issue_id} requested by {issue_selected_df$curator} covering the date range {issue_selected_df$from} to {issue_selected_df$to}.}")

  # obtain data associated with request
  revised_df <- process_decline_df(schedule_df, issue_selected_df)

  # create new local branch
  doltr::dolt_checkout(branch = branch_name,  b = TRUE, conn = conn)
  Sys.sleep(1)
  #doltr::dolt_checkout(branch = branch_name, conn = conn)

  # commit new schedule data frame
  DBI::dbWriteTable(conn, "schedule", revised_df, overwrite = TRUE)
  DBI::dbExecute(conn, "alter table schedule add primary key(issue_id);")
  doltr::dolt_add("schedule", conn = conn)

  # commit and push
  doltr::dolt_commit(message = pr_title, conn = conn)
  dolt_push(conn, branch_name = branch_name)
  Sys.sleep(2)

  # submit PR
  pr_resp <- NULL
  if (submit_pr) {
    pr_resp <- create_dolt_pr(
      title = pr_title,
      description = pr_description,
      from_branch_name = branch_name,
      from_branch_owner_name = from_branch_owner_name,
      from_branch_repo_name = from_branch_repo_name,
      to_branch_owner_name = to_branch_owner_name,
      to_branch_repo_name = to_branch_repo_name
    )
  }
  
  if (notify_slack_channel) {
    curator_id <- curator_df |>
      dplyr::filter(real_name == issue_selected_df$curator) |>
      dplyr::pull(short_name)

    backup_id <- curator_df |>
      dplyr::filter(real_name == issue_selected_df$backup) |>
      dplyr::pull(short_name)

    msg_resp <- send_decline_message(
      curator_id = curator_id,
      curator_name = issue_selected_df$curator,
      backup_id = backup_id,
      backup_name = issue_selected_df$backup,
      issue_id = issue_selected_df$issue_id,
      curation_start = issue_selected_df$from,
      curation_end = issue_selected_df$to,
      channel = slack_channel,
      repo = get_golem_config("repo"),
      notify_user = notify_user
    )
  }

  invisible(pr_resp)
}

submit_switch <- function(
  conn,
  schedule_df,
  curator_df,
  issue_selected_df,
  switch_issue_selected_df,
  to_branch_name = "main",
  from_branch_owner_name = "rpodcast",
  from_branch_repo_name = "curation-schedule",
  to_branch_owner_name = "rweekly-org",
  to_branch_repo_name = "curation-schedule",
  notify_slack_channel = FALSE,
  submit_pr = TRUE,
  slack_channel = "#random",
  notify_user = TRUE
) {
  
  if (!requireNamespace("doltr", quietly = TRUE)) {
    stop(
      "Package \"doltr\" must be installed to use this function.",
      call. = FALSE
    )
  }
  
  # initialize variables
  branch_name <- glue::glue("switch_{issue_selected_df$issue_id}")
  pr_title <- glue::glue("Switch {issue_selected_df$issue_id} - {issue_selected_df$curator} with {switch_issue_selected_df$issue_id} - {switch_issue_selected_df$curator}")
  pr_description <- glue::glue("
  Curator {issue_selected_df$curator} has requested to switch one of their scheduled curations with {switch_issue_selected_df$curator}:
  * Original: {issue_selected_df$issue_id} covering the date range {issue_selected_df$from} to {issue_selected_df$to}.
  * Switch: {switch_issue_selected_df$issue_id} covering the date range {switch_issue_selected_df$from} to {switch_issue_selected_df$to}.")

  # obtain data associated with request
  revised_df <- process_switch_df(schedule_df, issue_selected_df, switch_issue_selected_df)

  # create new local branch
  doltr::dolt_checkout(branch = branch_name,  b = TRUE, conn = conn)
  #doltr::dolt_checkout(branch = branch_name, conn = conn)

  # commit new schedule data frame
  DBI::dbWriteTable(conn, "schedule", revised_df, overwrite = TRUE)
  DBI::dbExecute(conn, "alter table schedule add primary key(issue_id);")
  doltr::dolt_add("schedule", conn = conn)

  # commit and push
  doltr::dolt_commit(message = pr_title, conn = conn)
  dolt_push(conn, branch_name = branch_name)
  Sys.sleep(2)

  # submit PR
  pr_resp <- NULL
  if (submit_pr) {
    pr_resp <- create_dolt_pr(
      title = pr_title,
      description = pr_description,
      from_branch_name = branch_name,
      from_branch_owner_name = from_branch_owner_name,
      from_branch_repo_name = from_branch_repo_name,
      to_branch_owner_name = to_branch_owner_name,
      to_branch_repo_name = to_branch_repo_name
    )
  }
  
  if (notify_slack_channel) {
    msg_resp <- send_switch_message(
      curator_id = "@rpodcast",
      curator_name = "Eric Nantz",
      issue_id = "2025-W24",
      curation_start = "2025-06-02",
      curation_end = "2025-06-08",
      switch_curator_id = "@cmpunk",
      switch_curator_name = "Phil Brooks",
      switch_issue_id = "2025-W25",
      switch_curation_start = "2025-06-09",
      switch_curation_end = "2025-06-16",
      channel = slack_channel,
      repo = get_golem_config("repo"),
      notify_user = notify_user
    )
  }

  invisible(pr_resp)
}