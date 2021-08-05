actions_cache <- NULL
au_cache <- NULL

.onLoad <- function(libname, pkgname){
  hoard_actions <- hoardr::hoard()
  actions_cache <<- hoard_actions

  hoard_au <- hoardr::hoard()
  au_cache <<- hoard_au
}
