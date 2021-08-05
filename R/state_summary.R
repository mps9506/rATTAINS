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
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr select
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlang is_empty .data
#' @importFrom tibble as_tibble
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
  state_cache <- hoardr::hoard()
  path <- "attains-public/api/usesStateSummary"
  file <- file_key(path = path, arg_list = args)
  state_cache$cache_path_set(path = file)
  state_cache$mkdir()

  ## check if current results have been cached
  file_name <- file.path(state_cache$cache_path_get(),
                         "state_summary.json")
  if(file.exists(file_name)) {
    message(paste0("reading cached file from: ", file_name))
    content <- readLines(file_name, warn = FALSE)
  } else { ## download data
    content <- xGET(path, args, ...)
  }
  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else {## return parsed data
    ## parse the returned json
    content <- jsonlite::fromJSON(content, simplifyVector = FALSE)

    ## return a flat tidy dataframe
    content <- content$data %>%
      as_tibble() %>%
      unnest_wider(.data$reportingCycles) %>%
      unnest_longer(.data$waterTypes) %>%
      unnest_wider(.data$waterTypes) %>%
      unnest_longer(.data$useAttainments) %>%
      unnest_wider(.data$useAttainments) %>%
      select(.data$organizationIdentifier, .data$organizationName, .data$organizationTypeText,
             .data$reportingCycle, .data$waterTypeCode, .data$unitsCode, .data$useName,
             .data$parameters) %>%
      unnest_longer(.data$parameters) %>%
      unnest_wider(.data$parameters) %>%
      clean_names()

    return(content)
  }

}
