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
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @export
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tibble enframe
#' @importFrom tidyr unnest_longer unnest_wider
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
                        ...) {

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
  path = "attains-public/api/assessments"
  content <- xGET(path, args, ...)
  ## parse the returned json
  content <- fromJSON(content, simplifyVector = FALSE)

  content <- assessments_to_tibble(content,
                                   count = return_count_only,
                                   exclude_assessments = exclude_assessments)

  return(content)
}

assessments_to_tibble <- function(content,
                                  count = FALSE,
                                  exclude_assessments = FALSE) {
  if(isTRUE(count)) {
    return(content$count)
  } else {
    if(isTRUE(exclude_assessments)) {
      content <- content$items %>%
        tibble::enframe() %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        unnest_longer(.data$documents) %>%
        unnest_wider(.data$documents) %>%
        unnest_longer(.data$documentTypes) %>%
        unnest_wider(.data$documentTypes)
      return(content)
    } else {
      content$items %>%
        tibble::enframe() %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        select(!c(.data$assessments, .data$delistedWaters)) %>%
        unnest_longer(.data$documents) %>%
        unnest_wider(.data$documents) %>%
        unnest_longer(.data$documentTypes) %>%
        unnest_wider(.data$documentTypes) -> content_docs

      content$items %>%
        tibble::enframe() %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        select(!c(.data$documents, .data$delistedWaters)) %>%
        unnest_longer(.data$assessments) %>%
        unnest_wider(.data$assessments) %>%
        select(!c(.data$agencyCode, .data$parameters, .data$probableSources)) %>%
        unnest_longer(.data$useAttainments) %>%
        unnest_wider(.data$useAttainments) -> content_use_assessment

      content$items %>%
        tibble::enframe() %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        select(!c(.data$documents, .data$delistedWaters)) %>%
        unnest_longer(.data$assessments) %>%
        unnest_wider(.data$assessments) %>%
        select(!c(.data$agencyCode, .data$useAttainments, .data$probableSources)) %>%
        unnest_longer(.data$parameters) %>%
        unnest_wider(.data$parameters) %>%
        unnest_longer(.data$associatedUses) %>%
        unnest_wider(.data$associatedUses) %>%
        unnest_wider(.data$impairedWatersInformation) %>%
        unnest_longer(.data$associatedActions) %>%
        unnest_wider(.data$associatedActions) %>%
        unnest_wider(.data$listingInformation) -> content_parameter_assessment

      content$items %>%
        tibble::enframe() %>%
        select(!c(.data$name)) %>%
        unnest_wider(.data$value) %>%
        select(!c(.data$documents, .data$delistedWaters)) %>%
        unnest_longer(.data$assessments) %>%
        unnest_wider(.data$assessments) %>%
        select(!c(.data$agencyCode, .data$useAttainments, .data$parameters)) %>%
        unnest_longer(.data$probableSources) %>%
        unnest_wider(.data$probableSources) %>%
        unnest_longer(.data$associatedCauseNames) %>%
        unnest_wider(.data$associatedCauseNames) -> content_causes_assessment

      return(list(documents = content_docs,
                  use_assessment = content_use_assessment,
                  parameter_assessment = content_parameter_assessment,
                  cause_assessment = content_causes_assessment))
    }
  }
}
