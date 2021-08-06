## setup file caching using hoardr package
## the following code is modified from
## the rnoaa package by Scott Chamberlain
## https://github.com/ropensci/rnoaa
## licensed under MIT

actions_cache <- NULL
au_cache <- NULL
assessments_cache <- NULL
dv_cache <- NULL
huc12_cache <- NULL
plans_cache <- NULL
state_cache <- NULL
surveys_cache <- NULL

.onLoad <- function(libname, pkgname){
  hoard_actions <- hoardr::hoard()
  hoard_actions$cache_path_set(path = fs::path("attains-public", "api", "actions"))
  actions_cache <<- hoard_actions

  hoard_au <- hoardr::hoard()
  hoard_au$cache_path_set(path = fs::path("attains-public", "api", "assessmentUnits"))
  au_cache <<- hoard_au

  hoard_assessments <- hoardr::hoard()
  hoard_assessments$cache_path_set(path = fs::path("attains-public", "api", "assessments"))
  assessments_cache <<- hoard_assessments

  hoard_dv <- hoardr::hoard()
  hoard_dv$cache_path_set(path = fs::path("attains-public", "api", "domains"))
  dv_cache <<- hoard_dv

  hoard_huc12 <- hoardr::hoard()
  hoard_huc12$cache_path_set(path = fs::path("attains-public", "api", "huc12summary"))
  huc12_cache <<- hoard_huc12

  hoard_plans <- hoardr::hoard()
  hoard_plans$cache_path_set(path = fs::path("attains-public", "api", "plans"))
  plans_cache <<- hoard_plans

  hoard_state <- hoardr::hoard()
  hoard_state$cache_path_set(path = fs::path("attains-public", "api", "usesStateSummary"))
  state_cache <<- hoard_state

  hoard_surveys <- hoardr::hoard()
  hoard_surveys$cache_path_set(path = fs::path("attains-public", "api", "surveys"))
  surveys_cache <<- hoard_surveys
}
