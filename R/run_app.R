#' Run the Shiny Application
#' @param use_auth0 toggle to use auth0 version of app. Default is TRUE.
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  use_auth0 = TRUE,
  ...
) {
  if (use_auth0) {
    with_golem_options(
      app = auth0::shinyAppAuth0(
        ui = app_ui(),
        server = app_server,
        onStart = onStart,
        options = options,
        enableBookmarking = enableBookmarking,
        uiPattern = uiPattern,
        config_file = system.file('app/_auth0.yml', package = 'calendar.admin')
      ),
      golem_opts = list(...)
    )
  } else {
    with_golem_options(
      app = shiny::shinyApp(
        ui = app_ui,
        server = app_server,
        onStart = onStart,
        options = options,
        enableBookmarking = enableBookmarking,
        uiPattern = uiPattern
      ),
      golem_opts = list(...)
    )
  }
  
}