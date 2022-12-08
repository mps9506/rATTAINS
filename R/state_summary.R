#' Download State Summaries
#'
#' @description  Provides summary information for assessed uses for an organization (State,
#' Territory or Tribe) and Integrated Reporting Cycle. The Organization ID for
#' the state, territory or tribe is required. If a Reporting Cycle isn't
#' provided, the service will return the most recent cycle. If a reporting Cycle
#' is provided, the service will return a summary for the requested cycle.
#'
#' @param organization_id (character) Restricts results to the specified
#'   organization. required
#' @param reporting_cycle (character) Filters the returned results to the
#'   specified 4 digit reporting cycle year. Typically even numbered years. Will
#'   return reporting data for all years prior to and including the reporting
#'   cycle by reporting cycle. optional
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @import tidyjson
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr select mutate
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom purrr map flatten_dbl flatten_chr
#' @importFrom rlang is_empty .data
#' @importFrom tibble as_tibble tibble
#' @importFrom tidyr unnest_longer unnest_wider
#' @export
#' @examples
#'
#' \dontrun{
#' ## Get a list of tibbles summarizing assessed uses
#' state_summary(organization_id = "TDECWR", reporting_cycle = "2016")
#'
#' ## Returns the query as a JSON string instead
#' state_summary(organization_id = "TDECWR", reporting_cycle = "2016", tidy = FALSE)
#' }
#'
state_summary <- function(organization_id = NULL,
                          reporting_cycle = NULL,
                          tidy = TRUE,
                          ...) {

  ## check connectivity
  check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(organization_id, reporting_cycle),
         .var.name = c("organization_id", "reporting_cycle"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)


  ## check that required args are present
  args <- list(organizationId = organization_id,
               reportingCycle = reporting_cycle)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: organization_id")
  }
  path <- "attains-public/api/usesStateSummary"

  ## download data without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)


  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else {## return parsed data
    content <- content %>%
      enter_object("data") %>%
      spread_values(organizationIdentifier = jstring("organizationIdentifier"),
                    organizationName = jstring("organizationName"),
                    organizationTypeText = jstring("organizationTypeText")) %>%
      select(-c(.data$document.id)) %>%
      enter_object("reportingCycles") %>%
      gather_array() %>%
      spread_values(reportingCycle = jstring("reportingCycle"),
                    combinedCycles = jstring("combinedCycles")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("waterTypes") %>%
      gather_array() %>%
      spread_values(waterTypeCode = jstring("waterTypeCode"),
                    unitsCode = jstring("unitsCode")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("useAttainments") %>%
      gather_array() %>%
      spread_values(useName = jstring("useName"),
                    fullySupporting = jstring("Fully Supporting"),
                    fullySupportingCount = jstring("Fully Supporting-count"),
                    notAssessed = jstring("Not Assessed"),
                    notAssessedCount = jstring("Not Assessed-count")) %>%
      select(-c(.data$array.index)) %>%
      mutate(parameters = map(.data$..JSON, ~{
        .x[["parameters"]] %>% {
          tibble(parameterGroup = map(., "parameterGroup", .default = NA) %>% flatten_chr(),
                 cause = map(., "Cause", .default = NA) %>% flatten_chr(),
                 causeCount = map(., "Cause-count", .default = NA) %>% flatten_chr(),
                 meetingCriteria = map(., "Meeting Criteria", .default = NA) %>% flatten_dbl(),
                 meetingCriteriaCount = map(., "Meeting Criteria-count", .default = NA) %>% flatten_dbl(),
                 insufficentInformation = map(., "Insufficient Information", .default = NA) %>% flatten_dbl(),
                 insufficientInformationCount = map(., "Insufficient Information-count", .default = NA) %>% flatten_dbl()) %>%
            clean_names()
        }
      })) %>%
      as_tibble() %>%
      clean_names()

    return(content)
  }

}
