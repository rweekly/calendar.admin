parse_auth_string <- function(string) {
  # format of string is oauth2|sign-in-with-slack|TEAMID-USERID888
  # split on |
  parts <- strsplit(string, "\\|")[[1]]
  team_user_string <- strsplit(parts[3], "-")[[1]]
  team_id <- team_user_string[1]
  user_id <- team_user_string[2]
  return(list(team_id = team_id, user_id = user_id))
}

valid_team <- function(team_id) {
  return(team_id == Sys.getenv("SLACK_TEAM_ID"))
}

get_user_info <- function(curator_df, session = shiny::getDefaultReactiveDomain()) {
  if (getOption("auth0_disable")) {
    auth_string <- list(
      sub = glue::glue("oauth2|sign-in-with-slack|{Sys.getenv('SLACK_TEAM_ID')}-{Sys.getenv('SLACK_TEST_USER_ID')}"),
      nickname = "rpodcast",
      name = "Eric Nantz",
      picture = "https://shinydevseries-assets.us-east-1.linodeobjects.com/megaman.png",
      updated_at = "2025-01-01T01:00:00.000Z"
    )
  } else {
    auth_string <- session$userData$auth0_info
  }
  user_info <- curator_df |>
    dplyr::filter(id == parse_auth_string(auth_string$sub)$user_id)

  info <- list(
    team_id = parse_auth_string(auth_string$sub)$team_id,
    user_id = parse_auth_string(auth_string$sub)$user_id,
    name = user_info$real_name,
    short_name = user_info$short_name,
    picture = user_info$image_32
  )

  return(info)
}