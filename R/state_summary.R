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
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
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
#'
state_summary <- function(organization_id,
                          reporting_cycle = NULL,
                          tidy = TRUE,
                          ...) {

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

  ##setup file cache
  path <- "attains-public/api/usesStateSummary"
  state_cache$mkdir()

  ## check if current results have been cached
  file_cache_name <- file_key(arg_list = args,
                              name = "state_summary.json")
  file_path_name <- fs::path(state_cache$cache_path_get(),
                             file_cache_name)

  if(file.exists(file_path_name)) {
    message(paste0("reading cached file from: ", file_path_name))
    content <- readLines(file_path_name, warn = FALSE)
  } else { ## download data
    content <- xGET(path,
                    args,
                    file = file_path_name,
                    ...)
  }
  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else {## return parsed data
    content <- content$data %>%
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
