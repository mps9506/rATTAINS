#' Download Plans and Actions by HUC
#' @description Returns information about plans or actions (TMDLs, 4B Actions,
#'   Alternative Actions, Protective Approach Actions) that have been finalized.
#'   This is similar to [actions] but returns data by HUC code and any
#'   assessment units covered by a plan or action within the specified HUC.
#' @param huc (character) Filters the returned actions by 8-digit or higher HUC.
#'   required
#' @param organization_id (character). Filters the returned actions by those
#'   belonging to the specified organization. Multiple values can be used.
#'   optional
#' @param summarize (logical) If \code{TRUE} the count of assessment units is
#'   returned rather than the assessment unit itdentifers for each action.
#'   Defaults to \code{FALSE}.
#' @param tidy (logical) \code{TRUE} (default) the function returns a list of
#'   tibbles. \code{FALSE} the function returns the raw JSON string.
#' @param .unnest (logical) \code{TRUE} (default) the function attempts to unnest
#'   data to longest format possible. This defaults to \code{TRUE} for backwards
#'   compatibility but it is suggested to use \code{FALSE}.
#' @param ... list of curl options passed to [crul::HttpClient()]
#' @details \code{huc} is a required argument. Multiple values are allowed for
#'   indicated arguments and should be included as a comma separated values in
#'   the string (eg. \code{organization_id="TCEQMAIN,DCOEE"}).
#' @return If \code{count = TRUE} returns a tibble that summarizes the count of
#'   actions returned by the query. If \code{count = FALSE} returns a list of
#'   tibbles including documents, use assessment data, and parameters assessment
#'   data identified by the query. If \code{tidy = FALSE} the raw JSON string is
#'   returned, else the JSON data is parsed and returned as a list of tibbles.
#' @note See [domain_values] to search values that can be queried. As of v1.0
#'   this function no longer returns the `documents`, `associated_permits`, or
#'   `plans` tibbles.
#' @importFrom checkmate assert_character assert_logical makeAssertCollection
#'   reportAssertions
#' @importFrom fs path
#' @importFrom rlang .data is_empty
#' @importFrom rlist list.filter
#' @export
#' @examples
#'
#' \dontrun{
#'
#' ## Query plans by huc
#' plans(huc ="020700100103")
#'
#' ## return a JSON string instead of list of tibbles
#' plans(huc = "020700100103", tidy = FALSE)
#' }
plans <- function(huc,
                  organization_id = NULL,
                  summarize = FALSE,
                  tidy = TRUE,
                  .unnest = TRUE,
                  ...) {

  ## check connectivity
  check_connectivity()

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
         x = list(summarize, tidy, .unnest),
         .var.name = c("summarize", "tidy", ".unnest"),
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

  path = "attains-public/api/plans"

  ## download data
  content <- xGET(path,
                  args,
                  file = NULL,
                  ...)

  if(is.null(content)) return(content)

  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else { ## return parsed data
    content <- plans_to_tibble(content = content,
                               summarize = summarize,
                               .unnest = .unnest)
    return(content)
  }
}

#'
#' @param content raw JSON
#' @param summarize character
#' @param .unnest logical
#'
#' @noRd
#' @import tibblify
#' @importFrom dplyr select
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr unnest
#' @importFrom tidyselect everything
plans_to_tibble <- function(content,
                            summarize,
                            .unnest) {

  ## parse JSON
  json_list <- fromJSON(content,
                        simplifyVector = FALSE,
                        simplifyDataFrame = FALSE,
                        flatten = FALSE)

  ## create tibblify specification
  spec <- spec_plans(summarize = summarize)

  ## nested list -> rectangular data
  content <- tibblify(json_list,
                      spec = spec,
                      unspecified = "drop")

  ## if unnest = FALSE do not unnest lists
  if(!isTRUE(.unnest)) {
    return(content)
  }

  if(summarize == "N") {
    content <- unpack(content$items, cols = everything())

    content_plans <- select(content, -c("specificWaters"))
    content_plans <- unnest(content_plans, cols = everything(),
                            names_repair = "unique", keep_empty = TRUE)
    content_plans <- unnest(content_plans, cols = everything(),
                            keep_empty = TRUE)
    content_plans <- clean_names(content_plans)

    content_sp_waters <- select(content, -c("documents"))
    content_sp_waters <- unnest(content_sp_waters, cols = everything(), keep_empty = TRUE)

    associated_pollutants <- select(content_sp_waters, -c("parameters"))
    associated_pollutants <- unnest(associated_pollutants, cols = everything(),
                                    keep_empty = TRUE)
    associated_pollutants <- clean_names(associated_pollutants)


    associated_parameters <- select(content_sp_waters, -c("associatedPollutants"))
    associated_parameters <- unnest(associated_parameters, cols = everything(),
                                    keep_empty = TRUE)
    associated_parameters <- unnest(associated_parameters, cols = everything(),
                                    keep_empty = TRUE)
    associated_parameters <- clean_names(associated_parameters)

    return(list(
      plans = content_plans,
      associated_pollutants = associated_pollutants,
      associated_parameters = associated_parameters
    ))
  }
  if(summarize == "Y") {

    content <- tibblify(json_list,
                        spec = spec,
                        unspecified = "drop")
    content <- unpack(content$items, cols = everything())


    associated_pollutants <- select(content, -c("parameters"))
    associated_pollutants <- unnest(associated_pollutants, cols = everything(),
                                    keep_empty = TRUE)
    associated_pollutants <- clean_names(associated_pollutants)

    associated_parameters <- select(content, -c("associatedPollutants"))
    associated_parameters <- unnest(associated_parameters, cols = everything(),
                                    keep_empty = TRUE)
    associated_parameters <- unnest(associated_parameters, cols = everything(),
                                    keep_empty = TRUE)
    associated_parameters <- clean_names(associated_parameters)

    return(list(
      associated_pollutants = associated_pollutants,
      associated_parameters = associated_parameters
    ))
  }
}


#' Create tibblify specification for plans
#' @param summarize character, one of 'Y' or 'N'.
#' @return tibblify specification
#' @keywords internal
#' @noRd
#' @import tibblify
spec_plans <- function(summarize) {

  if(summarize == "N") {
    spec <- tspec_object(
      tib_df(
        "items",
        tib_chr("actionIdentifier", required = FALSE),
        tib_chr("actionName", required = FALSE),
        "actionAgencyCode" = tib_chr("agencyCode", required = FALSE),
        tib_chr("actionTypeCode", required = FALSE),
        tib_chr("actionStatusCode", required = FALSE),
        tib_chr("completionDate", required = FALSE),
        tib_chr("organizationId", required = FALSE),
        tib_df(
          "documents",
          "documentAgencyCode" = tib_chr("agencyCode", required = FALSE),
          tib_df(
            "documentTypes",
            tib_chr("documentTypeCode", required = FALSE),
          ),
          tib_chr("documentFileType", required = FALSE),
          tib_chr("documentFileName", required = FALSE),
          tib_chr("documentName", required = FALSE),
          tib_unspecified("documentDescription", required = FALSE),
          tib_chr("documentComments", required = FALSE),
          tib_chr("documentURL", required = FALSE),
        ),
        tib_row(
          "associatedWaters",
          tib_df(
            "specificWaters",
            tib_chr("assessmentUnitIdentifier", required = FALSE),
            tib_df(
              "associatedPollutants",
              tib_chr("pollutantName", required = FALSE),
              tib_chr("pollutantSourceTypeCode", required = FALSE),
              tib_chr("explicitMarginofSafetyText", required = FALSE),
              tib_chr("implicitMarginofSafetyText", required = FALSE),
              tib_unspecified("loadAllocationDetails", required = FALSE),
              tib_df(
                "permits",
                tib_chr("NPDESIdentifier", required = FALSE),
                tib_chr("otherIdentifier", required = FALSE),
                tib_df(
                  "details",
                  tib_dbl("wasteLoadAllocationNumeric", required = FALSE),
                  tib_chr("wasteLoadAllocationUnitsText", required = FALSE),
                  tib_unspecified("seasonStartText", required = FALSE),
                  tib_unspecified("seasonEndText", required = FALSE),
                ),
              ),
              tib_chr("TMDLEndPointText", required = FALSE),
            ),
            tib_df(
              "parameters",
              tib_chr("parameterName", required = FALSE),
              tib_df(
                "associatedPollutants",
                tib_chr("pollutantName", required = FALSE),
              ),
            ),
            tib_unspecified("sources", required = FALSE),
          ),
        ),
        tib_row(
          "TMDLReportDetails",
          tib_unspecified("TMDLOtherIdentifier", required = FALSE),
          tib_chr("TMDLDate", required = FALSE),
          tib_chr("indianCountryIndicator", required = FALSE),
        ),
        tib_unspecified("pollutants", required = FALSE),
        tib_unspecified("associatedActions", required = FALSE),
        tib_unspecified("histories", required = FALSE),
      ),
      tib_int("count", required = FALSE),
    )
    if(summarize == "Y") {

    }
  }
  if(summarize == "Y") {
    spec <- tspec_object(
      tib_df(
        "items",
        tib_chr("actionIdentifier"),
        tib_chr("actionName"),
        tib_chr("agencyCode"),
        tib_chr("actionTypeCode"),
        tib_chr("actionStatusCode"),
        tib_chr("completionDate"),
        tib_chr("organizationId"),
        tib_row(
          "TMDLReportDetails",
          tib_unspecified("TMDLOtherIdentifier"),
          tib_chr("TMDLDate"),
          tib_chr("indianCountryIndicator"),
        ),
        tib_df(
          "associatedPollutants",
          tib_chr("pollutantName"),
          tib_chr("auCount"),
        ),
        tib_df(
          "parameters",
          tib_chr("parameterName"),
          tib_chr("auCount"),
        ),
        tib_unspecified("associatedActions"),
      ),
      tib_int("count"),
    )
  }
  return(spec)
}
