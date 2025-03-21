#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    uiOutput("logged_in_ui")
  )
}

#' @import shiny
#' @import bslib
ui_valid <- function() {
  tagList(
    page_sidebar(
      window_title = "rwcalendar-admin",
      title = "R Weekly Curation Calendar Admin",
      sidebar = sidebar(
        title = mod_auth_info_ui("auth_info_1"),
        width = 300,
        radioButtons(
          "curator_filter",
          label = "Display Entries",
          choices = c("Only mine" = "me", "All" = "all"),
          selected = "all",
          inline = TRUE
        ),
        uiOutput("current_issue_selected"),
        actionButton(
          "decline_curation",
          label = "Decline Curation"
        ),
        actionButton(
          "switch_curation",
          label = "Propose Switch"
        ),
        auth0::logoutButton()
      ),
      layout_columns(
        card(
          card_header("R Weekly Curation Calendar Admin App"),
          card_body(
            htmltools::includeMarkdown(app_sys("app", "doc", "description.md"))
          )
        )
      ),
      layout_columns(
        navset_card_tab(
          id = "tab_selected",
          selected = "table",
          title = "Schedule Viewer",
          nav_panel(
            title = "Calendar",
            value = "calendar",
            mod_calendar_ui("calendar_1")
          ),
          nav_panel(
            title = "Table",
            value = "table",
            mod_table_ui("table_1")
          )
        )
      )
    )
  )
}

ui_not_valid <- function() {
  tagList(
    h1("Sorry, you are not part of the team and cannot proceed")
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "calendar.admin"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
