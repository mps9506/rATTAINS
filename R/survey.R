#' Download State Survey Results
#'
#' Downloads data about state statistical (probability) survey results.
#' @param organization_id (character) - Filters the list to only those “belonging to” one of the specified organizations. Multiple values may be specified. required
#' @param survey_year (character) Filters the list to the year the survey was performed. optional.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return a tibble with multiple columns or a tibble with zero columns.
#' @note Arguments that allow multiple values should be entered as a comma separated string with no spaces (\code{organization_id = "DOEE,21AWIC"}).
#' @export
#' @importFrom checkmate assert_character
#' @importFrom dplyr select
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlist list.filter
#' @importFrom rlang is_empty .data
#' @importFrom tibble enframe tibble
#' @importFrom tidyr unnest_longer unnest_wider

surveys <- function(organization_id = NULL,
                    survey_year = NULL,
                    ...) {

  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(organization_id, survey_year),
         .var.name = c("organization_id", "survey_year"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  args <- list(organizationId = organization_id,
               surveyYear = survey_year)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("organizationId")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: organization_id")
  }

  path = "attains-public/api/surveys"
  content <- xGET(path, args, ...)
  content <- fromJSON(content, simplifyVector = FALSE)
  if(!rlang::is_empty(content$items)) {
    content <- content$items %>%
      tibble::enframe() %>%
      select(!c(.data$name)) %>%
      unnest_wider(.data$value) %>%
      unnest_longer(.data$surveys) %>%
      unnest_wider(.data$surveys) %>%
      unnest_longer(.data$surveyWaterGroups) %>%
      unnest_wider(.data$surveyWaterGroups) %>%
      unnest_longer(.data$surveyWaterGroupUseParameters) %>%
      unnest_wider(.data$surveyWaterGroupUseParameters) %>%
      clean_names()
  } else {
    content <- tibble::tibble()
  }

  return(content)
}


