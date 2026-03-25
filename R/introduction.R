#' Introduction Event data
#' 
#' A `tibble` containing the introduction events present in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `introduction`
#' A `tibble` data frame with 4,470 rows and 11 columns:
#' \describe{
#'   \item{occurenceID}{An identifier for the occurrence. Identifier specific to the data set}
#'   \item{taxonID}{An identifier for the set of taxon information. Identifier specific to the data set.}
#'   \item{year}{The four-digit year in which the introduction event occurred, according to the Common Era Calendar.}
#'   \item{country}{Country where the invasion event occurred}
#'   \item{establishmentMeans}{Statement about whether an organism has been introduced to a given place and time through the direct or indirect activity of modern humans.}
#'   \item{occurrenceRemarks}{Comments or notes about the occurrence.}
#'   \item{degreeOfEstablishment}{The degree to which a dwc:Organism survives, reproduces, and expands its range at the given place and time.}
#'   \item{pathway}{The process by which a dwc:Organism came to be in a given place at a given time.}
#'   \item{ECO_CODE_X}{Code of the Ecoregion (sensus Marine Ecoregion of the World according to \href{https://doi.org/10.1641/B570707}{Spalding et al. 2007}) of the corresponding MSFD sub-region.}
#'   \item{associatedReferences}{A list of publication, bibliographic reference, global unique identifier, URI)of literature associated with the occurrence.}
#'   \item{references}{A related resource that is referenced, cited, or otherwise pointed to by the described resource.}
#' }
#' @source ANIS-E package

"introduction"