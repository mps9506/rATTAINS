#' Download Assessment Decisions
#'
#' @param assessment_unit_id (character) Specify the specific assessment unit assessment data to return. Multiple values can be provided. optional
#' @param state_code (character) Filters returned assessments to those from the specified state. optional
#' @param organization_id (character) Filters the returned assessments to those belonging to the specified organization. optional
#' @param reporting_cycle (character) Filters the returned assessments to those for the specified reporting cycle. The reporting cycle refers to the four-digit year that the reporting cycle ended. Defaults to the current cycle. optional
#' @param use (character) Filters the returned assessments to those with the specified uses. Multiple values can be provided. optional
#' @param use_support (character) Filters returned assessments to those fully supporting the specified uses or that are threatened. Multiple values can be provided. Allowable values include \code{"X"}= Not Assessed, \code{"I"}= Insufficient Information, \code{"F"}= Fully Supporting, \code{"N"}= Not Supporting, and \code{"T"}= Threatened. optional
#' @param parameter (character) Filters the returned assessments to those with one or more of the specified parameters. Multiple values can be provided. optional
#' @param parameter_status_name (character) Filters the returned assessments to those with one or more associated parameters meeting the provided value. Valid values are \code{"Meeting Criteria"}, \code{"Cause"}, \code{"Observed Effect"}. Multiple valuse can be provided. optional
#' @param probable_source (character) Filters the returned assessments to those having the specified probable source. Multiple values can be provided. optional
#' @param agency_code (character) Filters the returned assessments to those by the type of agency responsible for the assessment. Allowed values are \code{"E"}=EPA, \code{"S"}=State, \code{"T"}=Tribal. optional
#' @param ir_category (character) Filters the returned assessments to those having the specified IR category. Multiple values can be provided. optional
#' @param state_ir_category_code (character) Filters the returned assessments to include those having the provided codes.
#' @param multicategory_search (character) Specifies whether to search at multiple levels.  If this parameter is set to “Y” then the query applies the EPA IR Category at the Assessment, UseAttainment, and Parameter levels; if the parameter is set to “N” it looks only at the Assessment level.
#' @param last_change_later_than_date (character) Filters the returned assessments to only those last changed after the provided date. Must be a character
#'   with format: \code{"yyyy-mm-dd"}. optional
#' @param last_change_earlier_than_date (character) Filters the returned assessments to only those last changed before the provided date. Must be a character
#'   with format: \code{"yyyy-mm-dd"}. optional
#' @param return_count_only (logical) If \code{TRUE} returns only the count of
#'   actions the match the query. defaults to \code{FALSE}
#' @param exclude_assessments (logical) If \code{TRUE} returns only the documents associated with the Assessment cycle instead of the assessment data. Defaults is \code{FALSE}.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details One or more of the following arguments must be included:
#'   \code{action_id}, \code{assessment_unit_id}, \code{state_code} or
#'   \code{organization_id}. Multiple values are allowed for indicated arguments
#'   and should be included as a comma separated values in the string (eg.
#'   \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return If \code{count = TRUE} returns a tibble that summarizes the count of
#'   actions returned by the query. If \code{count = FALSE} returns a list of
#'   tibbles including documents, use assessment data, and parameters assessment
#'   data identified by the query. If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as tibbles.
#' @note See [domain_values] to search values that can be queried. Data
#'   downloaded from the EPA webservice is automatically cached to reduce
#'   uneccessary calls to the server. To managed cached files see
#'   [rATTAINS_caching].
#' @export
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @examples
#'
#' \dontrun{
#'
#' ## Return all assessment decisions with specified parameters
#' assessments(organization_id = "SDDENR",
#' probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
#'
#' ## Returns the raw JSONs instead:
#' assessments(organization_id = "SDDENR",
#' probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
#' }
assessments <- function(assessment_unit_id = NULL,
                        state_code = NULL,
                        organization_id = NULL,
                        reporting_cycle = NULL,
                        use = NULL,
                        use_support = NULL,
                        parameter = NULL,
                        parameter_status_name = NULL,
                        probable_source = NULL,
                        agency_code = NULL,
                        ir_category = NULL,
                        state_ir_category_code = NULL,
                        multicategory_search = NULL,
                        last_change_later_than_date = NULL,
                        last_change_earlier_than_date = NULL,
                        return_count_only = FALSE,
                        exclude_assessments = FALSE,
                        tidy = TRUE,
                        ...) {

  ## check connectivity
  if (!has_internet_2("www.epa.gov")) {
    message("No connection to www.epa.gov available")
    return(invisible(NULL))
  }

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(assessment_unit_id, state_code, organization_id,
                  reporting_cycle, use, use_support, parameter,
                  parameter_status_name, probable_source, agency_code,
                  ir_category, state_ir_category_code, multicategory_search,
                  last_change_later_than_date, last_change_earlier_than_date),
         .var.name = c("assessment_unit_id", "state_code", "organization_id",
                       "reporting_cycle", "use", "use_support", "parameter",
                       "parameter_status_name", "probable_source", "agency_code",
                       "ir_category", "state_ir_category_code", "multicategory_search",
                       "last_change_later_than_date", "last_change_earlier_than_date"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(return_count_only, exclude_assessments, tidy),
         .var.name = c("return_count_only", "exclude_assessments", "tidy"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  returnCountOnly <- if(isTRUE(return_count_only)) {
    "Y"
  } else {"N"}
  excludeAssessments <- if(isTRUE(exclude_assessments)) {
    "Y"
  } else {"N"}

  args <- list(assessmentUnitIdentifier = assessment_unit_id,
               state = state_code,
               organizationId = organization_id,
               reportingCycle = reporting_cycle,
               use = use,
               useSupport = use_support,
               parameter = parameter,
               parameterStatusName = parameter_status_name,
               probableSource = probable_source,
               agencyCode = agency_code,
               irCategory = ir_category,
               stateIRCategoryCode = state_ir_category_code,
               multicategorySearch = multicategory_search,
               lastChangeLaterThanDate = last_change_later_than_date,
               lastChangeEarlierThanDate = last_change_earlier_than_date,
               returnCountOnly = returnCountOnly,
               excludeAssessments = excludeAssessments)

  args <- list.filter(args, !is.null(.data))
  required_args <- c("assessmentUnitIdentifier",
                     "state",
                     "organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: assessment_unit_identifer, state_code, or organization_id")
  }

  ##setup file cache
  path = "attains-public/api/assessments"
  if(isTRUE(rATTAINSenv$cache_downloads)){
    assessments_cache$mkdir()

    ## check if current results have been cached
    file_cache_name <- file_key(arg_list = args,
                                name = "assessments.json")
    file_path_name <- fs::path(assessments_cache$cache_path_get(),
                               file_cache_name)

    if(file.exists(file_path_name)) {
      message(paste0("reading cached file from: ", file_path_name))
      content <- readLines(file_path_name, warn = FALSE)
    } else {
      ## download data
      content <- xGET(path,
                      args,
                      file = file_path_name,
                      ...)
    }
  } else {
    ## download without caching
    content <- xGET(path,
                    args,
                    file = NULL,
                    ...)
  }

  if (!isTRUE(tidy)) {
    return(content)
  } else{
    ## parse the returned json
    content <- assessments_to_tibble(content,
                                     count = return_count_only,
                                     exclude_assessments = exclude_assessments)

    return(content)
  }
}


#'
#' @param content raw JSON
#' @param count logical
#' @param exclude_assessments logical
#'
#' @noRd
#' @import tidyjson
#' @importFrom dplyr select rename filter mutate
#' @importFrom janitor clean_names
#' @importFrom purrr map map_chr
#' @importFrom rlang .data
#' @importFrom tibble as_tibble tibble
#' @importFrom tidyr unnest
assessments_to_tibble <- function(content,
                                  count = FALSE,
                                  exclude_assessments = FALSE) {
  if(isTRUE(count)) {
    content <- content %>%
      gather_object() %>%
      filter(.data$name == "count") %>%
      spread_values(count = jnumber()) %>%
      select(-c(.data$document.id, .data$name)) %>%
      as_tibble()
    return(content)
  } else {
    if(isTRUE(exclude_assessments)) {
      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index, .data$document.id)) %>%
        enter_object("documents") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index)) %>%
        mutate(
          documentTypes = map(.data$..JSON, ~{
            .x[["documentTypes"]] %>% {
              tibble(
                assessmentTypeCode = map_chr(., "documentTypeCode")
              )}
          })) %>%
        tibble::as_tibble() %>%
        unnest(c(.data$documentTypes)) %>%
        clean_names()
      return(content)
    } else {
      ## return documents
      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index, .data$document.id)) %>%
        enter_object("documents") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index)) %>%
        as_tibble() -> content_docs

      ## return use assessment data
      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index, .data$document.id)) %>%
        enter_object("assessments") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index, .data$agencyCode)) %>%
        mutate(
          probableSources = map(.data$..JSON, ~{
            .x[["probableSources"]] %>% {
              tibble(
                sourceName = map_chr(., "sourceName"),
                sourceConfirmedIndicator = map_chr(., "sourceConfirmedIndicator"),
                associatedCauseName = map(., ~{
                  .x[["associatedCauseNames"]] %>% {
                    tibble(
                      causeName = map_chr(., "causeName")
                    )}
                })) %>%
                unnest(c(.data$associatedCauseName), keep_empty = TRUE)
            }})
        ) %>%
        enter_object("useAttainments") %>%
        gather_array() %>%
        spread_all()  %>%
        select(-c(.data$array.index)) %>%
        mutate(
          assessmentTypes = map(.data$..JSON, ~{
            .x[["assessmentMetadata"]][["assessmentTypes"]] %>% {
              tibble(
                assessmentTypeCode = map_chr(., "assessmentTypeCode"),
                assessmentConfidenceCode = map_chr(., "assessmentConfidenceCode")
              )}
          })) %>%
        tibble::as_tibble() %>%
        unnest(c(.data$probableSources, .data$assessmentTypes), keep_empty = TRUE) %>%
        janitor::clean_names()-> content_use_assessments

      ## return parameter assessment data
      content %>%
        enter_object("items") %>%
        gather_array() %>%
        spread_all() %>%
        select(-c(.data$array.index, .data$document.id)) %>%
        enter_object("assessments") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index, .data$agencyCode)) %>%
        enter_object("parameters") %>%
        gather_array() %>%
        spread_all(recursive = TRUE) %>%
        select(-c(.data$array.index)) %>%
        enter_object("associatedUses") %>%
        gather_array() %>%
        select(-c(.data$array.index)) %>%
        spread_all(recursive = TRUE) %>%
        mutate(seasons = map(.data$..JSON, ~{
          .x[["seasons"]] %>% {
            tibble(
              seasonStartText = map_chr(., "seasonStartText"),
              seasonEndText = map_chr(., "seasonEndText")
            )
          }
        })) %>%
        unnest(.data$seasons, keep_empty = TRUE) -> content_parameter_assessments

      return(list(documents = content_docs,
                  use_assessment = content_use_assessments,
                  parameter_assessment = content_parameter_assessments))
    }
  }
}
