#' auth_info UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList verbatimTextOutput
mod_auth_info_ui <- function(id) {
  ns <- NS(id)
  tagList(
    htmlOutput(ns("user_display"))
    #verbatimTextOutput(ns("user_info"))
  )
}

#' auth_info Server Functions
#'
#' @noRd 
mod_auth_info_server <- function(id, curator_df){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    user_info <- reactive({
      get_user_info(curator_df, session)
    })

    output$user_display <- renderUI({
      req(user_info())
      tagList(
        htmltools::div(
          #class = "welcome-container",
          class = "sidebar-title",
          htmltools::tags$img(src = user_info()$picture, alt = "User Picture", class = "profile-pic"),
          htmltools::span(
            class = "welcome-text",
            glue::glue("Welcome, {user_info()$short_name}!")
          )
        )
        #htmltools::tags$img(user_info()$picture),
        #htmltools::tags$p(user_info()$name)
      )
    })

    # return user_info reactive
    user_info
  })
}
    
## To be copied in the UI
# mod_auth_info_ui("auth_info_1")
    
## To be copied in the server
# mod_auth_info_server("auth_info_1")
