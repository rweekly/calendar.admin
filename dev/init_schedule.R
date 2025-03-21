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
    "Batool Alamazrouq",
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
    "Batool Alamazrouq"
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