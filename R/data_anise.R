#' Loading all anise datasets
#'
#' @param envir The environment where the datasets will be loaded. Defaults to the global environment.
#'
#' @returns Load the `taxo_tbl`, `taxo_id_tbl`,`inv_tbl`, `origin_tbl` and `meow` datasets.
#' @seealso
#' Dataset documentation: [taxo_tbl], [taxo_id_tbl], [inv_tbl], [origin_tbl], [meow_eco].
#' @examples
#' \dontrun{
#'   data_anise()
#' }
#' @export
data_anise <- function(envir = .GlobalEnv) {
  data(list = c("taxo_tbl", "taxo_id_tbl", "inv_tbl", "origin_tbl", "meow"), 
       package = "anise", 
       envir = envir)
}