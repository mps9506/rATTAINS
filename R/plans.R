#' Download Plans and Actions by HUC
#'
#' @param huc (character) 8-digit or higher HUC. required
#' @param organization_id (character). optional
#' @param summarize (logical)
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @export
plans <- function(huc = NULL,
                  organization_id = NULL,
                  summarize = FALSE,
                  ...) {

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
  content <- xGET(path, args, ...)
  content <- fromJSON(content, simplifyVector = FALSE)
}
