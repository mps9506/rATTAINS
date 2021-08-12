#' @title rATTAINS caching
#' @description Manage data caches
#' @name rATTAINS_caching
#' @details To get the cache directory for a data source, see the method
#'   `x$cache_path_get()`
#'
#'   `cache_delete` only accepts 1 file name, while `cache_delete_all` doesn't
#'   accept any names, but deletes all files. For deleting many specific files,
#'   use `cache_delete` in a [lapply()] type call
#'
#'   Note that cached files will continue to be used until they are deleted. You
#'   should occassionally delete all cached files.
#'
#'
#' @section Useful user functions:
#'
#'   Assuming x is a `HoardClient` class object, e.g., `actions_cache`
#'
#' - `x$cache_path_get()` get cache path
#' - `x$cache_path_set()` set cache path
#' - `x$list()` returns a character vector of full path file names
#' - `x$files()` returns file objects with metadata
#' - `x$details()` returns files with details
#' - `x$delete()` delete specific files
#' - `x$delete_all()` delete all files, returns nothing
#'
#' @section Caching objects for each data source:
#' - `actions()`: `actions_cache`
#' - `assessments()`: `assessments_cache`
#' - `assessment_units()`: `au_cache`
#' - `domain_values()`: `dv_cache`
#' - `huc12_summary()`: `huc12_cache`
#' - `plans()`: `plans_cache`
#' - `state_summary()`: `state_cache`
#' - `surveys()`: `surveys_cache`
#'
NULL

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"actions_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"au_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"assessments_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"dv_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"huc12_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"plans_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"state_cache"

#' @rdname rATTAINS_caching
#' @format NULL
#' @usage NULL
#' @export
"surveys_cache"
