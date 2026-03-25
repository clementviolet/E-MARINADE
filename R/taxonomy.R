#' Taxonomy Information data
#' 
#' A `tibble` containing the information on the taxonomy of taxa present in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `taxonomy`
#' A `tibble` data frame with  rows and 18 columns:
#' \describe{
#'   \item{taxonID}{An identifier for the set of taxon information. Identifier specific to the data set.}
#'   \item{Kingdom, Phylum, Class, Order, Family, Genus}{The full scientific name in which the taxon is classified}
#'   \item{acceeptedNameUsage}{The full name, with authorship and date information if known, of the currently valid (zoological) or accepted (botanical) taxon.}
#'   }
#' @source ANIS-E package

"taxonomy"