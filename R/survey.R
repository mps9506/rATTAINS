#' Download State Survey Results
#'
#' @description Downloads data about state statistical (probability) survey results.
#' @param organization_id (character) Filters the list to only those “belonging
#'   to” one of the specified organizations. Multiple values may be specified.
#'   required
#' @param survey_year (character) Filters the list to the year the survey was
#'   performed. optional.
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @details Arguments that allow multiple values should be entered as a comma
#'   separated string with no spaces (\code{organization_id = "DOEE,21AWIC"}).
#' @note See [domain_values] to search values that can be queried.
#' @export
#' @import tidyjson
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr select
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tibble as_tibble
#' @examples
#'
#' \dontrun{
#'
#' ## return surveys by organization
#' surveys(organization_id="SDDENR")
#'
#' ## return as a JSON string instead of a list of tibbles
#' surveys(organization_id="SDDENR", tidy = FALSE)
#' }

surveys <- function(organization_id = NULL,
                    survey_year = NULL,
                    tidy = TRUE,
                    ...) {

  ## check connectivity
  check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(organization_id, survey_year),
         .var.name = c("organization_id", "survey_year"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(tidy),
         .var.name = c("tidy"),
         MoreArgs = list(null.ok = FALSE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check that required args are present
  args <- list(organizationId = organization_id,
               surveyYear = survey_year)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: organization_id")
  }

  path = "attains-public/api/surveys"

  ## download data without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  ## return raw JSON
  if(!isTRUE(tidy)) return(content)
  ## parse and tidy JSON
  else {
    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(organizationIdentifier = jstring("organizationIdentifier"),
                    organizationName = jstring("organizationName"),
                    organizationTypeText = jstring("organizationTypeText")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("surveys") %>%
      gather_array() %>%
      spread_values(surveyStatusCode = jstring("surveyStatusCode"),
                    year = jnumber("year"),
                    surveyCommentText = jstring("surveyCommentText")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("surveyWaterGroups") %>%
      gather_array() %>%
      spread_values(waterTypeGroupCode = jstring("waterTypeGroupCode"),
                    subPopulationCode = jstring("subPopulationCode"),
                    unitCode = jstring("unitCode"),
                    size = jnumber("size"),
                    siteNumber = jstring("siteNumber"),
                    surveyWaterGroupCommentText = jstring("surveyWaterGRoupCommentText")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("surveyWaterGroupUseParameters") %>%
      gather_array() %>%
      spread_values(stressor = jstring("stressor"),
                    surveyUseCode = jstring("surveyUseCode"),
                    surveyCategoryCode = jstring("surveyCategoryCode"),
                    statistic = jstring("statistic"),
                    metricValue = jnumber("metricValue"),
                    confidenceLevel = jnumber("confidenceLevel"),
                    commentText = jstring("commentText")) %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      clean_names() -> content_surveys

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(organizationIdentifier = jstring("organizationIdentifier"),
                    organizationName = jstring("organizationName"),
                    organizationTypeText = jstring("organizationTypeText")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("surveys") %>%
      gather_array() %>%
      spread_values(surveyStatusCode = jstring("surveyStatusCode"),
                    year = jnumber("year"),
                    surveyCommentText = jstring("surveyCommentText")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("documents") %>%
      gather_array() %>%
      spread_values(agencyCode = jstring("agencyCode"),
                    documentFileType = jstring("documentFileType"),
                    documentFileName = jstring("documentFileName"),
                    documentDescription = jstring("documentDescription"),
                    documentComments = jstring("documentComments"),
                    documentURL = jstring("documentURL")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("documentTypes") %>%
      gather_array() %>%
      spread_all %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      clean_names() -> content_documents

    return(list(documents = content_documents,
                surveys = content_surveys))
    }
}


