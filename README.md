
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![R-CMD-check](https://github.com/mps9506/rATTAINS/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/rATTAINS/actions)
[![codecov](https://codecov.io/gh/mps9506/rATTAINS/branch/master/graph/badge.svg?token=J45QIKWA8E)](https://codecov.io/gh/mps9506/rATTAINS)
<!-- badges: end -->

Work in progress, probably don’t use this yet.

rATTAINS provides functions for downloading tidy data from the United
States (U.S.) Environmental Protection Agency (EPA)
[ATTAINS](https://www.epa.gov/waterdata/attains) webservice. ATTAINS is
the online system used to track and report Clean Water Act assessments
and Total Maximum Daily Loads (TMDLs) in U.S. surface waters. rATTAINS
facilitates access to the [public information
webservice](https://www.epa.gov/waterdata/get-data-access-public-attains-data)
made available through the EPA.

Install from Github

``` r
install.packages("remotes")
remotes::install_github("mps9506/rATTAINS")
```

## Functions and webservices

There are eight user available functions that correspond with the first
eight web services detailed by
[EPA](https://www.epa.gov/sites/default/files/2020-10/documents/attains_how_to_access_web_services_2020-10-28.pdf).
All arguments are case sensitive. By default the functions attempt to
provide flattened “tidy” data as a single or multiple dataframes. By
using the `tidy = FALSE` argument in the function below, the raw JSON
will be read into the session for the user to parse if desired. This can
be useful since some webservices provide different results based on the
query and the tidying process used in rATTAINS might make poor
assumptions in the data flattening process. If the function returns
unexpected results, try parsing the raw JSON string.

-   `state_summary()` provides summary information for assessed uses for
    organizations and by integrated reporting cycle.

-   `huc_12_summary()` provides summary information about impairments,
    actions, and documents for the specified 12-digit HUC (watershed).

-   `actions()` provides a summary of information for particular
    finalized actions (TMDLs and related).

-   `assessment_units()` provides summary data about the specified
    assessment unit (water body).

-   `plans()` returns a summary of the plans (TMDLs and related) within
    a specified HUC.

-   `domain_values()` returns allowed values in ATTAINS. By default (no
    arguments) the function returns a list of allowed `domain_names`.

-   `assessment_units()` returns a summary of information about
    assessment units.

-   `surveys()` returns results from state statistical survey results in
    ATTAINS.

# Examples:

``` r
library(rATTAINS)
df <- state_summary(organization_id = "TCEQMAIN", reporting_cycle = "2020")
#> reading cached file from: C:/Users/MICHAE~1.SCH/AppData/Local/Cache/R/attains-public/api/usesStateSummary/TCEQMAIN_2020state_summary.json
str(df)
#> tibble [31 x 13] (S3: tbl_df/tbl/data.frame)
#>  $ organization_identifier: chr [1:31] "TCEQMAIN" "TCEQMAIN" "TCEQMAIN" "TCEQMAIN" ...
#>  $ organization_name      : chr [1:31] "Texas" "Texas" "Texas" "Texas" ...
#>  $ organization_type_text : chr [1:31] "State" "State" "State" "State" ...
#>  $ reporting_cycle        : chr [1:31] "2020" "2020" "2020" "2020" ...
#>  $ combined_cycles        : chr [1:31] NA NA NA NA ...
#>  $ water_type_code        : chr [1:31] "ESTUARY" "ESTUARY" "ESTUARY" "ESTUARY" ...
#>  $ units_code             : chr [1:31] "Square Miles" "Square Miles" "Square Miles" "Square Miles" ...
#>  $ use_name               : chr [1:31] "Aquatic Life Use" "Recreation Use" "Oyster Waters Use" "General Use" ...
#>  $ fully_supporting       : chr [1:31] "1861.320000" "2255.080000" "1520.860000" "2513.770000" ...
#>  $ fully_supporting_count : chr [1:31] "57" "61" "21" "55" ...
#>  $ not_assessed           : chr [1:31] "46.190000" "45.490000" NA "45.490000" ...
#>  $ not_assessed_count     : chr [1:31] "6" "5" NA "5" ...
#>  $ parameters             :List of 31
#>   ..$ : tibble [7 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:7] "TOXIC INORGANICS" "ORGANIC ENRICHMENT/OXYGEN DEPLETION" "PESTICIDES" "TOXIC ORGANICS" ...
#>   .. ..$ cause                         : chr [1:7] NA "616.850000" NA NA ...
#>   .. ..$ cause_count                   : chr [1:7] NA "5" NA NA ...
#>   .. ..$ meeting_criteria              : num [1:7] NA 1901.8 NA NA 96.9 ...
#>   .. ..$ meeting_criteria_count        : num [1:7] NA 62 NA NA 8 NA 8
#>   .. ..$ insufficent_information       : num [1:7] 2.76 NA 3.2 1.07 344.3 ...
#>   .. ..$ insufficient_information_count: num [1:7] 1 NA 3 2 6 7 5
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr "104.570000"
#>   .. ..$ cause_count                   : chr "5"
#>   .. ..$ meeting_criteria              : num 2255
#>   .. ..$ meeting_criteria_count        : num 61
#>   .. ..$ insufficent_information       : num NA
#>   .. ..$ insufficient_information_count: num NA
#>   ..$ : tibble [3 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:3] "PATHOGENS" "FISH CONSUMPTION ADVISORY" "METALS (OTHER THAN MERCURY)"
#>   .. ..$ cause                         : chr [1:3] "291.590000" NA "30.470000"
#>   .. ..$ cause_count                   : chr [1:3] "21" NA "1"
#>   .. ..$ meeting_criteria              : num [1:3] NA 1521 NA
#>   .. ..$ meeting_criteria_count        : num [1:3] NA 21 NA
#>   .. ..$ insufficent_information       : num [1:3] NA 738 NA
#>   .. ..$ insufficient_information_count: num [1:3] NA 17 NA
#>   ..$ : tibble [2 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:2] "PH/ACIDITY/CAUSTIC CONDITIONS" "TEMPERATURE"
#>   .. ..$ cause                         : chr [1:2] NA NA
#>   .. ..$ cause_count                   : chr [1:2] NA NA
#>   .. ..$ meeting_criteria              : num [1:2] 2514 2514
#>   .. ..$ meeting_criteria_count        : num [1:2] 55 55
#>   .. ..$ insufficent_information       : num [1:2] NA NA
#>   .. ..$ insufficient_information_count: num [1:2] NA NA
#>   ..$ : tibble [4 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:4] "METALS (OTHER THAN MERCURY)" "MERCURY" "DIOXINS" "POLYCHLORINATED BIPHENYLS (PCBS)"
#>   .. ..$ cause                         : chr [1:4] NA "1.630000" "541.600000" "582.990000"
#>   .. ..$ cause_count                   : chr [1:4] NA "1" "30" "32"
#>   .. ..$ meeting_criteria              : num [1:4] 275 275 NA NA
#>   .. ..$ meeting_criteria_count        : num [1:4] 14 14 NA NA
#>   .. ..$ insufficent_information       : num [1:4] 0.7 0.7 NA NA
#>   .. ..$ insufficient_information_count: num [1:4] 1 1 NA NA
#>   ..$ : tibble [7 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:7] "MERCURY" "TOXIC ORGANICS" "RADIATION" "METALS (OTHER THAN MERCURY)" ...
#>   .. ..$ cause                         : chr [1:7] NA NA NA NA ...
#>   .. ..$ cause_count                   : chr [1:7] NA NA NA NA ...
#>   .. ..$ meeting_criteria              : num [1:7] 50079 NA 84576 361497 NA ...
#>   .. ..$ meeting_criteria_count        : num [1:7] 23 NA 25 77 NA 325 145
#>   .. ..$ insufficent_information       : num [1:7] 76180 6208 194218 98782 6208 ...
#>   .. ..$ insufficient_information_count: num [1:7] 10 1 16 17 1 2 11
#>   ..$ : tibble [8 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:8] "TOXIC ORGANICS" "TOTAL TOXICS" "MERCURY" "POLYCHLORINATED BIPHENYLS (PCBS)" ...
#>   .. ..$ cause                         : chr [1:8] NA "1409.680000" NA NA ...
#>   .. ..$ cause_count                   : chr [1:8] NA "3" NA NA ...
#>   .. ..$ meeting_criteria              : num [1:8] NA NA 25338 NA NA ...
#>   .. ..$ meeting_criteria_count        : num [1:8] NA NA 13 NA NA 1 310 49
#>   .. ..$ insufficent_information       : num [1:8] 46764 NA 98216 38025 46764 ...
#>   .. ..$ insufficient_information_count: num [1:8] 8 NA 10 4 8 NA 8 15
#>   ..$ : tibble [6 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:6] "MERCURY" "METALS (OTHER THAN MERCURY)" "POLYCHLORINATED BIPHENYLS (PCBS)" "TOXIC ORGANICS" ...
#>   .. ..$ cause                         : chr [1:6] "310089.930000" NA "91047.060000" NA ...
#>   .. ..$ cause_count                   : chr [1:6] "41" NA "19" NA ...
#>   .. ..$ meeting_criteria              : num [1:6] 50328 405827 NA NA NA ...
#>   .. ..$ meeting_criteria_count        : num [1:6] 24 86 NA NA NA NA
#>   .. ..$ insufficent_information       : num [1:6] 77313 83521 NA 17097 35588 ...
#>   .. ..$ insufficient_information_count: num [1:6] 11 12 NA 3 5 NA
#>   ..$ : tibble [5 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:5] "PH/ACIDITY/CAUSTIC CONDITIONS" "SALINITY/TOTAL DISSOLVED SOLIDS/CHLORIDES/SULFATES" "ALGAL GROWTH" "NUTRIENTS" ...
#>   .. ..$ cause                         : chr [1:5] "103304.230000" "133596.230000" "51036.370000" NA ...
#>   .. ..$ cause_count                   : chr [1:5] "30" "22" "15" NA ...
#>   .. ..$ meeting_criteria              : num [1:5] 1059144 1357298 229395 359677 1059144
#>   .. ..$ meeting_criteria_count        : num [1:5] 276 349 56 75 276
#>   .. ..$ insufficent_information       : num [1:5] 25955 2191 535791 394342 25955
#>   .. ..$ insufficient_information_count: num [1:5] 5 1 187 112 5
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr "1008.680000"
#>   .. ..$ cause_count                   : chr "2"
#>   .. ..$ meeting_criteria              : num 842009
#>   .. ..$ meeting_criteria_count        : num 242
#>   .. ..$ insufficent_information       : num 34629
#>   .. ..$ insufficient_information_count: num 12
#>   ..$ : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr(0) 
#>   .. ..$ cause                         : chr(0) 
#>   .. ..$ cause_count                   : chr(0) 
#>   .. ..$ meeting_criteria              : num(0) 
#>   .. ..$ meeting_criteria_count        : num(0) 
#>   .. ..$ insufficent_information       : num(0) 
#>   .. ..$ insufficient_information_count: num(0) 
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr "6496.510000"
#>   .. ..$ cause_count                   : chr "425"
#>   .. ..$ meeting_criteria              : num 7352
#>   .. ..$ meeting_criteria_count        : num 339
#>   .. ..$ insufficent_information       : num 1068
#>   .. ..$ insufficient_information_count: num 44
#>   ..$ : tibble [8 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:8] "CAUSE UNKNOWN - IMPAIRED BIOTA" "TOXIC ORGANICS" "TOTAL TOXICS" "MERCURY" ...
#>   .. ..$ cause                         : chr [1:8] "274.940000" NA "4.930000" NA ...
#>   .. ..$ cause_count                   : chr [1:8] "17" NA "2" NA ...
#>   .. ..$ meeting_criteria              : num [1:8] 691 NA NA 484 16040 ...
#>   .. ..$ meeting_criteria_count        : num [1:8] 41 NA NA 14 847 69 NA NA
#>   .. ..$ insufficent_information       : num [1:8] 142 302 NA 320 971 ...
#>   .. ..$ insufficient_information_count: num [1:8] 5 17 NA 19 46 36 18 6
#>   ..$ : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr(0) 
#>   .. ..$ cause                         : chr(0) 
#>   .. ..$ cause_count                   : chr(0) 
#>   .. ..$ meeting_criteria              : num(0) 
#>   .. ..$ meeting_criteria_count        : num(0) 
#>   .. ..$ insufficent_information       : num(0) 
#>   .. ..$ insufficient_information_count: num(0) 
#>   ..$ : tibble [8 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:8] "POLYCHLORINATED BIPHENYLS (PCBS)" "MERCURY" "TOXIC INORGANICS" "NUTRIENTS" ...
#>   .. ..$ cause                         : chr [1:8] NA NA NA NA ...
#>   .. ..$ cause_count                   : chr [1:8] NA NA NA NA ...
#>   .. ..$ meeting_criteria              : num [1:8] NA 431 5476 9147 NA ...
#>   .. ..$ meeting_criteria_count        : num [1:8] NA 16 216 393 NA NA 39 11
#>   .. ..$ insufficent_information       : num [1:8] 25.8 255.9 527 NA 267.3 ...
#>   .. ..$ insufficient_information_count: num [1:8] 1 13 21 NA 13 13 15 32
#>   ..$ : tibble [6 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:6] "MERCURY" "METALS (OTHER THAN MERCURY)" "DIOXINS" "PESTICIDES" ...
#>   .. ..$ cause                         : chr [1:6] "390.300000" "8.280000" "632.440000" NA ...
#>   .. ..$ cause_count                   : chr [1:6] "19" "2" "31" NA ...
#>   .. ..$ meeting_criteria              : num [1:6] 967 1776.9 NA 19.4 19.4 ...
#>   .. ..$ meeting_criteria_count        : num [1:6] 33 98 NA 2 2 NA
#>   .. ..$ insufficent_information       : num [1:6] 683 845 NA 420 401 ...
#>   .. ..$ insufficient_information_count: num [1:6] 29 43 NA 23 21 4
#>   ..$ : tibble [5 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:5] "NUTRIENTS" "SALINITY/TOTAL DISSOLVED SOLIDS/CHLORIDES/SULFATES" "ALGAL GROWTH" "PH/ACIDITY/CAUSTIC CONDITIONS" ...
#>   .. ..$ cause                         : chr [1:5] NA "1591.820000" "90.740000" "42.940000" ...
#>   .. ..$ cause_count                   : chr [1:5] NA "44" "5" "4" ...
#>   .. ..$ meeting_criteria              : num [1:5] 190 13427 NA 10312 10301
#>   .. ..$ meeting_criteria_count        : num [1:5] 9 592 NA 453 453
#>   .. ..$ insufficent_information       : num [1:5] 1166 NA 847 320 320
#>   .. ..$ insufficient_information_count: num [1:5] 55 NA 38 14 14
#>   ..$ : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr(0) 
#>   .. ..$ cause                         : chr(0) 
#>   .. ..$ cause_count                   : chr(0) 
#>   .. ..$ meeting_criteria              : num(0) 
#>   .. ..$ meeting_criteria_count        : num(0) 
#>   .. ..$ insufficent_information       : num(0) 
#>   .. ..$ insufficient_information_count: num(0) 
#>   ..$ : tibble [2 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:2] "METALS (OTHER THAN MERCURY)" "MERCURY"
#>   .. ..$ cause                         : chr [1:2] NA NA
#>   .. ..$ cause_count                   : chr [1:2] NA NA
#>   .. ..$ meeting_criteria              : num [1:2] 197 197
#>   .. ..$ meeting_criteria_count        : num [1:2] 1 1
#>   .. ..$ insufficent_information       : num [1:2] NA NA
#>   .. ..$ insufficient_information_count: num [1:2] NA NA
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr NA
#>   .. ..$ cause_count                   : chr NA
#>   .. ..$ meeting_criteria              : num 197
#>   .. ..$ meeting_criteria_count        : num 1
#>   .. ..$ insufficent_information       : num NA
#>   .. ..$ insufficient_information_count: num NA
#>   ..$ : tibble [3 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:3] "MERCURY" "ORGANIC ENRICHMENT/OXYGEN DEPLETION" "METALS (OTHER THAN MERCURY)"
#>   .. ..$ cause                         : chr [1:3] NA "197.090000" NA
#>   .. ..$ cause_count                   : chr [1:3] NA "1" NA
#>   .. ..$ meeting_criteria              : num [1:3] 197 NA 197
#>   .. ..$ meeting_criteria_count        : num [1:3] 1 NA 1
#>   .. ..$ insufficent_information       : num [1:3] NA NA NA
#>   .. ..$ insufficient_information_count: num [1:3] NA NA NA
#>   ..$ : tibble [2 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:2] "NUTRIENTS" "TOXIC INORGANICS"
#>   .. ..$ cause                         : chr [1:2] NA NA
#>   .. ..$ cause_count                   : chr [1:2] NA NA
#>   .. ..$ meeting_criteria              : num [1:2] 47.6 47.6
#>   .. ..$ meeting_criteria_count        : num [1:2] 2 2
#>   .. ..$ insufficent_information       : num [1:2] NA NA
#>   .. ..$ insufficient_information_count: num [1:2] NA NA
#>   ..$ : tibble [7 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:7] "TOXIC ORGANICS" "MERCURY" "ORGANIC ENRICHMENT/OXYGEN DEPLETION" "METALS (OTHER THAN MERCURY)" ...
#>   .. ..$ cause                         : chr [1:7] NA NA "158.990000" NA ...
#>   .. ..$ cause_count                   : chr [1:7] NA NA "35" NA ...
#>   .. ..$ meeting_criteria              : num [1:7] NA 63.9 795.9 75.6 NA ...
#>   .. ..$ meeting_criteria_count        : num [1:7] NA 15 89 16 NA NA NA
#>   .. ..$ insufficent_information       : num [1:7] 27.5 82.7 54.7 72 27.5 ...
#>   .. ..$ insufficient_information_count: num [1:7] 6 7 4 8 6 NA 9
#>   ..$ : tibble [5 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:5] "PH/ACIDITY/CAUSTIC CONDITIONS" "TEMPERATURE" "ALGAL GROWTH" "NUTRIENTS" ...
#>   .. ..$ cause                         : chr [1:5] "4.710000" NA NA NA ...
#>   .. ..$ cause_count                   : chr [1:5] "1" NA NA NA ...
#>   .. ..$ meeting_criteria              : num [1:5] 640 640 NA NA 61
#>   .. ..$ meeting_criteria_count        : num [1:5] 69 69 NA NA 13
#>   .. ..$ insufficent_information       : num [1:5] 47.32 47.32 7.69 7.69 NA
#>   .. ..$ insufficient_information_count: num [1:5] 3 3 2 2 NA
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr "607.880000"
#>   .. ..$ cause_count                   : chr "80"
#>   .. ..$ meeting_criteria              : num 182
#>   .. ..$ meeting_criteria_count        : num 19
#>   .. ..$ insufficent_information       : num 6.75
#>   .. ..$ insufficient_information_count: num 1
#>   ..$ : tibble [4 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:4] "MERCURY" "METALS (OTHER THAN MERCURY)" "POLYCHLORINATED BIPHENYLS (PCBS)" "DIOXINS"
#>   .. ..$ cause                         : chr [1:4] "3.760000" NA "337.200000" "285.450000"
#>   .. ..$ cause_count                   : chr [1:4] "1" NA "56" "48"
#>   .. ..$ meeting_criteria              : num [1:4] 63.9 27 NA NA
#>   .. ..$ meeting_criteria_count        : num [1:4] 15 7 NA NA
#>   .. ..$ insufficent_information       : num [1:4] 10.8 10.8 61.5 NA
#>   .. ..$ insufficient_information_count: num [1:4] 1 1 12 NA
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "MERCURY"
#>   .. ..$ cause                         : chr "1338.210000"
#>   .. ..$ cause_count                   : chr "10"
#>   .. ..$ meeting_criteria              : num NA
#>   .. ..$ meeting_criteria_count        : num NA
#>   .. ..$ insufficent_information       : num NA
#>   .. ..$ insufficient_information_count: num NA
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr "159.450000"
#>   .. ..$ cause_count                   : chr "2"
#>   .. ..$ meeting_criteria              : num 140
#>   .. ..$ meeting_criteria_count        : num 1
#>   .. ..$ insufficent_information       : num NA
#>   .. ..$ insufficient_information_count: num NA
#>   ..$ : tibble [2 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:2] "TEMPERATURE" "PH/ACIDITY/CAUSTIC CONDITIONS"
#>   .. ..$ cause                         : chr [1:2] NA NA
#>   .. ..$ cause_count                   : chr [1:2] NA NA
#>   .. ..$ meeting_criteria              : num [1:2] 347 347
#>   .. ..$ meeting_criteria_count        : num [1:2] 4 4
#>   .. ..$ insufficent_information       : num [1:2] NA NA
#>   .. ..$ insufficient_information_count: num [1:2] NA NA
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "ORGANIC ENRICHMENT/OXYGEN DEPLETION"
#>   .. ..$ cause                         : chr NA
#>   .. ..$ cause_count                   : chr NA
#>   .. ..$ meeting_criteria              : num 347
#>   .. ..$ meeting_criteria_count        : num 4
#>   .. ..$ insufficent_information       : num NA
#>   .. ..$ insufficient_information_count: num NA
#>   ..$ : tibble [1 x 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr "PATHOGENS"
#>   .. ..$ cause                         : chr "2.030000"
#>   .. ..$ cause_count                   : chr "4"
#>   .. ..$ meeting_criteria              : num 137
#>   .. ..$ meeting_criteria_count        : num 57
#>   .. ..$ insufficent_information       : num NA
#>   .. ..$ insufficient_information_count: num NA
```

``` r
df <- huc12_summary(huc = "020700100204")
#> reading cached file from: C:/Users/MICHAE~1.SCH/AppData/Local/Cache/R/attains-public/api/huc12summary/020700100204huc12.json
str(df)
#> List of 7
#>  $ huc_summary        : tibble [1 x 14] (S3: tbl_df/tbl/data.frame)
#>   ..$ huc12                                         : chr "020700100204"
#>   ..$ assessment_unit_count                         : num 20
#>   ..$ total_catchment_area_sq_mi                    : num 46.2
#>   ..$ total_huc_area_sq_mi                          : num 46.2
#>   ..$ assessed_catchment_area_sq_mi                 : num 44.1
#>   ..$ assessed_catchment_area_percent               : num 95.4
#>   ..$ assessed_good_catchment_area_sq_mi            : num 1.77
#>   ..$ assessed_good_catchment_area_percent          : num 3.83
#>   ..$ assessed_unknown_catchment_area_sq_mi         : num 0
#>   ..$ assessed_unknown_catchment_area_percent       : num 0
#>   ..$ contain_impaired_waters_catchment_area_sq_mi  : num 44.1
#>   ..$ contain_impaired_waters_catchment_area_percent: num 95.4
#>   ..$ contain_restoration_catchment_area_sq_mi      : num 44.1
#>   ..$ contain_restoration_catchment_area_percent    : num 95.4
#>  $ au_summary         : tibble [20 x 1] (S3: tbl_df/tbl/data.frame)
#>   ..$ assessment_unit_id: chr [1:20] "MD-ANATF-02140205" "MD-02140205-Northwest_Branch" "MD-02140205" "DCTFD01R_00" ...
#>  $ ir_summary         : tibble [3 x 4] (S3: tbl_df/tbl/data.frame)
#>   ..$ epa_ir_category_name  : chr [1:3] "1" "4A" "5"
#>   ..$ catchment_size_sq_mi  : num [1:3] 1.77 25.35 37.89
#>   ..$ catchment_size_percent: num [1:3] 3.83 54.81 81.93
#>   ..$ assessment_unit_count : num [1:3] 2 11 7
#>  $ use_summary        : tibble [6 x 5] (S3: tbl_df/tbl/data.frame)
#>   ..$ use_group_name        : chr [1:6] "ECOLOGICAL_USE" "FISHCONSUMPTION_USE" "FISHCONSUMPTION_USE" "FISHCONSUMPTION_USE" ...
#>   ..$ use_attainment        : chr [1:6] "Not Supporting" "Fully Supporting" "Insufficient Information" "Not Supporting" ...
#>   ..$ catchment_size_sq_mi  : num [1:6] 19.49 1.77 1.91 22.78 1.91 ...
#>   ..$ catchment_size_percent: num [1:6] 42.14 3.83 4.14 49.26 4.13 ...
#>   ..$ assessment_unit_count : num [1:6] 15 2 1 16 3 15
#>  $ param_summary      : tibble [17 x 4] (S3: tbl_df/tbl/data.frame)
#>   ..$ parameter_group_name  : chr [1:17] "ALGAL GROWTH" "CHLORINE" "HABITAT ALTERATIONS" "HYDROLOGIC ALTERATION" ...
#>   ..$ catchment_size_sq_mi  : num [1:17] 22.8 10.7 25.3 36.5 22.8 ...
#>   ..$ catchment_size_percent: num [1:17] 49.3 23.2 54.7 79 49.3 ...
#>   ..$ assessment_unit_count : num [1:17] 2 1 3 6 9 4 3 8 15 11 ...
#>  $ res_plan_summary   : tibble [1 x 4] (S3: tbl_df/tbl/data.frame)
#>   ..$ summary_type_name     : chr "TMDL"
#>   ..$ catchment_size_sq_mi  : num 26.4
#>   ..$ catchment_size_percent: num 57.1
#>   ..$ assessment_unit_count : num 15
#>  $ vision_plan_summary: tibble [1 x 4] (S3: tbl_df/tbl/data.frame)
#>   ..$ summary_type_name     : chr "TMDL"
#>   ..$ catchment_size_sq_mi  : num 26.4
#>   ..$ catchment_size_percent: num 57.1
#>   ..$ assessment_unit_count : num 15
```

``` r
df <- surveys(organization_id="SDDENR")
str(df)
#> List of 2
#>  $ documents: tibble [0 x 12] (S3: tbl_df/tbl/data.frame)
#>   ..$ organization_identifier: chr(0) 
#>   ..$ organization_name      : chr(0) 
#>   ..$ organization_type_text : chr(0) 
#>   ..$ survey_status_code     : chr(0) 
#>   ..$ year                   : num(0) 
#>   ..$ survey_comment_text    : chr(0) 
#>   ..$ agency_code            : chr(0) 
#>   ..$ document_file_type     : chr(0) 
#>   ..$ document_file_name     : chr(0) 
#>   ..$ document_description   : chr(0) 
#>   ..$ document_comments      : chr(0) 
#>   ..$ document_url           : chr(0) 
#>  $ surveys  : tibble [104 x 19] (S3: tbl_df/tbl/data.frame)
#>   ..$ organization_identifier        : chr [1:104] "SDDENR" "SDDENR" "SDDENR" "SDDENR" ...
#>   ..$ organization_name              : chr [1:104] "South Dakota" "South Dakota" "South Dakota" "South Dakota" ...
#>   ..$ organization_type_text         : chr [1:104] "State" "State" "State" "State" ...
#>   ..$ survey_status_code             : chr [1:104] "Final" "Final" "Final" "Final" ...
#>   ..$ year                           : num [1:104] 2018 2018 2018 2018 2018 ...
#>   ..$ survey_comment_text            : chr [1:104] NA NA NA NA ...
#>   ..$ water_type_group_code          : chr [1:104] "LAKE/RESERVOIR/POND" "LAKE/RESERVOIR/POND" "LAKE/RESERVOIR/POND" "LAKE/RESERVOIR/POND" ...
#>   ..$ sub_population_code            : chr [1:104] "Statewide" "Statewide" "Statewide" "Statewide" ...
#>   ..$ unit_code                      : chr [1:104] "Acres" "Acres" "Acres" "Acres" ...
#>   ..$ size                           : num [1:104] 213265 213265 213265 213265 213265 ...
#>   ..$ site_number                    : chr [1:104] "70" "70" "70" "70" ...
#>   ..$ survey_water_group_comment_text: chr [1:104] NA NA NA NA ...
#>   ..$ stressor                       : chr [1:104] "TEMPERATURE" NA "DISSOLVED OXYGEN" NA ...
#>   ..$ survey_use_code                : chr [1:104] "AQUATIC LIFE - TEMPERATURE" "AQUATIC LIFE - PH" "AQUATIC LIFE - DISSOLVED OXYGEN" "IMMERSION RECREATION WATERS" ...
#>   ..$ survey_category_code           : chr [1:104] "Fully Supporting" "Fully Supporting" "Fully Supporting" "Not Supporting" ...
#>   ..$ statistic                      : chr [1:104] "Condition Estimate" "Condition Estimate" "Condition Estimate" "Condition Estimate" ...
#>   ..$ metric_value                   : num [1:104] 85.9 62.9 95.1 7.24 98.8 37.1 4.9 95.1 37.1 4.9 ...
#>   ..$ confidence_level               : num [1:104] 90 90 90 90 90 90 90 90 90 90 ...
#>   ..$ comment_text                   : chr [1:104] NA NA NA NA ...
```

## File Caching

By default rATTAINS will cache downloaded data to minimize calls to the
EPA webservice. If a function is run with the same arguments, the cached
file will be read instead of downloading from the webservice. A message
will print if the cached file is used. It is probably a good idea to
periodically delete the cached files, espcially when updating packages
or R. The cached file paths and files can be managed using the methods
in the `hoard::hoardr` class. For example:

``` r
x <- surveys(organization_id="SDDENR")
#> reading cached file from: C:/Users/MICHAE~1.SCH/AppData/Local/Cache/R/attains-public/api/surveys/SDDENRsurveys.json

## find the location of the file path
surveys_cache$cache_path_get()
#> [1] "C:\\Users\\MICHAE~1.SCH\\AppData\\Local/Cache/R/attains-public/api/surveys"

## return the file names/path
surveys_cache$list()
#> [1] "C:\\Users\\MICHAE~1.SCH\\AppData\\Local/Cache/R/attains-public/api/surveys/SDDENRsurveys.json"

## delete the files in the cached path
surveys_cache$delete_all()

## or delete specific files
# surveys_cache$delete("filepath.json")
```
