
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rATTAINS)](https://cran.r-project.org/package=rATTAINS)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/mps9506/rATTAINS/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/rATTAINS/actions)
[![codecov](https://codecov.io/gh/mps9506/rATTAINS/branch/main/graph/badge.svg?token=J45QIKWA8E)](https://app.codecov.io/gh/mps9506/rATTAINS)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5469911.svg)](https://doi.org/10.5281/zenodo.5469911)

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
install.packages('rATTAINS')
```

Or install the development version from r-universe:

``` r
install.packages('rATTAINS',
                 repos = 'https://mps9506.r-universe.dev')
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

- `huc_12_summary()` provides summary information about impairments,
  actions, and documents for the specified 12-digit HUC (watershed).

- `actions()` provides a summary of information for particular finalized
  actions (TMDLs and related).

- `assessments()` provides summary data about the specified assessment
  decisions by waterbody.

- `plans()` returns a summary of the plans (TMDLs and related) within a
  specified HUC.

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
#>   huc12  asses…¹ total…² total…³ asses…⁴ asses…⁵ asses…⁶ asses…⁷ asses…⁸ asses…⁹
#>   <chr>    <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#> 1 02070…      17    46.2    46.2    44.1    95.4       0       0       0       0
#> # … with 4 more variables: contain_impaired_waters_catchment_area_sq_mi <dbl>,
#> #   contain_impaired_waters_catchment_area_percent <dbl>,
#> #   contain_restoration_catchment_area_sq_mi <dbl>,
#> #   contain_restoration_catchment_area_percent <dbl>, and abbreviated variable
#> #   names ¹​assessment_unit_count, ²​total_catchment_area_sq_mi,
#> #   ³​total_huc_area_sq_mi, ⁴​assessed_catchment_area_sq_mi,
#> #   ⁵​assessed_catchment_area_percent, ⁶​assessed_good_catchment_area_sq_mi, …
#> 
#> $au_summary
#> # A tibble: 17 × 1
#>    assessment_unit_id          
#>    <chr>                       
#>  1 MD-02140205-Northwest_Branch
#>  2 MD-02140205                 
#>  3 DCTFD01R_00                 
#>  4 MD-ANATF                    
#>  5 DCTFS01R_00                 
#>  6 DCTNA01R_00                 
#>  7 DCTTX27R_00                 
#>  8 DCTFC01R_00                 
#>  9 MD-02140205-Mainstem        
#> 10 DCTWB00R_02                 
#> 11 DCTWB00R_01                 
#> 12 DCANA00E_02                 
#> 13 DCTHR01R_00                 
#> 14 DCTPB01R_00                 
#> 15 DCTDU01R_00                 
#> 16 DCANA00E_01                 
#> 17 DCAKL00L_00                 
#> 
#> $ir_summary
#> # A tibble: 2 × 4
#>   epa_ir_category_name catchment_size_sq_mi catchment_size_percent assessment_…¹
#>   <chr>                               <dbl>                  <dbl>         <dbl>
#> 1 4A                                   25.2                   54.5            10
#> 2 5                                    37.9                   81.9             7
#> # … with abbreviated variable name ¹​assessment_unit_count
#> 
#> $use_summary
#> # A tibble: 5 × 5
#>   use_group_name      use_attainment           catchment_size_…¹ catch…² asses…³
#>   <chr>               <chr>                                <dbl>   <dbl>   <dbl>
#> 1 ECOLOGICAL_USE      Not Supporting                       22.8    49.3       13
#> 2 FISHCONSUMPTION_USE Insufficient Information             24.5    53.0        1
#> 3 FISHCONSUMPTION_USE Not Supporting                       24.5    53.0       12
#> 4 OTHER_USE           Fully Supporting                      1.92    4.15       3
#> 5 RECREATION_USE      Not Supporting                       24.5    53.0       13
#> # … with abbreviated variable names ¹​catchment_size_sq_mi,
#> #   ²​catchment_size_percent, ³​assessment_unit_count
#> 
#> $param_summary
#> # A tibble: 16 × 4
#>    parameter_group_name                catchment_size_sq_mi catchment_…¹ asses…²
#>    <chr>                                              <dbl>        <dbl>   <dbl>
#>  1 ALGAL GROWTH                                       22.8         49.3        2
#>  2 CHLORINE                                           10.7         23.2        1
#>  3 HABITAT ALTERATIONS                                 5.80        12.5        2
#>  4 HYDROLOGIC ALTERATION                              17.0         36.8        5
#>  5 METALS (OTHER THAN MERCURY)                        22.8         49.3        9
#>  6 NUTRIENTS                                          22.8         49.3        2
#>  7 OIL AND GREASE                                     22.8         49.3        3
#>  8 ORGANIC ENRICHMENT/OXYGEN DEPLETION                22.8         49.3        6
#>  9 PATHOGENS                                          24.5         53.0       13
#> 10 PESTICIDES                                         24.5         53.0        9
#> 11 PH/ACIDITY/CAUSTIC CONDITIONS                       1.72         3.71       1
#> 12 POLYCHLORINATED BIPHENYLS (PCBS)                   24.5         53.0       10
#> 13 SEDIMENT                                            3.88         8.39       1
#> 14 TOXIC ORGANICS                                     22.8         49.3        8
#> 15 TRASH                                              22.8         49.3        2
#> 16 TURBIDITY                                          24.5         53.0       13
#> # … with abbreviated variable names ¹​catchment_size_percent,
#> #   ²​assessment_unit_count
#> 
#> $res_plan_summary
#> # A tibble: 1 × 4
#>   summary_type_name catchment_size_sq_mi catchment_size_percent assessment_uni…¹
#>   <chr>                            <dbl>                  <dbl>            <dbl>
#> 1 TMDL                              24.5                   53.0               13
#> # … with abbreviated variable name ¹​assessment_unit_count
#> 
#> $vision_plan_summary
#> # A tibble: 1 × 4
#>   summary_type_name catchment_size_sq_mi catchment_size_percent assessment_uni…¹
#>   <chr>                            <dbl>                  <dbl>            <dbl>
#> 1 TMDL                              24.5                   53.0               13
#> # … with abbreviated variable name ¹​assessment_unit_count
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

## Citation

If you use this package in a publication, please cite as:

``` r
citation("rATTAINS")
#> 
#> To cite rATTAINS in publications use:
#> 
#>   Schramm, Michael (2021).  rATTAINS: Access EPA 'ATTAINS' Data.  R
#>   package version 0.1.3. doi:10.5281/zenodo.3635017
#>   https://CRAN.R-project.org/package=rATTAINS
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {{rATTAINS}: Access EPA 'ATTAINS' Data},
#>     author = {Michael Schramm},
#>     year = {2021},
#>     url = {https://CRAN.R-project.org/package=rATTAINS},
#>     doi = {10.5281/zenodo.5469911},
#>     note = {R package version 0.1.3},
#>   }
```
