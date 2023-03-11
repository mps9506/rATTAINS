#' Download HUC12 Summary
#'
#' @description Provides summary data for a 12-digit Hydrologic Unit Code (HUC12), based on
#' Assessment Units in the HUC12. Watershed boundaries may cross state
#' boundaries, so the service may return assessment units from multiple
#' organizations. Returns the assessment units in the HUC12, size and
#' percentages of assessment units considered Good, Unknown, or Impaired.
#'
#' @param huc (character) Specifies the 12-digit HUC to be summarized. required
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles that include a list of seven tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr select
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
#' @export
#' @examples
#'
#' \dontrun{
#' ## Return a list of tibbles with summary data about a single huc12
#' x <- huc12_summary(huc = "020700100204")
#'
#' ## Return as a JSON string
#' x <- huc12_summary(huc = "020700100204", tidy = TRUE)
#' }
huc12_summary <- function(huc, tidy = TRUE, ...) {

  ## check connectivity
  check_connectivity()

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(huc),
         .var.name = c("huc"),
         MoreArgs = list(null.ok = FALSE,
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

  args <- list(huc = huc)
  path = "attains-public/api/huc12summary"

  ## download data without caching
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) {
    return(content)
  } else {

    ## parse JSON
    json_list <- jsonlite::fromJSON(content,
                                    simplifyVector = FALSE,
                                    simplifyDataFrame = FALSE,
                                    flatten = FALSE)

    ## create tibblify specification
    spec <- spec_huc12()

    ## nested list -> rectangle
    content <- tibblify(json_list, spec = spec, unspecified = "drop")

    ## create separate tibbles to return as list
    content_huc_summary <- select(content$items, -c("assessmentUnits",
                                                    "summaryByIRCategory",
                                                    "summaryByOverallStatus",
                                                    "summaryByUseGroup",
                                                    "summaryByUse",
                                                    "summaryByParameterImpairments",
                                                    "summaryRestorationPlans",
                                                    "summaryVisionRestorationPlans"))
    content_huc_summary <- clean_names(content_huc_summary)

    content_assessment_units <- select(content$items, c("assessmentUnits"))
    content_assessment_units <- unnest(content_assessment_units,
                                       cols = everything(), keep_empty = TRUE)
    content_assessment_units <- clean_names(content_assessment_units)

    content_IR_summary <- select(content$items, c("summaryByIRCategory"))
    content_IR_summary <- unnest(content_IR_summary, cols = everything(),
                                 keep_empty = TRUE)
    content_IR_summary <- clean_names(content_IR_summary)

    content_status_summary <- select(content$items, c("summaryByOverallStatus"))
    content_status_summary <- unnest(content_status_summary,
                                     cols = everything(), keep_empty = TRUE)
    content_status_summary <- clean_names(content_status_summary)

    content_use_group_summary <- select(content$items, c("summaryByUseGroup"))
    content_use_group_summary <- unnest(content_use_group_summary,
                                        cols = everything(), keep_empty = TRUE)
    content_use_group_summary <- unnest(content_use_group_summary,
                                        cols = everything(), keep_empty = TRUE)
    content_use_group_summary <- clean_names(content_use_group_summary)

    content_use <- select(content$items, c("summaryByUse"))
    content_use <- unnest(content_use, cols = everything(), keep_empty = TRUE)
    content_use <- unnest(content_use, cols = everything(), keep_empty = TRUE)
    content_use <- clean_names(content_use)

    content_parameter_impairment <- select(content$items,
                                           c("summaryByParameterImpairments"))
    content_parameter_impairment <- unnest(content_parameter_impairment,
                                           cols = everything(),
                                           keep_empty = TRUE)
    content_parameter_impairment <- clean_names(content_parameter_impairment)

    content_restoration_plans <- select(content$items,
                                        c("summaryRestorationPlans"))
    content_restoration_plans <- unnest(content_restoration_plans,
                                        cols = everything(), keep_empty = TRUE)
    content_restoration_plans <- clean_names(content_restoration_plans)

    content_vision_restoration_plans <- select(content$items,
                                               c("summaryVisionRestorationPlans"))
    content_vision_restoration_plans <- unnest(content_vision_restoration_plans,
                                               cols = everything(),
                                               keep_empty = TRUE)
    content_vision_restoration_plans <- clean_names(content_vision_restoration_plans)

    content <- list(
      huc_summary = content_huc_summary,
      au_summary = content_assessment_units,
      ir_summary = content_IR_summary,
      status_summary = content_status_summary,
      use_group_summary = content_use_group_summary,
      use_summary = content_use,
      param_summary = content_parameter_impairment,
      res_plan_summary = content_restoration_plans,
      vision_plan_summary = content_vision_restoration_plans
    )
    return(content)
  }
}


#' Create tibblify specification for huc12_summary
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_huc12 <- function() {
  spec <- tspec_object(
    tib_df(
      "items",
      tib_chr("huc12", required = FALSE),
      tib_int("assessmentUnitCount", required = FALSE),
      tib_dbl("totalCatchmentAreaSqMi", required = FALSE),
      tib_dbl("totalHucAreaSqMi", required = FALSE),
      tib_dbl("assessedCatchmentAreaSqMi", required = FALSE),
      tib_dbl("assessedCatchmentAreaPercent", required = FALSE),
      tib_dbl("assessedGoodCatchmentAreaSqMi", required = FALSE),
      tib_dbl("assessedGoodCatchmentAreaPercent", required = FALSE),
      tib_dbl("assessedUnknownCatchmentAreaSqMi", required = FALSE),
      tib_dbl("assessedUnknownCatchmentAreaPercent", required = FALSE),
      tib_dbl("containImpairedWatersCatchmentAreaSqMi", required = FALSE),
      tib_dbl("containImpairedWatersCatchmentAreaPercent", required = FALSE),
      tib_dbl("containRestorationCatchmentAreaSqMi", required = FALSE),
      tib_dbl("containRestorationCatchmentAreaPercent", required = FALSE),
      tib_df(
        "assessmentUnits",
        tib_chr("assessmentUnitId", required = FALSE)
      ),
      tib_df(
        "summaryByIRCategory",
        tib_chr("epaIRCategoryName", required = FALSE),
        tib_dbl("catchmentSizeSqMi", required = FALSE),
        tib_dbl("catchmentSizePercent", required = FALSE),
        tib_int("assessmentUnitCount", required = FALSE),
      ),
      tib_df(
        "summaryByOverallStatus",
        tib_chr("overallStatus", required = FALSE),
        tib_dbl("catchmentSizeSqMi", required = FALSE),
        tib_dbl("catchmentSizePercent", required = FALSE),
        tib_int("assessmentUnitCount", required = FALSE)
      ),
      tib_df(
        "summaryByUseGroup",
        tib_chr("useGroupName", required = FALSE),
        tib_df(
          "useAttainmentSummary",
          tib_chr("useAttainment", required = FALSE),
          tib_dbl("catchmentSizeSqMi", required = FALSE),
          tib_dbl("catchmentSizePercent", required = FALSE),
          tib_int("assessmentUnitCount", required = FALSE)
        ),
      ),
      tib_df(
        "summaryByUse",
        tib_chr("useName", required = FALSE),
        tib_chr("useGroupName", required = FALSE),
        tib_df(
          "useAttainmentSummary",
          tib_chr("useAttainment", required = FALSE),
          tib_dbl("catchmentSizeSqMi", required = FALSE),
          tib_dbl("catchmentSizePercent", required = FALSE),
          tib_int("assessmentUnitCount", required = FALSE)
        ),
      ),
      tib_df(
        "summaryByParameterImpairments",
        tib_chr("parameterGroupName", required = FALSE),
        tib_dbl("catchmentSizeSqMi", required = FALSE),
        tib_dbl("catchmentSizePercent", required = FALSE),
        tib_int("assessmentUnitCount", required = FALSE)
      ),
      tib_df(
        "summaryRestorationPlans",
        tib_chr("summaryTypeName", required = FALSE),
        tib_dbl("catchmentSizeSqMi", required = FALSE),
        tib_dbl("catchmentSizePercent", required = FALSE),
        tib_int("assessmentUnitCount", required = FALSE),
      ),
      tib_df(
        "summaryVisionRestorationPlans",
        tib_chr("summaryTypeName", required = FALSE),
        tib_dbl("catchmentSizeSqMi", required = FALSE),
        tib_dbl("catchmentSizePercent", required = FALSE),
        tib_int("assessmentUnitCount", required = FALSE),
      ),
    ),
    tib_int("count", required = FALSE),
  )

  return(spec)
}
