#' Introduction Pathway data 
#'
#' A `tibble` containing the information on the introduction pathway of non-indigenous taxa present in the Shiny app. This dataset can be useful when working with the database programmatically.
#'
#' @format ## `pathway`
#' A `tibble` data frame with 9,038 rows and 3 columns:
#' \describe{
#'   \item{pathwayID}{An identifier for the set of pathway information. Identifier specific to the data set.}
#'   \item{occurenceID}{An identifier for the occurrence. Identifier specific to the data set}
#'   \item{pathway}{The process by which a dwc:Organism came to be in a given place at a given time.}
#' }
#' @source ANIS-E R package

"pathway"