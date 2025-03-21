options(
  shiny.port = 2557,
  shiny.host = '0.0.0.0',
  auth0_config_file = system.file('app/_auth0.yml', package = 'calendar.admin'),
  auth0_disable = FALSE
)
library(calendar.admin)
calendar.admin::run_app()