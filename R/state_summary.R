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
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom jsonlite fromJSON
#' @importFrom rlang is_empty .data
#' @importFrom rlist list.filter
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
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
                          .unnest = TRUE,
                          ...) {

  ## check connectivity
  con_check <- check_connectivity()
  if(!isTRUE(con_check)){
    return(invisible(NULL))
  }

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(organization_id, reporting_cycle),
         .var.name = c("organization_id", "reporting_cycle"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(tidy, .unnest),
         .var.name = c("tidy", ".unnest"),
         MoreArgs = list(null.ok = FALSE,
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

  ## download data
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)


  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else {## return parsed data

    ## parse json
    json_list <- jsonlite::fromJSON(content,
                                    simplifyVector = FALSE,
                                    simplifyDataFrame = FALSE,
                                    flatten = FALSE)

    ## create tibblify specification
    spec <- spec_state_summary()

    ## nested list -> rectangular data
    content <- tibblify(json_list$data,
                        spec = spec,
                        unspecified = "drop")

    ## if unnest == FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      return(content)
    }

    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)

    return(content)
  }

}


#' Create tibblify specification for state_summary
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_state_summary <- function() {
  spec <- tspec_row(
    "organization_identifer" = tib_chr("organizationIdentifier"),
    "organization_name" = tib_chr("organizationName"),
    "organization_type_text" = tib_chr("organizationTypeText"),
    "reporting_cycles" = tib_df(
      "reportingCycles",
      "reporting_cycle" = tib_chr("reportingCycle"),
      "combined_cycles" = tib_unspecified("combinedCycles"),
      "water_types" = tib_df(
        "waterTypes",
        "water_type_code" = tib_chr("waterTypeCode"),
        "units_code" = tib_chr("unitsCode"),
        "use_attainments" = tib_df(
          "useAttainments",
          "use_name" = tib_chr("useName"),
          "fully_supporting" = tib_dbl("Fully Supporting", required = FALSE),
          "fully_supporting_count" = tib_int("Fully Supporting-count", required = FALSE),
          "use_insufficient_information" = tib_dbl("Insufficient Information", required = FALSE),
          "use_insufficient_information_count" = tib_int("Insufficient Information-count", required = FALSE),
          "not_assessed" = tib_dbl("Not Assessed", required = FALSE),
          "not_assessed_count" = tib_int("Not Assessed-count", required = FALSE),
          "not_supporting" = tib_dbl("Not Supporting", required = FALSE),
          "not_supporting_count" = tib_int("Not Supporting-count", required = FALSE),
          "parameters" = tib_df(
            "parameters",
            "parameter_group" = tib_chr("parameterGroup", required = FALSE),
            "parameter_insufficient_information" = tib_dbl("Insufficient Information", required = FALSE),
            "parameter_insufficient_information_count" = tib_int("Insufficient Information-count", required = FALSE),
            "cause" = tib_dbl("Cause", required = FALSE),
            "cause_count" = tib_int("Cause-count", required = FALSE),
            "meeting_criteria" = tib_dbl("Meeting Criteria", required = FALSE),
            "meeting_criteria_count" = tib_int("Meeting Criteria-count", required = FALSE),
            "removed" = tib_dbl("Removed", required = FALSE),
            "removed_count" = tib_int("Removed-count", required = FALSE),
          ),
        ),
      ),
    ),
  )
  return(spec)
  }
