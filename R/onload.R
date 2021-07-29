actions_cache <- NULL

.onLoad <- function(libname, pkgname){
  hoard_actions <- hoardr::hoard()
  hoard_actions$cache_path_set("rATTAINS_actions")
  actions_cache <<- hoard_actions
}
