## code to prepare `schedule_df` dataset goes here
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

init_schedule <- function(cal_year = 2025, date_as_string = FALSE) {
  curator_df <- create_curator_df()

  from_date_min <- clock::as_naive_time(clock::year_month_day(cal_year, 1, 6))
  from_date_max <- clock::as_naive_time(clock::year_month_day(cal_year, 12, 15))
  cal_from <- seq(from_date_min, from_date_max, by = 7)

  to_date_min <- clock::as_naive_time(clock::year_month_day(cal_year, 1, 12))
  to_date_max <- clock::as_naive_time(clock::year_month_day(cal_year, 12, 21))
  cal_to <- seq(to_date_min, to_date_max, by = 7)

  # define curator sequence
  curator_primary_order <- c(
    "Batool Almazrouq",
    "Ryo Nakagawara",
    "Jon Calder",
    "Jonathan Kitt",
    "Jonathan Carroll",
    "Eric Nantz",
    "Colin Fay",
    "Sam Parmar"
  )

  curator_backup_order <- c(
    "Ryo Nakagawara",
    "Jon Calder",
    "Jonathan Kitt",
    "Jonathan Carroll",
    "Eric Nantz",
    "Colin Fay",
    "Sam Parmar",
    "Batool Almazrouq"
  )

  curator_primary_sequence <- rep(curator_primary_order, length(curator_primary_order))[1:50]
  curator_backup_sequence <- rep(curator_backup_order, length(curator_backup_order))[1:50]

  # create schedule data frame
  if (date_as_string) {
    cal_from <- as.character(cal_from)
    cal_to <- as.character(cal_to)
  } else {
    cal_from <- as.Date(cal_from)
    cal_to <- as.Date(cal_to)
  }


  curation_schedule_df <- tibble::tibble(
    from = cal_from,
    to = cal_to,
    curator = curator_primary_sequence,
    backup = curator_backup_sequence
  ) |>
    dplyr::mutate(issue_index = dplyr::row_number() + 2L) |>
    dplyr::mutate(issue_id = paste0(cal_year, "-W", sprintf("%02d", issue_index))) |>
    dplyr::select(issue_index, issue_id, from, to, curator, backup)
  
  return(curation_schedule_df)
}

schedule_df <- init_schedule()
usethis::use_data(schedule_df, overwrite = TRUE)
