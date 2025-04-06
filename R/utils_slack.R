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