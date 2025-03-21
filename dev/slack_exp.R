devtools::load_all()

library(slackr)

slackr_msg(
  txt = "Hello! Testing the ability to tag a user: @rpodcast ",
  #txt = "Hello! Testing markdown formatting: *bold* _italics_ and a custom link: <https://rweekly.org|rweekly.org>", 
  #txt = "Hello! A test message with a web link: https://rweekly.org . Nothing to see here.",
  #txt = "Hello! Another test message with an emoji :calendar: . Nothing to see here.",
  #channel = "#dev",
  channel = "#random",
  username = "rpodcast",
  token = Sys.getenv("SLACK_TOKEN")
)

debugonce(send_decline_message)
send_decline_message(
  curator_id = "@rpodcast",
  curator_name = "Eric Nantz",
  issue_id = "2025-W24",
  curation_start = "2025-06-02",
  curation_end = "2025-06-08",
  pull_id = 6
)

debugonce(send_switch_message)
send_switch_message(
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
  pull_id = 6
)

# dolthub PR url form

#https://www.dolthub.com/repositories/rpodcast/curation-schedule/pulls/6?refName=main

# https://www.dolthub.com/repositories/{repo}/pulls/{pull_id}?refName={to_branch}