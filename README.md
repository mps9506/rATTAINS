
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rATTAINS)](https://cran.r-project.org/package=rATTAINS)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/mps9506/rATTAINS/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/rATTAINS/actions)
[![codecov](https://codecov.io/gh/mps9506/rATTAINS/branch/master/graph/badge.svg?token=J45QIKWA8E)](https://codecov.io/gh/mps9506/rATTAINS)
<!-- badges: end -->

rATTAINS provides functions for downloading tidy data from the United
States (U.S.) Environmental Protection Agency (EPA)
[ATTAINS](https://www.epa.gov/waterdata/attains) webservice. ATTAINS is
the online system used to track and report Clean Water Act assessments
and Total Maximum Daily Loads (TMDLs) in U.S. surface waters. rATTAINS
facilitates access to the [public information
webservice](https://www.epa.gov/waterdata/get-data-access-public-attains-data)
made available through the EPA.

rATTAINS is on CRAN:

``` r
install.packages("rATTAINS")
```

Or install the development version from Github:

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

  - `state_summary()` provides summary information for assessed uses for
    organizations and by integrated reporting cycle.

  - `huc_2_summary()` provides summary information about impairments,
    actions, and documents for the specified 12-digit HUC (watershed).

  - `actions()` provides a summary of information for particular
    finalized actions (TMDLs and related).

  - `assessments()` provides summary data about the specified assessment
    decisions by waterbody.

  - `plans()` returns a summary of the plans (TMDLs and related) within
    a specified HUC.

  - `domain_values()` returns allowed values in ATTAINS. By default (no
    arguments) the function returns a list of allowed `domain_names`.

  - `assessment_units()` returns a summary of information about the
    specified assessment units.

  - `surveys()` returns results from state statistical survey results in
    ATTAINS.

# Examples:

Get a summary about assessed uses from the Texas Commission on
Environmental Quality:

``` r
library(rATTAINS)
state_summary(organization_id = "TCEQMAIN", reporting_cycle = "2020") %>%
  .[1,] %>% str()
#> tibble [1 × 13] (S3: tbl_df/tbl/data.frame)
#>  $ organization_identifier: chr "TCEQMAIN"
#>  $ organization_name      : chr "Texas"
#>  $ organization_type_text : chr "State"
#>  $ reporting_cycle        : chr "2020"
#>  $ combined_cycles        : chr NA
#>  $ water_type_code        : chr "ESTUARY"
#>  $ units_code             : chr "Square Miles"
#>  $ use_name               : chr "Aquatic Life Use"
#>  $ fully_supporting       : chr "1861.320000"
#>  $ fully_supporting_count : chr "57"
#>  $ not_assessed           : chr "46.190000"
#>  $ not_assessed_count     : chr "6"
#>  $ parameters             :List of 1
#>   ..$ : tibble [7 × 7] (S3: tbl_df/tbl/data.frame)
#>   .. ..$ parameter_group               : chr [1:7] "TOXIC INORGANICS" "ORGANIC ENRICHMENT/OXYGEN DEPLETION" "PESTICIDES" "TOXIC ORGANICS" ...
#>   .. ..$ cause                         : chr [1:7] NA "616.850000" NA NA ...
#>   .. ..$ cause_count                   : chr [1:7] NA "5" NA NA ...
#>   .. ..$ meeting_criteria              : num [1:7] NA 1901.8 NA NA 96.9 ...
#>   .. ..$ meeting_criteria_count        : num [1:7] NA 62 NA NA 8 NA 8
#>   .. ..$ insufficent_information       : num [1:7] 2.76 NA 3.2 1.07 344.3 ...
#>   .. ..$ insufficient_information_count: num [1:7] 1 NA 3 2 6 7 5
```

Get a summary about assessed uses, parameters and plans in a HUC12:

``` r
huc12_summary(huc = "020700100204")
#> $huc_summary
#> # A tibble: 1 × 14
#>   huc12        assessment_unit… total_catchment… total_huc_area_… assessed_catchm…
#>   <chr>                   <dbl>            <dbl>            <dbl>            <dbl>
#> 1 020700100204               20             46.2             46.2             44.1
#> # … with 9 more variables: assessed_catchment_area_percent <dbl>,
#> #   assessed_good_catchment_area_sq_mi <dbl>,
#> #   assessed_good_catchment_area_percent <dbl>,
#> #   assessed_unknown_catchment_area_sq_mi <dbl>,
#> #   assessed_unknown_catchment_area_percent <dbl>,
#> #   contain_impaired_waters_catchment_area_sq_mi <dbl>,
#> #   contain_impaired_waters_catchment_area_percent <dbl>, …
#> 
#> $au_summary
#> # A tibble: 20 × 1
#>    assessment_unit_id                      
#>    <chr>                                   
#>  1 MD-ANATF-02140205                       
#>  2 MD-02140205-Northwest_Branch            
#>  3 MD-02140205                             
#>  4 DCTFD01R_00                             
#>  5 MD-ANATF                                
#>  6 DCTFS01R_00                             
#>  7 DCTNA01R_00                             
#>  8 DCTTX27R_00                             
#>  9 DCTFC01R_00                             
#> 10 MD-02140205-Mainstem                    
#> 11 MD-02140205-Northeast_Northwest_Branches
#> 12 MD-02140205-Mainstem2                   
#> 13 DCTWB00R_02                             
#> 14 DCTWB00R_01                             
#> 15 DCANA00E_02                             
#> 16 DCTHR01R_00                             
#> 17 DCTPB01R_00                             
#> 18 DCTDU01R_00                             
#> 19 DCANA00E_01                             
#> 20 DCAKL00L_00                             
#> 
#> $ir_summary
#> # A tibble: 3 × 4
#>   epa_ir_category_name catchment_size_sq_mi catchment_size_pe… assessment_unit_…
#>   <chr>                               <dbl>              <dbl>             <dbl>
#> 1 1                                    1.77               3.83                 2
#> 2 4A                                  25.3               54.8                 11
#> 3 5                                   37.9               81.9                  7
#> 
#> $use_summary
#> # A tibble: 6 × 5
#>   use_group_name      use_attainment           catchment_size_… catchment_size_…
#>   <chr>               <chr>                               <dbl>            <dbl>
#> 1 ECOLOGICAL_USE      Not Supporting                      19.5             42.1 
#> 2 FISHCONSUMPTION_USE Fully Supporting                     1.77             3.83
#> 3 FISHCONSUMPTION_USE Insufficient Information             1.91             4.14
#> 4 FISHCONSUMPTION_USE Not Supporting                      22.8             49.3 
#> 5 OTHER_USE           Fully Supporting                     1.91             4.13
#> 6 RECREATION_USE      Not Supporting                      24.5             53.0 
#> # … with 1 more variable: assessment_unit_count <dbl>
#> 
#> $param_summary
#> # A tibble: 17 × 4
#>    parameter_group_name    catchment_size_s… catchment_size_p… assessment_unit_…
#>    <chr>                               <dbl>             <dbl>             <dbl>
#>  1 ALGAL GROWTH                        22.8              49.3                  2
#>  2 CHLORINE                            10.7              23.2                  1
#>  3 HABITAT ALTERATIONS                 25.3              54.7                  3
#>  4 HYDROLOGIC ALTERATION               36.5              79.0                  6
#>  5 METALS (OTHER THAN MER…             22.8              49.3                  9
#>  6 NUTRIENTS                           42.4              91.7                  4
#>  7 OIL AND GREASE                      22.8              49.3                  3
#>  8 ORGANIC ENRICHMENT/OXY…             42.4              91.7                  8
#>  9 PATHOGENS                           44.1              95.4                 15
#> 10 PESTICIDES                          26.4              57.1                 11
#> 11 PH/ACIDITY/CAUSTIC CON…              1.72              3.71                 1
#> 12 POLYCHLORINATED BIPHEN…             26.4              57.1                 12
#> 13 SALINITY/TOTAL DISSOLV…             19.5              42.1                  1
#> 14 SEDIMENT                             3.88              8.39                 1
#> 15 TOXIC ORGANICS                      22.8              49.3                  8
#> 16 TRASH                               42.4              91.7                  4
#> 17 TURBIDITY                           44.1              95.4                 15
#> 
#> $res_plan_summary
#> # A tibble: 1 × 4
#>   summary_type_name catchment_size_sq_mi catchment_size_percent assessment_unit…
#>   <chr>                            <dbl>                  <dbl>            <dbl>
#> 1 TMDL                              26.4                   57.1               15
#> 
#> $vision_plan_summary
#> # A tibble: 1 × 4
#>   summary_type_name catchment_size_sq_mi catchment_size_percent assessment_unit…
#>   <chr>                            <dbl>                  <dbl>            <dbl>
#> 1 TMDL                              26.4                   57.1               15
```

Find statistical surveys completed by an organization:

``` r
df <- surveys(organization_id="SDDENR")
str(df)
#> List of 2
#>  $ documents: tibble [0 × 12] (S3: tbl_df/tbl/data.frame)
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
#>  $ surveys  : tibble [104 × 19] (S3: tbl_df/tbl/data.frame)
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
periodically delete the cached files, especially when updating packages
or R. The cached file paths and files can be managed using the methods
in the `hoard::hoardr` class. For example:

``` r
x <- surveys(organization_id="SDDENR")
#> reading cached file from: ~/Library/Caches/R/attains-public/api/surveys/SDDENRsurveys.json

## find the location of the file path
surveys_cache$cache_path_get()
#> [1] "~/Library/Caches/R/attains-public/api/surveys"

## return the file names/path
surveys_cache$list()
#> [1] "/Users/runner/Library/Caches/R/attains-public/api/surveys/SDDENRsurveys.json"

## delete the files in the cached path
surveys_cache$delete_all()

## or delete specific files
# surveys_cache$delete("filepath.json")
```
