% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import.R
\name{import_schedule_data}
\alias{import_schedule_data}
\title{Import R Weekly curation schedule data}
\usage{
import_schedule_data(
  query = "SELECT * FROM schedule",
  from_owner = "rweekly-org",
  from_repo_name = "curation-schedule"
)
}
\arguments{
\item{query}{String with the SQL querty to execute on Dolthub. Default is
the string `SELECT * FROM schedule` which simply returns all rows of the 
table.}

\item{from_owner}{String with the Dolthub owner of the database. Default is
`rweekly-org`.}

\item{from_repo_name}{String with the name of the repository containing the
database. Default is `curation-schedule`.}
}
\value{
data frame of the R Weekly schedule data
}
\description{
Obtain the current version of the R Weekly curation schedule metadata
from the R Weekly Dolthub repository
}
