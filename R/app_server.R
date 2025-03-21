#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  # reactive values
  reset_table_selection_rv <- reactiveVal(NULL)
  reset_switch_table_selection_rv <- reactiveVal(NULL)

  # import schedule data from public API endpoint
  raw_schedule_df <- import_schedule_data()

  # import curator data from public API endpoint
  raw_curator_df <- import_curator_data()
  
  user_info <- reactive({
    get_user_info(raw_curator_df, session)
  })

  # dynamically render appropriate UI based on logged in user
  output$logged_in_ui <- renderUI({
    # obtain information on user
    req(user_info())
    if (valid_team(user_info()$team_id)) {
      ui_valid()
    } else {
      ui_not_valid()
    }
  })

  # execute user authentication information module
  user_info <- mod_auth_info_server("auth_info_1", raw_curator_df)

  # reactive for tab selected
  tab_selected <- reactive({
    req(input$tab_selected)
    input$tab_selected
  })

  # reactive for filter selection
  selected_display <- reactive({
    req(input$curator_filter)
    if (input$curator_filter == "all") {
      return(NULL)
    } else {
      req(user_info())
      return(user_info()$name)
    }
  })

  # reactive for schedule_df
  schedule_df <- reactive({
    if (is.null(selected_display())) {
      return(raw_schedule_df)
    } else {
      df <- raw_schedule_df |>
        dplyr::filter(curator == selected_display())
      return(df)
    }
  })

  # execute calendar view module
  mod_calendar_server("calendar_1", schedule_df, raw_curator_df, default_date_rv = reactive(NULL))

  # execute table view module
  table_issue_selected <- mod_table_server("table_1", schedule_df, raw_curator_df, reset_selection = reset_table_selection_rv)

  # reactive for selected issue
  issue_selected_df <- reactive({
    selection_df <- table_issue_selected()
    return(selection_df)
  })

  # reactive for schedule df after selected issue
  post_schedule_df <- reactive({
    req(issue_selected_df())
    df <- raw_schedule_df |>
      dplyr::filter(issue_index > issue_selected_df()$issue_index)
    return(df)
  })

  default_date_rv <- reactive({
    req(issue_selected_df())
    new_date <- raw_schedule_df |>
      dplyr::filter(issue_index == issue_selected_df()$issue_index) |>
      dplyr::pull(from)
    return(new_date)
  })

  # reactive indicator of selected curator
  same_curator <- reactive({
    req(issue_selected_df())
    req(user_info())
    user_info()$name == issue_selected_df()$curator
  })

  output$current_issue_selected <- renderUI({
    if (is.null(issue_selected_df())) {
      msg <- "Please select one of your issues"
    } else {
      if (!same_curator()) {
        msg <- "Please select one of your issues"
      } else {
        msg <- glue::glue(
          "Selection: {issue_selected_df()$issue_id}"
        )
      }
    }
    return(msg)
  })

  # show pop-up modal for declining curation
  observeEvent(input$decline_curation, {
    #req(issue_selected_df())
    if (is.null(issue_selected_df())) {
      shiny::showNotification(
        "Please select your own curation",
        type = "error"
      )
      return(NULL)
    }
    if (!same_curator()) {
      shiny::showNotification(
        "Please select your own curation",
        type = "error"
      )
      return(NULL)
    }
    shiny::showModal(
      shiny::modalDialog(
        title = "Decline Curation",
        tagList(
          htmltools::tags$p("You have selected the following issue to decline your curation:"),
          htmltools::tags$br(),
          htmltools::tags$p(
            glue::glue(
              "Issue {issue_selected_df()$issue_id} with curation period from {issue_selected_df()$from} to {issue_selected_df()$to}"
            )
          )
        ),
        size = "l",
        footer = tagList(
          modalButton("Cancel"),
          actionButton(
            "decline_confirm",
            "OK"
          )
        )
      )
    )
  })

  # show pop-up modal for proposing curation switch
  observeEvent(input$switch_curation, {
    if (is.null(issue_selected_df())) {
      shiny::showNotification(
        "Please select your own curation",
        type = "error"
      )
      return(NULL)
    }
    if (!same_curator()) {
      shiny::showNotification(
        "Please select your own curation",
        type = "error"
      )
      return(NULL)
    }
    shiny::showModal(
      shiny::modalDialog(
        title = "Propose Curation Switch",
        tagList(
          tags$h4("Select a curation to switch"),
          tags$h4(glue::glue("Original selection: {issue_selected_df()$issue_id}")),
          layout_columns(
            navset_card_tab(
              id = "switch_tab_selected",
              selected = "table",
              title = "Schedule Viewer",
              nav_panel(
                title = "Calendar",
                value = "calendar",
                mod_calendar_ui("calendar_2")
              ),
              nav_panel(
                title = "Table",
                value = "table",
                mod_table_ui("table_2")
              )
            )
          )
        ),
        size = "xl",
        footer = tagList(
          modalButton("Cancel"),
          actionButton(
            "switch_confirm",
            "OK"
          )
        )
      )
    )
  })

  # execute calendar view module
  mod_calendar_server("calendar_2", post_schedule_df, raw_curator_df, default_date_rv)

  # execute table view module
  switch_table_issue_selected <- mod_table_server("table_2", post_schedule_df, raw_curator_df, reset_switch_table_selection_rv)

  # reactive for selected issue
  switch_issue_selected_df <- reactive({
    selection_df <- switch_table_issue_selected()
    return(selection_df)
  })

  # process curation decline
  observeEvent(input$decline_confirm, {
    shiny::removeModal()

    shiny::showNotification(
      "Processing ...",
      duration = NULL,
      id = "decline_process"
    )

    conn <- create_dolt_conn(
      dolt_local = get_golem_config("dolt_local"),
      repo = get_golem_config("repo")
    )

    submit_decline(
      conn = conn,
      schedule_df = raw_schedule_df,
      curator_df = raw_curator_df,
      issue_selected_df = issue_selected_df(),
      to_branch_name = get_golem_config("to_branch"),
      from_branch_owner_name = get_golem_config("from_owner"),
      from_branch_repo_name = get_golem_config("from_repo_name"),
      to_branch_owner_name = get_golem_config("to_owner"),
      to_branch_repo_name = get_golem_config("to_repo_name"),
      notify_slack_channel = TRUE,
      slack_channel = get_golem_config("slack_channel")
    )

    shiny::removeNotification("decline_process")
    shiny::showNotification(
      "Submission successful!",
      type = "success"
    )

    reset_table_selection_rv(runif(1))
  })

  # process curation switch
  observeEvent(input$switch_confirm, {
    shiny::removeModal()
    shiny::showNotification(
      "Processing ...",
      duration = NULL,
      id = "switch_process"
    )

    conn <- create_dolt_conn(
      dolt_local = get_golem_config("dolt_local"),
      repo = get_golem_config("repo")
    )

    submit_switch(
      conn = conn,
      schedule_df = raw_schedule_df,
      curator_df = raw_curator_df,
      issue_selected_df = issue_selected_df(),
      switch_issue_selected_df = switch_issue_selected_df(),
      to_branch_name = get_golem_config("to_branch"),
      from_branch_owner_name = get_golem_config("from_owner"),
      from_branch_repo_name = get_golem_config("from_repo_name"),
      to_branch_owner_name = get_golem_config("to_owner"),
      to_branch_repo_name = get_golem_config("to_repo_name"),
      notify_slack_channel = TRUE,
      slack_channel = get_golem_config("slack_channel")
    )

    shiny::removeNotification("switch_process")
    shiny::showNotification(
      "Request submitted!",
      type = "default"
    )
    reset_switch_table_selection_rv(runif(1))
    reset_table_selection_rv(runif(1))
  })
}
