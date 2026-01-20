#' Launch the ANIS-E Shiny app
#'
#' Starts the interactive **ANIS-E** application bundled with the package.
#' The function loads prebuilt data objects and then runs the Shiny UI/server.
#' 
#' @importFrom dplyr filter
#' @return A \code{shiny.appobj} (the running app). The function is usually called for its side effect of launching the app.
#' @seealso
#' Dataset documentation: [taxo_tbl], [inv_tbl], [origin_tbl], [meow_eco].
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

  dm_data <- dm::dm_get_tables(data_env$dm_data) %>%
    dm::as_dm()

  meow_eco <- data_env$meow_eco
  meow_prov <- data_env$meow_prov
  meow_rlm <- data_env$meow_rlm
  
  europe_ecoregions <- c(2, 20:27, 29, 30:36, 44)

  rm(data_env)
  
  # Retrieve species native of EU but NIS in other part of EU
  
  eu_nativeID <- dm_data$origin_tbl %>% 
    dplyr::filter(ECO_CODE_X %in% europe_ecoregions) %>% 
    dplyr::pull(taxonID) %>% 
    unique()
  
  dm_data <- dm_data %>%
    dm::dm_zoom_to(inv_tbl) %>%
    dplyr::mutate(
      EU_native = dplyr::if_else(taxonID %in% eu_nativeID, TRUE, FALSE),
      .after = "country"
    ) %>%
    dm::dm_update_zoomed()
  
  
  # Provide taxonomical identifiers
  
  taxo_identifiers <- dm_data$taxo_identifiers %>%
    tidyr::pivot_wider(
      names_from = subject, values_from = identifier
    ) %>%
    dplyr::select(-title, -identifierID) %>%
    dplyr::group_by(taxonID) %>%
    dplyr::summarise(dplyr::across(dplyr::everything(), ~sum(.x, na.rm = TRUE))) %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), ~dplyr::na_if(.x, 0)))
  
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

