OrgMapUI <- function(){
  
  tabItem(
    tabName = "org_map",
    fluidRow(
      column(
        width = 12,
        tags$h1("Origin of European NIS")
      )
    ),
    fluidRow(
      column(
        width = 12,
        tags$p("Choosing Marine Ecoregion of the World aggregation level")
      )
    ),
    fluidRow(
      column(
        width = 12,
        radioButtons(
          inputId = "meow_select",
          label = "",
          choices = list(
            "Realm" = "RLM",
            "Province" = "PROV",
            "Ecoregion" = "ECO"
          ),
          selected = "PROV"
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        leafletOutput("OriginMap", height = "600px")
      )
    )
  )
}