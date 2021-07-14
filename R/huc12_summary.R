#' Download HUC12 Summary
#'
#' Provides summary data for a 12-digit Hydrologic Unit Code (HUC12), based on
#' Assessment Units in the HUC12. Watershed boundaries may cross state
#' boundaries, so the service may return assessment units from multiple
#' organizations. Returns the assessment units in the HUC12, size and
#' percentages of assessment units considered Good, Unknown, or Impaired.
#'
#' @param huc (character) 12-digit hydrologic unit code. required
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return a list of tibbles
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @importFrom tidyr unnest_wider unnest_longer
#' @export
huc12_summary <- function(huc, ...) {

  ## still need to check that huc is a 12-digit character

  args <- list(huc = huc)
  path = "attains-public/api/huc12summary"

  content <- xGET(path, args, ...)

  ## parse the returned json
  content <- fromJSON(content, simplifyVector = FALSE)


  ## tibble of assessment unit ids
  ## tibble of IR category summary
  ## tibble with summary by use
  ## tibble with summary by parameter
  huc_summary <- content[["items"]][[1]][1:14] %>%
    as_tibble() %>%
    clean_names()

  au_summary <- content[["items"]][[1]][15] %>%
    as_tibble() %>%
    unnest_wider(assessmentUnits) %>%
    clean_names()

  ir_summary <- content[["items"]][[1]][16] %>%
    as_tibble() %>%
    unnest_wider(summaryByIRCategory) %>%
    clean_names()

  use_summary <- content[["items"]][[1]][18] %>%
    as_tibble() %>%
    unnest_wider(summaryByUse) %>%
    unnest_longer(useAttainmentSummary) %>%
    unnest_wider(useAttainmentSummary) %>%
    clean_names()

  param_summary <- content[["items"]][[1]][19] %>%
    as_tibble() %>%
    unnest_wider(summaryByParameterImpairments) %>%
    clean_names()

  res_plan_summary <- content[["items"]][[1]][20]  %>%
    as_tibble() %>%
    unnest_wider(summaryRestorationPlans) %>%
    clean_names()

  vision_plan_summary <- content[["items"]][[1]][21]  %>%
    as_tibble() %>%
    unnest_wider(summaryVisionRestorationPlans) %>%
    clean_names()

  content <- list(huc_summary = huc_summary,
                  au_summary = au_summary,
                  ir_summary = ir_summary,
                  use_summary = use_summary,
                  param_summary = param_summary,
                  res_plan_summary = res_plan_summary,
                  vision_plan_summary = vision_plan_summary)

  return(content)
}
