#' R Weekly Curator Data Set
#' 
#' A data frame of the current R Weekly curators. Note that this data set is only
#' included for testing purposes, as the upstream version of the data is 
#' imported from Dolthub.
#' 
#' @format ## `curator_df`
#' A data frame with 8 rows and 8 columns
#' \describe{
#' \item{real_name}{Curator full name}
#' \item{short_name}{Curator Slack user name}
#' \item{calendar_color}{Color for the curator's calendar entry cell background color in hex format}
#' \item{name_color}{Color for the curator's calendar entry font color in hex format}
#' \item{picture}{URL of the curator picture}
#' \item{id}{Curator Slack user ID}
#' \item{image_32}{URL of the curator 32x32 image in Slack}
#' \item{image_48}{URL of the curator 48x48 image in Slack}
#' }
#' @source <https://www.dolthub.com/repositories/rweekly-org/curation-schedule>
"curator_df"