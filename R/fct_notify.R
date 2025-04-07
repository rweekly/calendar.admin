
#' Obtain the current R Weekly issue metadata
#' 
#' @param schedule_df data frame of the R Weekly schedule of curation
#' @param curator_df data frame of current R Weekly curators
#' @param current_date string with the current date, default is `Sys.Date()`
#' @return list with the following components:
#' * `current_issue_id`: String of issue identifier in YYYY-WXX format
#' * `curator_name`: String with full name of scheduled issue curator
#' * `curator_id`: String with the Slack ID of scheduled issue curator
#' * `backup_name`: String with the full name of the scheduled issue backup
#' * `backup_id`: String with the Slack ID of the scheduled issue backup
#' @export
current_issue_metadata <- function(schedule_df, curator_df, current_date = Sys.Date()) {
  current_issue_df <- schedule_df |>
    dplyr::filter(current_date >= from & current_date <= to)

  current_curator_name <- current_issue_df$curator
  current_backup_name <- current_issue_df$backup

  current_curator_id <- curator_df |>
    dplyr::filter(real_name == current_curator_name) |>
    dplyr::pull(short_name)

  current_backup_id <- curator_df |>
    dplyr::filter(real_name == current_backup_name) |>
    dplyr::pull(short_name)

  return(
    list(
      current_issue_id = current_issue_df$issue_id,
      curator_name = current_curator_name,
      curator_id = current_curator_id,
      backup_name = current_backup_name,
      backup_id = current_backup_id
    )
  )
}

#' Driver function to send issue reminder
#' 
#' This function is intended to be used in an automated step such as a 
#' GitHub action. It is simply a wrapper around the functions to obtain
#' the upcoming issue metadata and sending the notification in Slack.
#' 
#' @param channel String with the Slack channel for the message. Default is `#dev`.
#' @param notify_user Indicator for tagging (notifying) any users mentioned in the 
#'   message. Default is `TRUE`.
#' @export
reminder_driver <- function(channel = "#dev", notify_user = TRUE) {
  current_issue_list <- current_issue_metadata(
    schedule_df = import_schedule_data(),
    curator_df = import_curator_data()
  )
  
  send_reminder_message(
    current_issue_id = current_issue_list$current_issue_id,
    curator_id = current_issue_list$curator_id,
    curator_name = current_issue_list$curator_name,
    backup_id = current_issue_list$backup_id,
    backup_name = current_issue_list$backup_name,
    channel = channel,
    notify_user = notify_user
  )
}