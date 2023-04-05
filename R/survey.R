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
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom janitor clean_names
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

    ## if unnest == FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      return(content)
    }

    content <- unnest(content$items, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)
    content <- unnest(content, cols = everything(), keep_empty = TRUE)

    content <- clean_names(content)

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
    tib_df(
      "items",
      tib_chr("organizationIdentifier", required = FALSE),
      tib_chr("organizationName", required = FALSE),
      tib_chr("organizationTypeText", required = FALSE),
      tib_df(
        "surveys",
        tib_chr("surveyStatusCode", required = FALSE),
        tib_int("year", required = FALSE),
        tib_chr("surveyCommentText", required = FALSE),
        tib_df(
          "documents",
          tib_chr("agencyCode", required = FALSE),
          tib_df(
            "documentTypes",
            tib_chr("documentTypeCode", required = FALSE),
          ),
          tib_chr("documentFileType", required = FALSE),
          tib_chr("documentFileName", required = FALSE),
          tib_chr("documentName", required = FALSE),
          tib_chr("documentDescription", required = FALSE),
          tib_chr("documentComments", required = FALSE),
          tib_chr("documentURL", required = FALSE),
        ),
        tib_df(
          "surveyWaterGroups",
          tib_chr("waterTypeGroupCode", required = FALSE),
          tib_chr("subPopulationCode", required = FALSE),
          tib_chr("unitCode", required = FALSE),
          tib_int("size", required = FALSE),
          tib_int("siteNumber", required = FALSE),
          tib_chr("surveyWaterGroupCommentText", required = FALSE),
          tib_df(
            "surveyWaterGroupUseParameters",
            tib_chr("stressor", required = FALSE),
            tib_chr("surveyUseCode", required = FALSE),
            tib_chr("surveyCategoryCode", required = FALSE),
            tib_chr("statistic", required = FALSE),
            tib_dbl("metricValue", required = FALSE),
            tib_dbl("marginOfError", required = FALSE),
            tib_dbl("confidenceLevel", required = FALSE),
            tib_chr("commentText", required = FALSE),
          ),
        ),
      ),
    ),
    tib_int("count"),
  )
  return(spec)
}
