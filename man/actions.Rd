% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/actions.R
\name{actions}
\alias{actions}
\title{Download Actions Data}
\usage{
actions(
  action_id = NULL,
  assessment_unit_id = NULL,
  state_code = NULL,
  organization_id = NULL,
  summarize = FALSE,
  parameter_name = NULL,
  pollutant_name = NULL,
  action_type_code = NULL,
  agency_code = NULL,
  pollutant_source_code = NULL,
  action_status_code = NULL,
  completion_date_later_than = NULL,
  completion_date_earlier_than = NULL,
  tmdl_date_later_than = NULL,
  tmdl_date_earlier_then = NULL,
  last_change_later_than_date = NULL,
  last_change_earlier_than_date = NULL,
  return_count_only = FALSE,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
}
\arguments{
\item{action_id}{(character) Specifies what action to retrieve. multiple
values allowed. optional}

\item{assessment_unit_id}{(character) Filters returned actions to those
associated with the specified assessment unit identifier, plus any
statewide actions. multiple values allowed. optional}

\item{state_code}{(character) Filters returned actions to those "belonging"
to the specified state. optional}

\item{organization_id}{(character) Filter returned actions to those
"belonging" to specified organizations. multiple values allowed. optional}

\item{summarize}{(logical) If \code{TRUE} provides only a count of the
assessment units for the action and summary of the pollutants and
parameters covered by the action.}

\item{parameter_name}{(character) Filters returned actions to those
associated with the specified parameter. multiple values allowed. optional}

\item{pollutant_name}{(character) Filters returned actions to those
associated with the specified pollutant. multiple values allowed. optional}

\item{action_type_code}{(character) Filters returned actions to those
associated with the specified action type code. multiple values allowed.
optional}

\item{agency_code}{(character) Filters returned actions to those with the
specified agency code. multiple values allowed. optional}

\item{pollutant_source_code}{(character) Filters returned actions to those
matching the specified pollutant source code. multiple values allowed.
optional}

\item{action_status_code}{(character) Filters returned actions to those
matching the specified action status code. multiple values allowed.
optional}

\item{completion_date_later_than}{(character) Filters returned actions to
those with a completion date later than the value specified. Must be a
character formatted as \code{"YYYY-MM-DD"}. optional}

\item{completion_date_earlier_than}{(character) Filters returned actions to
those with a completion date earlier than the value specified. Must be a
character formatted as \code{"YYYY-MM-DD"}. optional}

\item{tmdl_date_later_than}{(character) Filters returned actions to those
with a TMDL date later than the value specified. Must be a character
formatted as \code{"YYYY-MM-DD"}. optional}

\item{tmdl_date_earlier_then}{(character) Filters returned actions to those
with a TMDL date earlier than the value specified. Must be a character
formatted as \code{"YYYY-MM-DD"}. optional}

\item{last_change_later_than_date}{(character) Filters returned actions to
those with a last change date later than the value specified. Can be used
with \code{last_change_earlier_than_date} to return actions changed within
a date range. Must be a character formatted as \code{"YYYY-MM-DD"}.
optional}

\item{last_change_earlier_than_date}{(character) Filters returned actions to
those with a last change date earlier than the value specified. Can be used
with \code{last_change_later_than_date} to return actions changed within a
date range. Must be a character formatted as \code{"YYYY-MM-DD"}. optional}

\item{return_count_only}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}
\code{return_count_only = TRUE} is no longer supported.}

\item{tidy}{(logical) \code{TRUE} (default) the function returns a tidied
tibble. \code{FALSE} the function returns the raw JSON string.}

\item{.unnest}{(logical) \code{TRUE} (default) the function attempts to unnest
data to longest format possible. This defaults to \code{TRUE} for backwards
compatibility but it is suggested to use \code{FALSE}.}

\item{...}{list of curl options passed to \code{\link[crul:HttpClient]{crul::HttpClient()}}}
}
\value{
If \code{tidy = FALSE} the raw JSON string is returned, else the
JSON data is parsed and returned as tibbles.
}
\description{
Provides data about actions (TMDLs, 4B Actions, Alternative Actions,
Protection Approach Actions) that have been finalized.
}
\details{
One or more of the following arguments must be included:
\code{action_id}, \code{assessment_unit_id}, \code{state_code} or
\code{organization_id}. Multiple values are allowed for indicated arguments
and should be included as a comma separated values in the string (eg.
\code{organization_id="TCEQMAIN,DCOEE"}).
}
\note{
See \link{domain_values} to search values that can be queried.
}
\examples{
\dontrun{

## Look up an individual action
actions(action_id = "R8-ND-2018-03")
## Get the JSON instead
actions(action_id = "R8-ND-2018-03", tidy = FALSE)
}
}
