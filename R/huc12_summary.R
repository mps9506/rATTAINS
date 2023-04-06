#' Download HUC12 Summary
#'
#' @description Provides summary data for a 12-digit Hydrologic Unit Code
#'   (HUC12), based on Assessment Units in the HUC12. Watershed boundaries may
#'   cross state boundaries, so the service may return assessment units from
#'   multiple organizations. Returns the assessment units in the HUC12, size and
#'   percentages of assessment units considered Good, Unknown, or Impaired.
#'
#' @param huc (character) Specifies the 12-digit HUC to be summarized. required
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied
#'   tibble. \code{FALSE} the function returns the raw JSON string.
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return If \code{tidy = FALSE} the raw JSON string is returned, else the JSON
#'   data is parsed and returned as a list of tibbles that include a list of
#'   seven tibbles.
#' @note See [domain_values] to search values that can be queried.
#' @import tibblify
#' @importFrom checkmate assert_character assert_logical makeAssertCollection
#'   reportAssertions
#' @importFrom dplyr select
#' @importFrom fs path
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
huc12_summary <- function(huc,
                          tidy = TRUE,
                          .unnest = TRUE,
                          ...) {

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
         x = list(tidy, .unnest),
         .var.name = c("tidy", ".unnest"),
         MoreArgs = list(null.ok = FALSE,
                         add = coll))
  checkmate::reportAssertions(coll)

  args <- list(huc = huc)
  path = "attains-public/api/huc12summary"

  ## download data
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

    ## if unnest = FALSE do not unnest lists
    if(!isTRUE(.unnest)) {
      return(content$items)
    }

    ## create separate tibbles to return as list
    content_huc_summary <- select(content$items, -c("assessment_units",
                                                    "summary_by_IR_category",
                                                    "summary_by_overall_status",
                                                    "summary_by_use_group",
                                                    "summary_by_use",
                                                    "summary_by_parameter_impairments",
                                                    "summary_restoration_plans",
                                                    "summary_vision_restoration_plans"))

    content_assessment_units <- select(content$items, c("assessment_units"))
    content_assessment_units <- unnest(content_assessment_units,
                                       cols = everything(), keep_empty = TRUE)


    content_IR_summary <- select(content$items, c("summary_by_IR_category"))
    content_IR_summary <- unnest(content_IR_summary, cols = everything(),
                                 keep_empty = TRUE)


    content_status_summary <- select(content$items, c("summary_by_overall_status"))
    content_status_summary <- unnest(content_status_summary,
                                     cols = everything(), keep_empty = TRUE)


    content_use_group_summary <- select(content$items, c("summary_by_use_group"))
    content_use_group_summary <- unnest(content_use_group_summary,
                                        cols = everything(), keep_empty = TRUE)
    content_use_group_summary <- unnest(content_use_group_summary,
                                        cols = everything(), keep_empty = TRUE)


    content_use <- select(content$items, c("summary_by_use"))
    content_use <- unnest(content_use, cols = everything(), keep_empty = TRUE)
    content_use <- unnest(content_use, cols = everything(), keep_empty = TRUE)


    content_parameter_impairment <- select(content$items,
                                           c("summary_by_parameter_impairments"))
    content_parameter_impairment <- unnest(content_parameter_impairment,
                                           cols = everything(),
                                           keep_empty = TRUE)


    content_restoration_plans <- select(content$items,
                                        c("summary_restoration_plans"))
    content_restoration_plans <- unnest(content_restoration_plans,
                                        cols = everything(), keep_empty = TRUE)


    content_vision_restoration_plans <- select(content$items,
                                               c("summary_vision_restoration_plans"))
    content_vision_restoration_plans <- unnest(content_vision_restoration_plans,
                                               cols = everything(),
                                               keep_empty = TRUE)


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
    "items" = tib_df(
      "items",
      "huc12" = tib_chr("huc12", required = FALSE),
      "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE),
      "total_catchment_area_sq_mi" = tib_dbl("totalCatchmentAreaSqMi", required = FALSE),
      "total_huc_area_sq_mi" = tib_dbl("totalHucAreaSqMi", required = FALSE),
      "assessed_catchment_area_sq_mi" = tib_dbl("assessedCatchmentAreaSqMi", required = FALSE),
      "assessed_cathcment_area_percent" = tib_dbl("assessedCatchmentAreaPercent", required = FALSE),
      "assessed_good_catchment_area_sq_mi" = tib_dbl("assessedGoodCatchmentAreaSqMi", required = FALSE),
      "assessed_good_catchment_area_percent" = tib_dbl("assessedGoodCatchmentAreaPercent", required = FALSE),
      "assessed_unknown_catchment_area_sq_mi" = tib_dbl("assessedUnknownCatchmentAreaSqMi", required = FALSE),
      "assessed_unknown_catchment_area_percent" = tib_dbl("assessedUnknownCatchmentAreaPercent", required = FALSE),
      "contain_impaired_waters_catchment_area_sq_mi" = tib_dbl("containImpairedWatersCatchmentAreaSqMi", required = FALSE),
      "contain_impaired_catchment_area_percent" = tib_dbl("containImpairedWatersCatchmentAreaPercent", required = FALSE),
      "contain_restoration_catchment_area_sq_mi" = tib_dbl("containRestorationCatchmentAreaSqMi", required = FALSE),
      "contain_restoration_catchment_area_percent" = tib_dbl("containRestorationCatchmentAreaPercent", required = FALSE),
      "assessment_units" = tib_df(
        "assessmentUnits",
        "assessment_unit_id" = tib_chr("assessmentUnitId", required = FALSE)
      ),
      "summary_by_IR_category" = tib_df(
        "summaryByIRCategory",
        "EPA_IR_category_name" = tib_chr("epaIRCategoryName", required = FALSE),
        "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
        "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
        "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE),
      ),
      "summary_by_overall_status" = tib_df(
        "summaryByOverallStatus",
        "overall_status" = tib_chr("overallStatus", required = FALSE),
        "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
        "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
        "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE)
      ),
      "summary_by_use_group" = tib_df(
        "summaryByUseGroup",
        "use_group_name" = tib_chr("useGroupName", required = FALSE),
        "use_attainment_summary" = tib_df(
          "useAttainmentSummary",
          "use_attainment" = tib_chr("useAttainment", required = FALSE),
          "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
          "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
          "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE)
        ),
      ),
      "summary_by_use" = tib_df(
        "summaryByUse",
        "use_name" = tib_chr("useName", required = FALSE),
        "use_group_name" = tib_chr("useGroupName", required = FALSE),
        "use_attainment_summary" = tib_df(
          "useAttainmentSummary",
          "use_attainment" = tib_chr("useAttainment", required = FALSE),
          "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
          "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
          "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE)
        ),
      ),
      "summary_by_parameter_impairments" = tib_df(
        "summaryByParameterImpairments",
        "parameter_group_name" = tib_chr("parameterGroupName", required = FALSE),
        "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
        "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
        "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE)
      ),
      "summary_restoration_plans" = tib_df(
        "summaryRestorationPlans",
        "summary_type_name" = tib_chr("summaryTypeName", required = FALSE),
        "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
        "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
        "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE),
      ),
      "summary_vision_restoration_plans" = tib_df(
        "summaryVisionRestorationPlans",
        "summary_type_name" = tib_chr("summaryTypeName", required = FALSE),
        "catchment_size_sq_mi" = tib_dbl("catchmentSizeSqMi", required = FALSE),
        "catchment_size_percent" = tib_dbl("catchmentSizePercent", required = FALSE),
        "assessment_unit_count" = tib_int("assessmentUnitCount", required = FALSE),
      ),
    ),
    "count" = tib_int("count", required = FALSE),
  )

  return(spec)
}
