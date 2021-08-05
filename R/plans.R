#' Download Plans and Actions by HUC
#'
#' @param huc (character) 8-digit or higher HUC. required
#' @param organization_id (character). optional
#' @param summarize (logical)
#' @param tidy (logical) \code{TRUE} (default) the function returns a tidied tibble. \code{FALSE} the function returns the raw JSON string.
#' @param ... list of curl options passed to [crul::HttpClient()]
#'
#' @return tibble
#' @importFrom checkmate assert_character assert_logical makeAssertCollection reportAssertions
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
  plans_cache <- hoardr::hoard()
  path = "attains-public/api/plans"
  file <- file_key(path = path, arg_list = args)
  plans_cache$cache_path_set(path = file)
  plans_cache$mkdir()

  ## check if current results have been cached
  file_name <- file.path(plans_cache$cache_path_get(),
                         "plans.json")
  if(file.exists(file_name)) {
    message(paste0("reading cached file from: ", file_name))
    content <- readLines(file_name, warn = FALSE)
  } else { ## download data
    content <- xGET(path,
                    args,
                    file = file_name,
                    ...)
  }
  if(!isTRUE(tidy)) { ## return raw data
    return(content)
  } else { ## return parsed data
    content <- fromJSON(content, simplifyVector = FALSE)
  }
}
