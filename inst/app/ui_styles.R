globalStyles <- function() {
  shiny::tagList(
    # Include custom styles
    shiny::includeCSS("inst/www/style.css"),
    
    # Hide Shiny warnings
    shiny::tags$style(
      type = "text/css",
      "
      .shiny-output-error { visibility: hidden; }
      .shiny-output-error:before { visibility: hidden; }
      div.info.legend.leaflet-control br {clear: both;}
      "
    )
  )
}
