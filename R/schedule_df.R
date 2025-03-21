#' R Weekly Schedule Data Set
#' 
#' A data frame of the current R Weekly curation schedule. Note that this data set is only
#' included for testing purposes, as the upstream version of the data is 
#' imported from Dolthub.
#' 
#' @format ## `schedule_df`
#' A data frame with 50 rows and 6 columns
#' \describe{
#' \item{issue_index}{Integer with issue index}
#' \item{issue_id}{String with the issue ID, in format YYYY-WXX}
#' \item{from}{Date with the start of the issue curation period}
#' \item{to}{Date with the end of the issue curation period}
#' \item{curator}{Name of the issue curator}
#' \item{backup}{Name of the issue backup curator}
#' }
#' @source <https://www.dolthub.com/repositories/rweekly-org/curation-schedule>
"schedule_df"