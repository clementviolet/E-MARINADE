globalStyles <- function() {
  tagList(
    # Include custom styles
    includeCSS("../www/style.css"),
    
    # Hide Shiny warnings
    tags$style(
      type = "text/css",
      "
      .shiny-output-error { visibility: hidden; }
      .shiny-output-error:before { visibility: hidden; }
      div.info.legend.leaflet-control br {clear: both;}
      "
      # Last line fix issue with the NA placement legend in the
      # European Introduction Map page
    )
  )
}
