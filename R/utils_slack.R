get_slack_users <- function(token = Sys.getenv("SLACK_TOKEN")) {
  df <- slackr::slackr_users(token = token)
  return(df)
}

send_decline_message <- function(
  curator_id, 
  curator_name,
  backup_id,
  backup_name,
  issue_id,
  curation_start,
  curation_end,
  channel = "#random",
  channel_string = "channel",
  username = "rweeklycalbot",
  repo = "rpodcast/curation-schedule",
  to_branch = "main",
  notify_user = TRUE
) {
  if (notify_user) {
    channel_string <- paste0("@", channel_string)
    curator_id <- paste0("@", curator_id)
    backup_id <- paste0("@", backup_id)
  }
  msg <- glue::glue("
    Greetings, {channel_string}! Curator {curator_name} ({curator_id}) is not able to curate the R Weekly issue {issue_id} covering the date range {curation_start} to {curation_end}.
    - Hi {backup_name} ({backup_id}), you are listed as the backup curator for the issue. Would you be able to curate issue {issue_id}?")
  
  if (channel == "#random") {
    msg <- paste("TESTING MESSAGE ONLY! Please disregard :smile: .", msg)
  }
  slackr::slackr_msg(
    txt = msg,
    channel = channel,
    username = username,
    token = Sys.getenv("SLACK_TOKEN")
  )
}

send_switch_message <- function(
  curator_id, 
  curator_name,
  issue_id,
  curation_start,
  curation_end,
  switch_curator_id,
  switch_curator_name,
  switch_issue_id,
  switch_curation_start,
  switch_curation_end,
  channel = "#random",
  channel_string = "channel",
  username = "rweeklycalbot",
  repo = "rpodcast/curation-schedule",
  to_branch = "main",
  notify_user = TRUE
) {
  if (notify_user) {
    channel_string <- paste0("@", channel_string)
    curator_id <- paste0("@", curator_id)
    switch_curator_id <- paste0("@", switch_curator_id)
  }
  msg <- glue::glue("
    Greetings, {channel_string}! Curator {curator_name} ({curator_id}) is not able to curate the R Weekly issue {issue_id} covering the date range {curation_start} to {curation_end}.
    - Hi {switch_curator_name} ({switch_curator_id}). {curator_name} would like to switch with your curation of R Weekly issue {switch_issue_id} covering the date range {switch_curation_start} to {switch_curation_end}.
    Are you able to switch issues?")
  
  if (channel == "#random") {
    msg <- paste("TESTING MESSAGE ONLY! Please disregard :smile: .", msg)
  }

  slackr::slackr_msg(
    txt = msg,
    channel = channel,
    username = username,
    token = Sys.getenv("SLACK_TOKEN")
  )
}

#' Send current issue curation reminder in Slack
#' 
#' @param current_issue_id String of issue identifier in YYYY-WXX format
#' @param curator_id String with the Slack ID of scheduled issue curator
#' @param curator_name String with full name of scheduled issue curator
#' @param backup_id String with the Slack ID of the scheduled issue backup
#' @param backup_name String with the full name of the scheduled issue backup
#' @param channel String with the Slack channel for the message. Default is `#random`.
#' @param username String iwth the Slack ID of the bot. Default is `rweeklycalbot`.
#' @param notify_user Indicator for tagging (notifying) any users mentioned in the 
#'   message. Default is `TRUE`.
#' @export
#' @return Nothing, used for the message side effect
send_reminder_message <- function(
  current_issue_id,
  curator_id, 
  curator_name,
  backup_id,
  backup_name,
  channel = "#random",
  username = "rweeklycalbot",
  notify_user = TRUE
) {
  if (notify_user) {
    curator_id <- paste0("@", curator_id)
    backup_id <- paste0("@", backup_id)
  }

  msg <- glue::glue("
    Beep Beep! This is the R Weekly Calendar Bot with a friendly reminder for the upcoming issue {current_issue_id}:
    - {curator_name} {curator_id} is the curator for this issue.
    - {backup_name} {backup_id} is the backup curator for this issue.")
  
  if (channel == "#random") {
    msg <- paste("TESTING MESSAGE ONLY! Please disregard :smile: .", msg)
  }

  slackr::slackr_msg(
    txt = msg,
    channel = channel,
    username = username,
    token = Sys.getenv("SLACK_TOKEN")
  )
}