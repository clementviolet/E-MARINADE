#' Native range records
#' 
#' A `tibble` containing information about the native range of taxa listed as non-indigenous species in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `origin_tbl`
#' A `tibble` data frame with 43,584 rows and 5 columns:
#' \describe{
#'   \item{locationID}{An identifier for the set of origine information. Identifier specific to the data set}
#'   \item{taxonID}{An identifier for the set of taxon information. Identifier specific to the data set.}
#'   \item{ECO_CODE_X}{Code of the Ecoregion in a short format. See \link{meow} documentation.}
#'   \item{references}{A related resource that is referenced, cited, or otherwise pointed to by the described resource.}
#'   \item{occurrenceRemarks}{Comments or notes about the native range.}
#' }
#' @source E-MARINADE package
"origin_tbl"