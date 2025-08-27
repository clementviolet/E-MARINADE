#' Taxonomic Information data
#' 
#' A `tibble` containing the information on the taxonomy of taxa present in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `inv_tbl`
#' A `tibble` data frame with 4,834 rows and 18 columns:
#' \describe{
#'   \item{SpeciesID}{Identifier linking a species to a valid taxonomic}
#'   \item{AphiaID}{Identifier linking a species to a valid taxonomic}
#'   \item{tsnID}{ITIS identifier.}
#'   \item{boldID}{Barcode of Life identifier.}
#'   \item{eolID}{Encyclopedia of Life identifier.}
#'   \item{fishbaseID}{Fishbase identifier.}
#'   \item{algaebaseID}{Algaebase identifier.}
#'   \item{iucnID}{IUCN Red List identifier.}
#'   \item{ncbiID}{NCBI identifier.}
#'   \item{Kingdom, Phylum, Class, Order, Family, Genus, Species}{Taxonomic rank.}#'
#'   }
#' @source E-MARINADE package
"taxo_tbl"