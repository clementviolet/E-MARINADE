#' Native range records
#' 
#' A `tibble` containing information about the native range of taxa listed as non-indigenous species in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `inv_tbl`
#' A `tibble` data frame with 4,834 rows and 18 columns:
#' \describe{
#'   \item{OriginID}{Identifier linking the species to its native geographic region.}
#'   \item{SpeciesID}{Identifier linking a species to a valid taxonomic name.}
#'   \item{ECO_CODE_X}{Code of the Ecoregion in a short format. See \link{meow} documentation.}
#'   \item{Source}{Reference indicating that the species is a cryptogenic or non-indigenous species in the area.}
#'   \item{Comment}{Comment about the native geographic region of a species}
#' }
#' @source E-MARINADE package
"origin_tbl"