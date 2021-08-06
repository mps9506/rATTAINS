#' Download HUC12 Summary
#'
#' Provides summary data for a 12-digit Hydrologic Unit Code (HUC12), based on
#' Assessment Units in the HUC12. Watershed boundaries may cross state
#' boundaries, so the service may return assessment units from multiple
#' organizations. Returns the assessment units in the HUC12, size and
#' percentages of assessment units considered Good, Unknown, or Impaired.
#'
#' @param huc (character) 12-digit hydrologic unit code. required
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return a list of tibbles
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
#' @importFrom tidyr unnest_wider unnest_longer
#' @export
huc12_summary <- function(huc, tidy = TRUE, ...) {

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

  ##setup file cache
  path = "attains-public/api/huc12summary"
  huc12_cache$mkdir()

  ## check if current results have been cached
  file_cache_name <- file_key(arg_list = args,
                              name = "huc12.json")
  file_path_name <- fs::path(huc12_cache$cache_path_get(),
                             file_cache_name)

  if(file.exists(file_path_name)) {
    message(paste0("reading cached file from: ", file_path_name))
    content <- readLines(file_path_name, warn = FALSE)
  } else {## download data
    content <- xGET(path,
                    args,
                    file = file_path_name,
                    ...)
  }
  if(!isTRUE(tidy)) {
    return(content)
  } else {
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
      unnest_wider(.data$assessmentUnits) %>%
      clean_names()

    ir_summary <- content[["items"]][[1]][16] %>%
      as_tibble() %>%
      unnest_wider(.data$summaryByIRCategory) %>%
      clean_names()

    use_summary <- content[["items"]][[1]][18] %>%
      as_tibble() %>%
      unnest_wider(.data$summaryByUse) %>%
      unnest_longer(.data$useAttainmentSummary) %>%
      unnest_wider(.data$useAttainmentSummary) %>%
      clean_names()

    param_summary <- content[["items"]][[1]][19] %>%
      as_tibble() %>%
      unnest_wider(.data$summaryByParameterImpairments) %>%
      clean_names()

    res_plan_summary <- content[["items"]][[1]][20]  %>%
      as_tibble() %>%
      unnest_wider(.data$summaryRestorationPlans) %>%
      clean_names()

    vision_plan_summary <- content[["items"]][[1]][21]  %>%
      as_tibble() %>%
      unnest_wider(.data$summaryVisionRestorationPlans) %>%
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
}
