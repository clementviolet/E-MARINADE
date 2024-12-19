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
        tags$h2("Mapping the origin of European marine NIS")
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
        leafletOutput("OriginMap", height = "600px") %>% withSpinner(color = "blue")
      )
    ),
    fluidRow(
      column(
        width = 12,
        tags$h2("Upset plot of the origin of European marine NIS"),
        tags$p("Intersection break down by taxonomic groups"),
      )
    ),
    fluidRow(
      column(
        width = 12,
        selectizeInput( 
          "select_taxo_setup", 
          "Select taxonomical categories to break down the intersection plot:", 
          list(
            "Teleostei","Gastropoda", "Annelida", "Decapoda", "Rhodophyta",
            "Bivalvia", "Copepoda", "Cnidaria", "Bryozoa", "Ascidiacea", 
            "Foraminifera", "Chlorophyta", "Amphipoda", "Phaeophyceae",
            "Isopoda", "Thecostraca", "Chondrostei", 
            "Elasmobranchii", "Mammalia"
          ),
          selected = c(
            "Annelida", "Bivalvia", "Copepoda", "Decapoda",
            "Gastropoda", "Rhodophyta", "Teleostei"
          ),
          multiple = TRUE 
        )
      )
    ), 
    fluidRow(
      column(
        width = 12,
        plotOutput("OriginUpSet", height = "800px") %>% withSpinner(color = "blue")
      )
    )
  )
}