#' Download State Summaries
#'
#' Provides summary information for assess uses for an organization (State,
#' Territory or Tribe) and Integrated Reporting Cycle. The Organization ID for
#' the state, territory or tribe is required. If a Reporting Cycle isn't
#' provided, the service will return the most recent cycle. If a reporting Cycle
#' is provided, the service will return a summary for the requested cycle.
#'
#' @param organization_id character
#' @param reporting_cycle character
#' @param ... list of curl options passed to crul::HttpClient()
#'
#' @return tibble
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @export
#'
dl_state_summary <- function(organization_id,
                             reporting_cycle = NULL,
                             ...) {
  ## this logic doesn't work for building url
  ## still returns different reporting years

  # Check that organization_id is character
  if(!is.character(organization_id)) {
    stop("organization_id must be character")
  }

  args = list(organizationId = organization_id)

  # Check that reporting cycle is character or NULL
  if(!is.character(reporting_cycle)) {
    if(!is.null(reporting_cycle)) {
      stop("organization_id must be character or NULL")
    }

    args = list(organizationId = organization_id,
                reportingCycle = reporting_cycle)
  }

  path = "attains-public/api/usesStateSummary"

  content <- xGET(path, args, ...)

  ## parse the returned json
  content <- jsonlite::fromJSON(content)

  return(content)
}
