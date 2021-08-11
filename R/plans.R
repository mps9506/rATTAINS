#' Download Plans and Actions by HUC
#'
#' @param huc (character) 8-digit or higher HUC. required
#' @param organization_id (character). optional
#' @param summarize (logical)
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return returns a list of tibbles
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
#' @importFrom fs path
#' @export
plans <- function(huc,
                  organization_id = NULL,
                  summarize = FALSE,
                  tidy = TRUE,
                  ...) {

  ## check that arguments are character
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_character,
         x = list(huc, organization_id),
         .var.name = c("huc", "organization_id"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  ## check logical
  coll <- checkmate::makeAssertCollection()
  mapply(FUN = checkmate::assert_logical,
         x = list(summarize, tidy),
         .var.name = c("summarize", "tidy"),
         MoreArgs = list(null.ok = TRUE,
                         add = coll))
  checkmate::reportAssertions(coll)

  summarize <- if(isTRUE(summarize)) {
    "Y"
  } else {"N"}

  args <- list(huc = huc,
               oganizationId = organization_id,
               summarize = summarize)
  args <- list.filter(args, !is.null(.data))
  required_args <- c("huc")
  args_present <- intersect(names(args), required_args)
  if(is_empty(args_present)) {
    stop("One of the following arguments must be provided: huc")
  }


  ##setup file cache
  path = "attains-public/api/plans"
  plans_cache$mkdir()

  ## check if current results have been cached
  file_cache_name <- file_key(arg_list = args,
                              name = "plans.json")
  file_path_name <- fs::path(plans_cache$cache_path_get(),
                             file_cache_name)

  if(file.exists(file_path_name)) {
    message(paste0("reading cached file from: ", file_path_name))
    content <- readLines(file_path_name, warn = FALSE)
  } else { ## download data
    content <- xGET(path,
                    args,
                    file = file_path_name,
                    ...)
  }
  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else { ## return parsed data
    content <- plans_to_tibble(content = content)
    return(content)
  }
}

#'
#' @param content raw JSON
#' @param summarize character
#'
#' @noRd
#' @import tidyjson
#' @importFrom dplyr select rename filter mutate
#' @importFrom janitor clean_names
#' @importFrom purrr map flatten_dbl flatten_chr
#' @importFrom rlang .data
#' @importFrom tibble as_tibble tibble
#' @importFrom tidyr unnest
plans_to_tibble <- function(content, summarize) {

  if(summarize=="N"){
    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifier = jstring("actionIdentifier"),
                    actionName = jstring("actionName"),
                    agencyCode = jstring("agencyCode"),
                    actionTypeCode = jstring("actionTypeCode"),
                    actionStatusCode = jstring("actionStatusCode"),
                    completionDate = jstring("completionDate"),
                    organizationId = jstring("organizationId"),
                    associatedActions = jstring("associatedActions")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("TMDLReportDetails") %>%
      spread_values(TMDLOtherIdentifier = jstring("TMDLOtherIdentifier"),
                    TMDLDate = jstring("TMDLDate"),
                    indianCountryIdentifier = jstring("indianCountryIdentifier")) %>%
      as_tibble() %>%
      clean_names() -> content_plans

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifer = jstring("actionIdentifier")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("documents") %>%
      gather_array() %>%
      spread_values(documentFileType = jstring("docuementFileType"),
                    documentFileName = jstring("documentFileName"),
                    documentName = jstring("documentName"),
                    documentDescription = jstring("documentDescription"),
                    documentComments = jstring("documentComments"),
                    documentURL = jstring("documentURL")) %>%
      select(-c(.data$array.index))  %>%
      enter_object("documentTypes") %>%
      gather_array() %>%
      spread_values(documentTypeCode = jstring("documentTypeCode")) %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      clean_names() -> content_documents

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifer = jstring("actionIdentifier")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("associatedWaters") %>%
      spread_all() %>%
      enter_object("specificWaters") %>%
      gather_array() %>%
      spread_values(assessmentUnitIdentifier = jstring("assessmentUnitIdentifier")) %>%
      select(-c(.data$array.index))  %>%
      enter_object("associatedPollutants") %>%
      gather_array() %>%
      spread_values(pollutantName = jstring("pollutantName"),
                    explicitMarginofSafetyText = jstring("explicitMarginofSafetyText"),
                    implicitMarginofSafetyText = jstring("implicitMarginofSafetyText"),
                    TMDLEndPointText = jstring("TMDLEndPointText")) %>%
      select(-c(.data$array.index))  %>%
      as_tibble() %>%
      clean_names()  -> content_associated_pollutants

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifer = jstring("actionIdentifier")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("associatedWaters") %>%
      spread_all() %>%
      enter_object("specificWaters") %>%
      gather_array() %>%
      spread_values(assessmentUnitIdentifier = jstring("assessmentUnitIdentifier")) %>%
      select(-c(.data$array.index))  %>%
      enter_object("parameters") %>%
      gather_array() %>%
      spread_values(parameterName = jstring("parameterName")) %>%
      select(-c(.data$array.index))  %>%
      enter_object("associatedPollutants") %>%
      gather_array() %>%
      spread_values(pollutantName = jstring("pollutantName")) %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      clean_names()  -> content_associated_parameters

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifer = jstring("actionIdentifier")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("associatedWaters") %>%
      spread_all() %>%
      enter_object("specificWaters") %>%
      gather_array() %>%
      spread_values(assessmentUnitIdentifier = jstring("assessmentUnitIdentifier")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("associatedPollutants") %>%
      gather_array() %>%
      spread_values(pollutantName = jstring("pollutantName")) %>%
      select(-c(.data$array.index)) %>%
      enter_object("permits") %>%
      gather_array() %>%
      spread_values(NPDESIdentifier = jstring("NPDESIdentifier"),
                    otherIdentifier = jstring("otherIdentifier")) %>%
      mutate(details = map(.data$..JSON, ~{
        .x[["details"]] %>% {
          tibble(
            wasteLoadAllocationNumeric = map(., "wasteLoadAllocationNumeric", .default = NA) %>% purrr::flatten_dbl(),
            wasteLoadAllocationUnitsText = map(., "wasteLoadAllocationUnitsText", .default = NA) %>% purrr::flatten_chr(),
            seasonStartText = map(., "seasonStartText", .default = NA) %>% purrr::flatten_chr(),
            seasonEndText = map(., "seasonEndText", .default = NA) %>% purrr::flatten_chr()
          )
        }
      })) %>%
      unnest(.data$details, keep_empty = TRUE) %>%
      as_tibble() %>%
      clean_names() -> content_associated_permits

    return(list(plans = content_plans,
                documents = content_documents,
                associated_pollutants = content_associated_pollutants,
                associated_parameters = content_associated_parameters,
                associated_permits = content_associated_permits))
  }

  if(summarize==Y) {
    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifier = jstring("actionIdentifier"),
                    actionName = jstring("actionName"),
                    agencyCode = jstring("agencyCode"),
                    actionTypeCode = jstring("actionTypeCode"),
                    actionStatusCode = jstring("actionStatusCode"),
                    completionDate = jstring("completionDate"),
                    organizationId = jstring("organizationId"),
                    associatedActions = jstring("associatedActions")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("TMDLReportDetails") %>%
      spread_values(TMDLOtherIdentifier = jstring("TMDLOtherIdentifier"),
                    TMDLDate = jstring("TMDLDate"),
                    indianCountryIdentifier = jstring("indianCountryIdentifier")) %>%
      as_tibble() %>%
      clean_names() -> content_plans

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifer = jstring("actionIdentifier")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("associatedPollutants") %>%
      gather_array() %>%
      spread_values(pollutantName = jstring("pollutantName"),
                    auCount = jstring("auCount")) %>%
      select(-c(.data$array.index))  %>%
      as_tibble() %>%
      clean_names()  -> content_associated_pollutants

    content %>%
      enter_object("items") %>%
      gather_array() %>%
      spread_values(actionIdentifer = jstring("actionIdentifier")) %>%
      select(-c(.data$document.id, .data$array.index)) %>%
      enter_object("parameters") %>%
      gather_array() %>%
      spread_values(parameterName = jstring("parameterName"),
                    auCount = jstring("auCount")) %>%
      select(-c(.data$array.index)) %>%
      as_tibble() %>%
      clean_names()  -> content_associated_parameters

    return(list(plans = content_plans,
                associated_pollutants = content_associated_pollutants,
                associated_parameters = content_associated_parameters))
  }

}
