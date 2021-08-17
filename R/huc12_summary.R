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
#' @note See [domain_values] to search values that can be queried. Data
#'   downloaded from the EPA webservice is automatically cached to reduce
#'   uneccessary calls to the server. To managed cached files see
#'   [rATTAINS_caching]
#' @import tidyjson
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom dplyr select
#' @importFrom fs path
#' @importFrom janitor clean_names
#' @importFrom rlang .data
#' @importFrom tibble as_tibble
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
    ## parse json
    huc_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      as_tibble() %>%
      janitor::clean_names()

    au_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      enter_object("assessmentUnits") %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      janitor::clean_names()


    ir_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      enter_object("summaryByIRCategory") %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      janitor::clean_names()

    use_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      enter_object("summaryByUseGroup") %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      enter_object("useAttainmentSummary") %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      janitor::clean_names()

    param_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      enter_object("summaryByParameterImpairments")   %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      janitor::clean_names()

    res_plan_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      enter_object("summaryRestorationPlans")   %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      janitor::clean_names()


    vision_plan_summary <- content %>%
      enter_object("items") %>%
      gather_array() %>%
      select(-c(.data$array.index, .data$document.id)) %>%
      enter_object("summaryVisionRestorationPlans")   %>%
      gather_array() %>%
      spread_all() %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      janitor::clean_names()

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
