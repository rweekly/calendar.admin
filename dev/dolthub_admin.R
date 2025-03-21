library(doltr)
library(dplyr)
devtools::load_all()

# change Batool name in schedule df
# - from: Batool Almarzouq
# - to: Batool Almazrouq


# establish dolt connection
repo <- "rweekly-org/curation-schedule"
#repo <- "rpodcast/curation_schedule"
conn <- create_dolt_conn(dolt_local = FALSE, repo = repo)


# try to figure out dolt diff situation
schedule_db <- tbl(conn, "schedule")

# create curator data from public API endpoint
curator_df <- import_curator_data()

# create curator data from DBI instance
#curator_df2 <- DBI::dbGetQuery(conn, "SELECT * FROM curator_df")

# create schedule data from public API endpoint
schedule_df <- import_schedule_data(from_owner = "rweekly-org", from_repo_name = "curation-schedule")

selected_issue_df <- schedule_df |>
  dplyr::slice(21)

submit_decline(
  conn = conn,
  schedule_df = schedule_df,
  issue_selected_df = selected_issue_df,
  from_branch_owner_name = "rpodcast",
  from_branch_repo_name = "playground",
  to_branch_owner_name = "rpodcast",
  to_branch_repo_name = "playground"
)


# create schedule data from DBI instance
#schedule_df2 <- DBI::dbGetQuery(conn, "SELECT * FROM schedule")  

#schedule_df2_backup <- schedule_df2

# schedule_df2 <- schedule_df2 |>
#   dplyr::mutate(curator = ifelse(curator == "Batool Almarzouq", "Batool Almazrouq", curator)) |>
#   dplyr::mutate(backup = ifelse(backup == "Batool Almarzouq", "Batool Almazrouq", backup))


# create new branch
dolt_checkout(branch = "namefix",  b = TRUE, conn = conn)
dolt_checkout(branch = "namefix", conn = conn)

# add table to connection
dbWriteTable(conn, "schedule", schedule_df2, overwrite = TRUE)
dolt_add("schedule", conn = conn)
dolt_status(conn)


dolt_branches(conn = conn)

dolt_commit(message = "update Batool to match slack version", conn = conn)
dolt_status(conn)

push <- function(branch, conn) {
  query <- sprintf("CALL DOLT_PUSH('--set-upstream', 'origin', '%s')", paste(branch))
  DBI::dbGetQuery(conn, query)
}

push("namefix", conn)


create_dolt_pr(
  title = "Fix curator name",
  description = "Update Batool name to match version stored in Slack, otherwise merging operations fail",
  from_branch_name = "namefix",
  from_branch_owner_name = "rweekly-org",
  from_branch_repo_name = "curation-schedule",
  to_branch_owner_name = "rweekly-org",
  to_branch_repo_name = "curation-schedule",
  to_branch_name = "main"
)