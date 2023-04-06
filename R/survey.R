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
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @details Arguments that allow multiple values should be entered as a comma
#'   separated string with no spaces (\code{organization_id = "DOEE,21AWIC"}).
#' @note See [domain_values] to search values that can be queried.
#' @export
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom jsonlite fromJSON
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
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
         x = list(organization_id, survey_year),
         .var.name = c("organization_id", "survey_year"),
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

    ## parse JSON
    json_list <- fromJSON(content,
                          simplifyVector = FALSE,
                          simplifyDataFrame = FALSE,
                          flatten = FALSE)

    ## create tibblify spec
    spec <- spec_survey()

    content <- tibblify(json_list,
                        spec = spec,
                        unspecified = "drop")
    content <- unnest(content$items, cols = everything(), keep_empty = TRUE)

    ## if unnest == FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      return(content)
    }

    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)

    return(content)
    }
}


#' Create tibblify specification for survey
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_survey <- function(summarize) {
  spec <- tspec_object(
    "items" = tib_df(
      "items",
      "organization_identifier" = tib_chr("organizationIdentifier", required = FALSE),
      "organization_name" = tib_chr("organizationName", required = FALSE),
      "organization_type_text" = tib_chr("organizationTypeText", required = FALSE),
      "surveys" = tib_df(
        "surveys",
        "survey_status_code" = tib_chr("surveyStatusCode", required = FALSE),
        "year" = tib_int("year", required = FALSE),
        "survey_comment_text" = tib_chr("surveyCommentText", required = FALSE),
        "documents" = tib_df(
          "documents",
          "agency_code" = tib_chr("agencyCode", required = FALSE),
          "document_types" = tib_df(
            "documentTypes",
            "document_type_code" = tib_chr("documentTypeCode", required = FALSE),
          ),
          "document_file_type" = tib_chr("documentFileType", required = FALSE),
          "document_file_name" = tib_chr("documentFileName", required = FALSE),
          "document_name" = tib_chr("documentName", required = FALSE),
          "document_description" = tib_chr("documentDescription", required = FALSE),
          "document_comments" = tib_chr("documentComments", required = FALSE),
          "document_url" = tib_chr("documentURL", required = FALSE),
        ),
        "survey_water_groups" = tib_df(
          "surveyWaterGroups",
          "water_type_group_code" = tib_chr("waterTypeGroupCode", required = FALSE),
          "sub_population_code" = tib_chr("subPopulationCode", required = FALSE),
          "unit_code" = tib_chr("unitCode", required = FALSE),
          "size" = tib_int("size", required = FALSE),
          "site_number" = tib_int("siteNumber", required = FALSE),
          "surey_water_group_comment_text" = tib_chr("surveyWaterGroupCommentText", required = FALSE),
          "survey_water_group_use_parameters" = tib_df(
            "surveyWaterGroupUseParameters",
            "stressor" = tib_chr("stressor", required = FALSE),
            "survey_use_code" = tib_chr("surveyUseCode", required = FALSE),
            "survey_category_code" = tib_chr("surveyCategoryCode", required = FALSE),
            "statistic" = tib_chr("statistic", required = FALSE),
            "metric_value" = tib_dbl("metricValue", required = FALSE),
            "margin_of_error" = tib_dbl("marginOfError", required = FALSE),
            "confidence_level" = tib_dbl("confidenceLevel", required = FALSE),
            "comment_text" = tib_chr("commentText", required = FALSE),
          ),
        ),
      ),
    ),
    "count" = tib_int("count"),
  )
  return(spec)
}
