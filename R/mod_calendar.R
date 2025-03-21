#' calendar UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_calendar_ui <- function(id) {
  ns <- NS(id)
  tagList(
    toastui::calendarOutput(ns("calendar"))
  )
}
    
#' calendar Server Functions
#'
#' @noRd 
mod_calendar_server <- function(id, schedule_df, curator_df, default_date_rv = NULL) {
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    processed_cal_data <- reactive({
      req(schedule_df())
      process_cal_data(schedule_df(), curator_df)
    })

    output$calendar <- toastui::renderCalendar({
      req(processed_cal_data())
      toastui::calendar(
        data = processed_cal_data(),
        view = "month",
        defaultDate = default_date_rv(),
        navigation = TRUE,
        useDetailPopup = FALSE,
        useCreationPopup = FALSE
      ) |>
        toastui::cal_month_options(
          startDayOfWeek = 1,
          narrowWeekend = FALSE
        )
    })

    # reactive for calendar click event
    issue_selected <- reactive({
      req(input$calendar_click)
      curator <- input$calendar_click$raw
      start_date <- lubridate::date(input$calendar_click$start$d$d) |> as.character()
      end_date <- lubridate::date(input$calendar_click$end$d$d) |> as.character()

      df <- schedule_df() |>
        dplyr::filter(
          curator == !!curator,
          from >= !!start_date,
          to <= !!end_date
        )
      return(df)
    })
  })
}
    
## To be copied in the UI
# mod_calendar_ui("calendar_1")
    
## To be copied in the server
# mod_calendar_server("calendar_1")
