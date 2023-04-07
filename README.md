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

    install.packages('rATTAINS')

Or install the development version from r-universe:

    install.packages('rATTAINS',
                     repos = 'https://mps9506.r-universe.dev')

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

    library(rATTAINS)
    state_summary(organization_id = "TCEQMAIN", 
                  reporting_cycle = "2020",
                  .unnest = FALSE) |>
      tidyr::unnest(reporting_cycles) |> 
      tidyr::unnest(water_types) |> 
      tidyr::unnest(use_attainments)
    #> # A tibble: 31 × 16
    #>    organization_identifer organization_name organization_type_text
    #>    <chr>                  <chr>             <chr>                 
    #>  1 TCEQMAIN               Texas             State                 
    #>  2 TCEQMAIN               Texas             State                 
    #>  3 TCEQMAIN               Texas             State                 
    #>  4 TCEQMAIN               Texas             State                 
    #>  5 TCEQMAIN               Texas             State                 
    #>  6 TCEQMAIN               Texas             State                 
    #>  7 TCEQMAIN               Texas             State                 
    #>  8 TCEQMAIN               Texas             State                 
    #>  9 TCEQMAIN               Texas             State                 
    #> 10 TCEQMAIN               Texas             State                 
    #> # ℹ 21 more rows
    #> # ℹ 13 more variables: reporting_cycle <chr>, water_type_code <chr>,
    #> #   units_code <chr>, use_name <chr>, fully_supporting <dbl>,
    #> #   fully_supporting_count <int>, use_insufficient_information <dbl>,
    #> #   use_insufficient_information_count <int>, not_assessed <dbl>,
    #> #   not_assessed_count <int>, not_supporting <dbl>, not_supporting_count <int>,
    #> #   parameters <list<tibble[,9]>>

Get a summary about assessed uses, parameters and plans in a HUC12:

    df <- huc12_summary(huc = "020700100204",
                  .unnest = FALSE)

    tidyr::unnest(df, summary_by_use)
    #> # A tibble: 5 × 24
    #>   huc12        assessment_unit_count total_catchment_area…¹ total_huc_area_sq_mi
    #>   <chr>                        <int>                  <dbl>                <dbl>
    #> 1 020700100204                    17                   46.1                 46.2
    #> 2 020700100204                    17                   46.1                 46.2
    #> 3 020700100204                    17                   46.1                 46.2
    #> 4 020700100204                    17                   46.1                 46.2
    #> 5 020700100204                    17                   46.1                 46.2
    #> # ℹ abbreviated name: ¹​total_catchment_area_sq_mi
    #> # ℹ 20 more variables: assessed_catchment_area_sq_mi <dbl>,
    #> #   assessed_cathcment_area_percent <dbl>,
    #> #   assessed_good_catchment_area_sq_mi <dbl>,
    #> #   assessed_good_catchment_area_percent <dbl>,
    #> #   assessed_unknown_catchment_area_sq_mi <dbl>,
    #> #   assessed_unknown_catchment_area_percent <dbl>, …

    tidyr::unnest(df, summary_by_parameter_impairments, names_repair = "minimal")
    #> # A tibble: 16 × 25
    #>    huc12       assessment_unit_count total_catchment_area…¹ total_huc_area_sq_mi
    #>    <chr>                       <int>                  <dbl>                <dbl>
    #>  1 0207001002…                    17                   46.1                 46.2
    #>  2 0207001002…                    17                   46.1                 46.2
    #>  3 0207001002…                    17                   46.1                 46.2
    #>  4 0207001002…                    17                   46.1                 46.2
    #>  5 0207001002…                    17                   46.1                 46.2
    #>  6 0207001002…                    17                   46.1                 46.2
    #>  7 0207001002…                    17                   46.1                 46.2
    #>  8 0207001002…                    17                   46.1                 46.2
    #>  9 0207001002…                    17                   46.1                 46.2
    #> 10 0207001002…                    17                   46.1                 46.2
    #> 11 0207001002…                    17                   46.1                 46.2
    #> 12 0207001002…                    17                   46.1                 46.2
    #> 13 0207001002…                    17                   46.1                 46.2
    #> 14 0207001002…                    17                   46.1                 46.2
    #> 15 0207001002…                    17                   46.1                 46.2
    #> 16 0207001002…                    17                   46.1                 46.2
    #> # ℹ abbreviated name: ¹​total_catchment_area_sq_mi
    #> # ℹ 21 more variables: assessed_catchment_area_sq_mi <dbl>,
    #> #   assessed_cathcment_area_percent <dbl>,
    #> #   assessed_good_catchment_area_sq_mi <dbl>,
    #> #   assessed_good_catchment_area_percent <dbl>,
    #> #   assessed_unknown_catchment_area_sq_mi <dbl>,
    #> #   assessed_unknown_catchment_area_percent <dbl>, …

    tidyr::unnest(df, summary_restoration_plans, names_repair = "minimal")
    #> # A tibble: 1 × 25
    #>   huc12        assessment_unit_count total_catchment_area…¹ total_huc_area_sq_mi
    #>   <chr>                        <int>                  <dbl>                <dbl>
    #> 1 020700100204                    17                   46.1                 46.2
    #> # ℹ abbreviated name: ¹​total_catchment_area_sq_mi
    #> # ℹ 21 more variables: assessed_catchment_area_sq_mi <dbl>,
    #> #   assessed_cathcment_area_percent <dbl>,
    #> #   assessed_good_catchment_area_sq_mi <dbl>,
    #> #   assessed_good_catchment_area_percent <dbl>,
    #> #   assessed_unknown_catchment_area_sq_mi <dbl>,
    #> #   assessed_unknown_catchment_area_percent <dbl>, …

Find statistical surveys completed by an organization:

    surveys(organization_id="SDDENR",
            .unnest = FALSE) |> 
      tidyr::unnest(survey_water_groups) |> 
      tidyr::unnest(survey_water_group_use_parameters)
    #> # A tibble: 104 × 21
    #>    organization_identifier organization_name organization_type_text
    #>    <chr>                   <chr>             <chr>                 
    #>  1 SDDENR                  South Dakota      State                 
    #>  2 SDDENR                  South Dakota      State                 
    #>  3 SDDENR                  South Dakota      State                 
    #>  4 SDDENR                  South Dakota      State                 
    #>  5 SDDENR                  South Dakota      State                 
    #>  6 SDDENR                  South Dakota      State                 
    #>  7 SDDENR                  South Dakota      State                 
    #>  8 SDDENR                  South Dakota      State                 
    #>  9 SDDENR                  South Dakota      State                 
    #> 10 SDDENR                  South Dakota      State                 
    #> # ℹ 94 more rows
    #> # ℹ 18 more variables: survey_status_code <chr>, year <int>,
    #> #   survey_comment_text <chr>, documents <list<tibble[,8]>>,
    #> #   water_type_group_code <chr>, sub_population_code <chr>, unit_code <chr>,
    #> #   size <int>, site_number <int>, surey_water_group_comment_text <chr>,
    #> #   stressor <chr>, survey_use_code <chr>, survey_category_code <chr>,
    #> #   statistic <chr>, metric_value <dbl>, margin_of_error <dbl>, …

## Citation

If you use this package in a publication, please cite as:

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
