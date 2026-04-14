#' Launch the ANIS-E Shiny app
#'
#' Starts the interactive **ANIS-E** application bundled with the package.
#' The function loads prebuilt data objects and then runs the Shiny UI/server.
#' 
#' @importFrom dplyr filter
#' @return A \code{shiny.appobj} (the running app). The function is usually called for its side effect of launching the app.
#' @seealso
#' Dataset documentation: [taxonomy], [introduction], [origin], [taxonomy], [taxonomy_identifiers], [meow].
#'
#' @examples
#' \dontrun{
#'   shiny_anise()
#' }
#' @export
shiny_anise <- function(){
  
  suppressMessages({

    sf::sf_use_s2(FALSE)

  })

  data_env <- new.env()
  data_path <- system.file("app/data/shiny_app_data.rda", package = "anise")
  load(data_path, envir = data_env)

  # dm_data <- dm::dm_get_tables(data_env$dm_data) %>%
  #   dm::as_dm()

  meow <- data_env$meow
  meow_prov <- data_env$meow_prov
  meow_rlm <- data_env$meow_rlm
  
  # pathway_tbl <- data_env$pathway
  # taxo_tbl <- data_env$taxonomy
  
  europe_ecoregions <- c(2, 20:27, 29, 30:36, 44)
  
  # Pathway
  
  pathway_wide <- anise::pathway %>%
    dplyr::mutate(values = TRUE) %>%
    tidyr::pivot_wider(
      names_from = pathway,
      values_from = values,
      values_fill = NA
    )
  
  # Provide taxonomical identifiers
  
  taxoIdentifiers <- anise::taxonomy_identifiers %>%
    tidyr::pivot_wider(
      names_from = subject, values_from = identifier
    ) %>%
    dplyr::select(-title, -identifierID) %>%
    dplyr::group_by(taxonID) %>%
    dplyr::summarise(dplyr::across(dplyr::everything(), ~sum(.x, na.rm = TRUE))) %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), ~dplyr::na_if(.x, 0)))
  
  rm(data_env)
  
  # Shiny App per say

  # Shiny ressources
  # There is a bug in the way shiny expose the files in the www folder. 
  # Normally it is automatic
  shiny::addResourcePath("wwww", system.file("www", package = "anise"))

  source(
    system.file("app/main_ui.R", package = "anise"),
    local = TRUE
  )
  
  source(
    system.file("app/main_server.R", package = "anise"),
    local = TRUE
  )

  # Run the application

  shiny::shinyApp(ui = ui, server = server)
  
  
}

