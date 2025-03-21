#' table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    reactable::reactableOutput(ns("table")),
    verbatimTextOutput(ns("state"))
  )
}
    
#' table Server Functions
#'
#' @noRd 
mod_table_server <- function(id, schedule_df, curator_df, reset_selection = NULL){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    output$table <- reactable::renderReactable({
      req(schedule_df())
      create_schedule_table(schedule_df(), curator_df)
    })

    output$state <- renderPrint({
      state <- req(reactable::getReactableState("table"))
      print(state)
    })

    # reactive for selected entry
    issue_selected <- reactive({
      req(schedule_df())
      state_ind <- reactable::getReactableState("table")
      if (is.null(state_ind)) {
        return(NULL)
      } else {
        if (is.null(state_ind$selected)) {
          return(NULL)
        } else {
          selected <- reactable::getReactableState("table", "selected")
          req(selected)
          return(dplyr::slice(schedule_df(), selected))
        }

      }
    })

    observeEvent(reset_selection(), {
      if (!is.null(reset_selection())) {
        reactable::updateReactable("table", selected = NA)
      }
    })

    issue_selected
  })
}
    
## To be copied in the UI
# mod_table_ui("table_1")
    
## To be copied in the server
# mod_table_server("table_1")
