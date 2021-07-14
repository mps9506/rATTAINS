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
#' @return
#' @export
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty
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

  args <- list.filter(args, !is.null(.))
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
        select(!c(name)) %>%
        unnest_wider(value) %>%
        unnest_longer(documents) %>%
        unnest_wider(documents) %>%
        unnest_longer(documentTypes) %>%
        unnest_wider(documentTypes)
      return(content)
    } else {
      content$items %>%
        tibble::enframe() %>%
        select(!c(name)) %>%
        unnest_wider(value) %>%
        select(!c(assessments, delistedWaters)) %>%
        unnest_longer(documents) %>%
        unnest_wider(documents) %>%
        unnest_longer(documentTypes) %>%
        unnest_wider(documentTypes) -> content_docs

      content$items %>%
        tibble::enframe() %>%
        select(!c(name)) %>%
        unnest_wider(value) %>%
        select(!c(documents, delistedWaters)) %>%
        unnest_longer(assessments) %>%
        unnest_wider(assessments) %>%
        select(!c(agencyCode, parameters, probableSources)) %>%
        unnest_longer(useAttainments) %>%
        unnest_wider(useAttainments) -> content_use_assessment

      content$items %>%
        tibble::enframe() %>%
        select(!c(name)) %>%
        unnest_wider(value) %>%
        select(!c(documents, delistedWaters)) %>%
        unnest_longer(assessments) %>%
        unnest_wider(assessments) %>%
        select(!c(agencyCode, useAttainments, probableSources)) %>%
        unnest_longer(parameters) %>%
        unnest_wider(parameters) %>%
        unnest_longer(associatedUses) %>%
        unnest_wider(associatedUses) %>%
        unnest_wider(impairedWatersInformation) %>%
        unnest_longer(associatedActions) %>%
        unnest_wider(associatedActions) %>%
        unnest_wider(listingInformation) -> content_parameter_assessment



      content$items %>%
        tibble::enframe() %>%
        select(!c(name)) %>%
        unnest_wider(value) %>%
        select(!c(documents, delistedWaters)) %>%
        unnest_longer(assessments) %>%
        unnest_wider(assessments) %>%
        select(!c(agencyCode, useAttainments, parameters)) %>%
        unnest_longer(probableSources) %>%
        unnest_wider(probableSources) %>%
        unnest_longer(associatedCauseNames) %>%
        unnest_wider(associatedCauseNames) -> content_causes_assessment

      return(list(documents = content_docs,
                  use_assessment = content_use_assessment,
                  parameter_assessment = content_parameter_assessment,
                  cause_assessment = content_causes_assessment))
    }
  }
}
