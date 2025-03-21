## code to prepare `curator_df` dataset goes here
create_curator_df <- function(add_slack_id = TRUE, keep_email = FALSE) {
  curator_df <- tibble::tribble(
    ~real_name, ~short_name, ~calendar_color, ~name_color, ~email_address, ~picture,
    "Sam Parmar", "parmsam", "#800080", "#ffffff", "parmartsam@gmail.com", "https://github.com/parmsam.png",
    "Batool Almazrouq", "BatoolMM", "#f0e68c", "#000000", "batool@liverpool.ac.uk", "https://github.com/BatoolMM.png",
    "Ryo Nakagawara", "Ryo-N7", "#4682b4", "#ffffff", "ryonakagawara@gmail.com", "https://github.com/Ryo-N7.png",
    "Jon Calder", "jonmcalder", "#cd5c5c", "#ffffff", "jonmcalder@gmail.com", "https://github.com/jonmcalder.png",
    "Jonathan Kitt", "Jonathan Kitt", "#adff2f", "#000000", "jonathan.kitt@proton.me", "https://github.com/KittJonathan.png",
    "Jonathan Carroll", "jonocarroll", "#ffa500", "#000000","jono@jcarroll.com.au", "https://github.com/jonocarroll.png",
    "Eric Nantz", "rpodcast", "#191970", "#ffffff", "theRcast@gmail.com", "https://github.com/rpodcast.png",
    "Colin Fay", "ColinFay", "#ffff00", "#000000", "contact@colinfay.me", "https://github.com/ColinFay.png"
  )

  if (add_slack_id) {
    curator_df <- curator_df |>
      dplyr::left_join(
        get_slack_users() |> dplyr::select(id, real_name, image_32, image_48),
        by = "real_name"
      )
  }

  if (!keep_email) {
    curator_df <- curator_df |>
      dplyr::select(-email_address)
  }
  
  return(curator_df)
}

get_slack_users <- function(token = Sys.getenv("SLACK_TOKEN")) {
  df <- slackr::slackr_users(token = token)
  return(df)
}

curator_df <- create_curator_df()

usethis::use_data(curator_df, overwrite = TRUE)
