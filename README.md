
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rATTAINS)](https://cran.r-project.org/package=rATTAINS)
[![rATTAINS status
badge](https://mps9506.r-universe.dev/badges/rATTAINS)](https://mps9506.r-universe.dev)
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

-   `state_summary()` provides summary information for assessed uses for
    organizations and by integrated reporting cycle.

-   `huc_12_summary()` provides summary information about impairments,
    actions, and documents for the specified 12-digit HUC (watershed).

-   `actions()` provides a summary of information for particular
    finalized actions (TMDLs and related).

-   `assessments()` provides summary data about the specified assessment
    decisions by waterbody.

-   `plans()` returns a summary of the plans (TMDLs and related) within
    a specified HUC.

-   `domain_values()` returns allowed values in ATTAINS. By default (no
    arguments) the function returns a list of allowed `domain_names`.

-   `assessment_units()` returns a summary of information about the
    specified assessment units.

-   `surveys()` returns results from state statistical survey results in
    ATTAINS.

# Examples:

Get a summary about assessed uses from the Texas Commission on
Environmental Quality:

``` r
library(rATTAINS)
state_summary(organization_id = "TCEQMAIN", 
              reporting_cycle = "2020",
              .unnest = FALSE) |>
  tidyr::unnest(reporting_cycles) |> 
  tidyr::unnest(water_types) |> 
  tidyr::unnest(use_attainments)
#> # A tibble: 31 × 16
#>    organizatio…¹ organ…² organ…³ repor…⁴ water…⁵ units…⁶ use_n…⁷ fully…⁸ fully…⁹
#>    <chr>         <chr>   <chr>   <chr>   <chr>   <chr>   <chr>     <dbl>   <int>
#>  1 TCEQMAIN      Texas   State   2020    ESTUARY Square… Aquati…  1.86e3      57
#>  2 TCEQMAIN      Texas   State   2020    ESTUARY Square… Recrea…  2.26e3      61
#>  3 TCEQMAIN      Texas   State   2020    ESTUARY Square… Oyster…  1.52e3      21
#>  4 TCEQMAIN      Texas   State   2020    ESTUARY Square… Genera…  2.51e3      55
#>  5 TCEQMAIN      Texas   State   2020    ESTUARY Square… Fish C…  2.70e2      11
#>  6 TCEQMAIN      Texas   State   2020    RESERV… Acres   DOMEST…  1.31e6     330
#>  7 TCEQMAIN      Texas   State   2020    RESERV… Acres   Aquati…  1.08e6     309
#>  8 TCEQMAIN      Texas   State   2020    RESERV… Acres   Fish C…  1.59e5      62
#>  9 TCEQMAIN      Texas   State   2020    RESERV… Acres   Genera…  1.14e6     301
#> 10 TCEQMAIN      Texas   State   2020    RESERV… Acres   Recrea…  8.42e5     242
#> # … with 21 more rows, 7 more variables: use_insufficient_information <dbl>,
#> #   use_insufficient_information_count <int>, not_assessed <dbl>,
#> #   not_assessed_count <int>, not_supporting <dbl>, not_supporting_count <int>,
#> #   parameters <list<tibble[,9]>>, and abbreviated variable names
#> #   ¹​organization_identifer, ²​organization_name, ³​organization_type_text,
#> #   ⁴​reporting_cycle, ⁵​water_type_code, ⁶​units_code, ⁷​use_name,
#> #   ⁸​fully_supporting, ⁹​fully_supporting_count
```

Get a summary about assessed uses, parameters and plans in a HUC12:

``` r
df <- huc12_summary(huc = "020700100204",
              .unnest = FALSE)

tidyr::unnest(df, summary_by_use)
#> # A tibble: 5 × 24
#>   huc12  asses…¹ total…² total…³ asses…⁴ asses…⁵ asses…⁶ asses…⁷ asses…⁸ asses…⁹
#>   <chr>    <int>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#> 1 02070…      17    46.1    46.2    59.7     100       0       0       0       0
#> 2 02070…      17    46.1    46.2    59.7     100       0       0       0       0
#> 3 02070…      17    46.1    46.2    59.7     100       0       0       0       0
#> 4 02070…      17    46.1    46.2    59.7     100       0       0       0       0
#> 5 02070…      17    46.1    46.2    59.7     100       0       0       0       0
#> # … with 14 more variables: contain_impaired_waters_catchment_area_sq_mi <dbl>,
#> #   contain_impaired_catchment_area_percent <dbl>,
#> #   contain_restoration_catchment_area_sq_mi <dbl>,
#> #   contain_restoration_catchment_area_percent <dbl>,
#> #   assessment_units <list<tibble[,1]>>,
#> #   summary_by_IR_category <list<tibble[,4]>>,
#> #   summary_by_overall_status <list<tibble[,4]>>, …

tidyr::unnest(df, summary_by_parameter_impairments, names_repair = "minimal")
#> # A tibble: 16 × 25
#>    huc12 asses…¹ total…² total…³ asses…⁴ asses…⁵ asses…⁶ asses…⁷ asses…⁸ asses…⁹
#>    <chr>   <int>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#>  1 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  2 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  3 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  4 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  5 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  6 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  7 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  8 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#>  9 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 10 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 11 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 12 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 13 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 14 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 15 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> 16 0207…      17    46.1    46.2    59.7     100       0       0       0       0
#> # … with 15 more variables: contain_impaired_waters_catchment_area_sq_mi <dbl>,
#> #   contain_impaired_catchment_area_percent <dbl>,
#> #   contain_restoration_catchment_area_sq_mi <dbl>,
#> #   contain_restoration_catchment_area_percent <dbl>,
#> #   assessment_units <list<tibble[,1]>>,
#> #   summary_by_IR_category <list<tibble[,4]>>,
#> #   summary_by_overall_status <list<tibble[,4]>>, …

tidyr::unnest(df, summary_restoration_plans, names_repair = "minimal")
#> # A tibble: 1 × 25
#>   huc12  asses…¹ total…² total…³ asses…⁴ asses…⁵ asses…⁶ asses…⁷ asses…⁸ asses…⁹
#>   <chr>    <int>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#> 1 02070…      17    46.1    46.2    59.7     100       0       0       0       0
#> # … with 15 more variables: contain_impaired_waters_catchment_area_sq_mi <dbl>,
#> #   contain_impaired_catchment_area_percent <dbl>,
#> #   contain_restoration_catchment_area_sq_mi <dbl>,
#> #   contain_restoration_catchment_area_percent <dbl>,
#> #   assessment_units <list<tibble[,1]>>,
#> #   summary_by_IR_category <list<tibble[,4]>>,
#> #   summary_by_overall_status <list<tibble[,4]>>, …
```

Find statistical surveys completed by an organization:

``` r
surveys(organization_id="SDDENR",
        .unnest = FALSE) |> 
  tidyr::unnest(survey_water_groups) |> 
  tidyr::unnest(survey_water_group_use_parameters)
#> # A tibble: 104 × 21
#>    organ…¹ organ…² organ…³ surve…⁴  year surve…⁵ docum…⁶ water…⁷ sub_p…⁸ unit_…⁹
#>    <chr>   <chr>   <chr>   <chr>   <int> <chr>   <list<> <chr>   <chr>   <chr>  
#>  1 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  2 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  3 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  4 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  5 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  6 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  7 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  8 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#>  9 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#> 10 SDDENR  South … State   Final    2018 <NA>    [0 × 8] LAKE/R… Statew… Acres  
#> # … with 94 more rows, 11 more variables: size <int>, site_number <int>,
#> #   surey_water_group_comment_text <chr>, stressor <chr>,
#> #   survey_use_code <chr>, survey_category_code <chr>, statistic <chr>,
#> #   metric_value <dbl>, margin_of_error <dbl>, confidence_level <dbl>,
#> #   comment_text <chr>, and abbreviated variable names
#> #   ¹​organization_identifier, ²​organization_name, ³​organization_type_text,
#> #   ⁴​survey_status_code, ⁵​survey_comment_text, ⁶​documents, …
```

## Citation

If you use this package in a publication, please cite as:

``` r
citation("rATTAINS")
#> 
#> To cite rATTAINS in publications use:
#> 
#>   Schramm, Michael (2021).  rATTAINS: Access EPA 'ATTAINS' Data.  R
#>   package version 1.0.0. doi:10.5281/zenodo.5469911
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
#>     note = {R package version 1.0.0},
#>   }
```
