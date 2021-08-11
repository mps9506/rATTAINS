#' Download Assessment Decisions
#'
#' @param assessment_unit_id (character)
#' @param state_code (character)
#' @param organization_id (character)
#' @param reporting_cycle (character)
#' @param use (character)
#' @param use_support (character)
#' @param parameter (character)
#' @param parameter_status_name (character)
#' @param probable_source (character)
#' @param agency_code (character)
#' @param ir_category (character)
#' @param state_ir_category_code (character)
#' @param multicategory_search (character)
#' @param last_change_later_than_date (character)
#' @param last_change_earlier_than_date (character)
#' @param return_count_only (logical)
#' @param exclude_assessments (logical)
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble or list of tibbles
#' @export
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#'
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
  assessments_cache$mkdir()

  ## check if current results have been cached
  file_cache_name <- file_key(arg_list = args,
                              name = "assessments.json")
  file_path_name <- fs::path(assessments_cache$cache_path_get(),
                             file_cache_name)

  if(file.exists(file_path_name)) {
    message(paste0("reading cached file from: ", file_path_name))
    content <- readLines(file_path_name, warn = FALSE)
  }

  ## download data
  else{
    content <- xGET(path,
                    args,
                    file = file_path_name,
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
