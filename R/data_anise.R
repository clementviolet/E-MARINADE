#' Loading all anise datasets
#'
#' @param envir The environment where the datasets will be loaded. Defaults to the global environment.
#'
#' @returns Load the `taxonomy`, `taxonomy_identifiers`,`introudction`, `origin` and `meow` datasets.
#' @seealso
#' Dataset documentation: [taxonomy], [taxonomy_identifiers], [introduction], [origin], [meow].
#' @examples
#' \dontrun{
#'   data_anise()
#' }
#' @export
data_anise <- function(envir = .GlobalEnv) {
  data(list = c("taxonomy", "taxonomy_identifiers", "introduction", "origin", "meow"), 
       package = "anise", 
       envir = envir)
}