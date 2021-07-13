#' Download State Summaries
#'
#' Provides summary information for assess uses for an organization (State,
#' Territory or Tribe) and Integrated Reporting Cycle. The Organization ID for
#' the state, territory or tribe is required. If a Reporting Cycle isn't
#' provided, the service will return the most recent cycle. If a reporting Cycle
#' is provided, the service will return a summary for the requested cycle.
#'
#' @param organization_id (character) Organization identifier used by EPA.
#'   required
#' @param reporting_cycle (character) 4 digit reporting cycle year. Typically
#'   even numbered years. Will return reporting data for all years prior to and
#'   including the reporting cycle by reporting cycle. optional
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @importFrom dplyr select
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlang is_empty
#' @importFrom tibble as_tibble
#' @importFrom tidyr unnest_longer unnest_wider
#' @export
#'
state_summary <- function(organization_id,
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
  content <- jsonlite::fromJSON(content, simplifyVector = FALSE)

  ## grab any messages, I haven't gotten any messages so not sure this is needed
  if (is_empty(content$messages)) {
    messages <- NULL
  } else {
    messages <- content$messages
    # add to dataframe attr I think...
  }

  ## return a flat tidy dataframe
  content <- content$data %>%
    as_tibble() %>%
    unnest_wider(reportingCycles) %>%
    unnest_longer(waterTypes) %>%
    unnest_wider(waterTypes) %>%
    unnest_longer(useAttainments) %>%
    unnest_wider(useAttainments) %>%
    select(organizationIdentifier, organizationName, organizationTypeText,
           reportingCycle, waterTypeCode, unitsCode, useName,
           parameters) %>%
    unnest_longer(parameters) %>%
    unnest_wider(parameters) %>%
    clean_names()

  return(content)
}
