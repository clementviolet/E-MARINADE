#' Taxonomic Identifiers Information data
#' 
#' A `tibble` containing the information on the taxonomic identifiers of taxa present in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `taxonomy_identifiers`
#' A `tibble` data frame with 3,511 rows and 5 columns:
#' \describe{
#'   \item{identifierID}{An identifier for the set of taxon information. Identifier specific to the data set.}
#'   \item{taxonID}{An identifier for the set of taxon information. Identifier specific to the data set.}
#'   \item{title}{An optional display label for the URL that the publisher may prefer be displayed with the identifier or link.}
#'   \item{identifier}{Other known identifier used for the same taxon. Can be a URL pointing to a webpage, an xml or rdf document, a DOI, UUID or any other identifer.}
#'   \item{subject}{Keywords qualifying the identifier}
#'   }
#' @source E-MARINADE package
"taxo_id_tbl"