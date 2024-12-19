upset_plot <- function(group_of_interest){
  
  # Taxonomic group to choose from
  
  groups <- tribble(
    ~taxo_group, ~color, ~hex,
    "Teleostei", "olivegreen", "#2b3d26",
    "Gastropoda", "reddishorange", "#e25822",
    "Annelida", "yellowishbrown", "#654522",
    "Decapoda", "yellowgreen", "#8db600",
    "Rhodophyta", "reddishbrown", "#882d17",
    "Bivalvia", "greenishyellow", "#dcd300",
    "Copepoda", "purplishred", "#b3446c",
    "Cnidaria", "orangeyellow", "#f6a600",
    "Bryozoa", "violet",	"#604e97",
    "Ascidiacea", "yellowishpink", "#f99379",
    "Foraminifera", "blue", "#0067a5",
    "Chlorophyta", "purplishpink", "#e68fac",
    "Amphipoda", "green",	"#008856",
    "Phaeophyceae", "gray",	"#848482",
    "Isopoda", "buff",	"#c2b280",
    "Thecostraca", "red",	"#be0032",
    "Chondrostei", "lightblue", "#a1caf1",
    "Elasmobranchii", "orange", "#f38400",
    "Mammalia", "purple",	"#875692",
    "Other groups", "black", "#000000"
  ) %>%
    mutate(
      taxo_group = factor(taxo_group, levels = taxo_group),
      hex = factor(hex, levels = hex)
    )
  
  # Needed for upset plot
  realm_name <- c(
    "Temperate Southern Africa",
    "Temperate Northern Pacific",
    "Tropical Atlantic",
    "Southern Ocean",
    "Western Indo-Pacific",
    "Temperate South America",
    "Central Indo-Pacific",
    "Temperate Northern Atlantic",
    "Arctic",
    "Temperate Australasia",
    "Tropical Eastern Pacific",
    "Eastern Indo-Pacific"
  )
  
  # Preparing data
  
  prep_data <- dm_data[['origin_tbl']] %>%
    left_join(dm_data[['taxo_tbl']], by = "SpeciesID") %>%
    select(Kingdom:Species, ECO_CODE_X) %>%
    left_join(
      distinct(st_drop_geometry(meow_eco), ECO_CODE_X, .keep_all = TRUE),
      by = "ECO_CODE_X"
    )
  
  # Presence/Absence dataframe where each row is a sp. and column a Realm.
  
  origin_species <- prep_data %>%
    distinct(Species, REALM, .keep_all = TRUE) %>%
    rowid_to_column() %>%
    mutate(values = 1) %>%
    pivot_wider(
      names_from = REALM, 
      values_from = values, 
      values_fill = 0
    ) %>%
    select(-rowid, Kingdom:Species, -c(ECO_CODE_X:Lat_Zone)) %>%
    group_by(Kingdom, Phylum, Class, Order, Family, Genus, Species) %>%
    summarise(across(everything(), ~sum(.x)), .groups = "drop")
  
  # Add the taxonomic levels wanted
  
  taxo_species <- origin_species %>%
    pivot_longer(Kingdom:Genus, names_to = "taxo_level", values_to = "taxo_group")
  
  taxo_level_interest <- taxo_species %>%
    filter(taxo_group %in% group_of_interest)
  
  taxo_level_not_interest <- taxo_species %>%
    filter(!taxo_group %in% group_of_interest) %>%
    mutate(taxo_group = "Other groups")
  
  taxo_species <- taxo_level_interest %>%
    rbind(taxo_level_not_interest) %>%
    distinct(
      Species,
      .keep_all = TRUE
    ) %>%
    select(Species, taxo_group)
  
  
  origin_species <- origin_species %>%
    left_join(taxo_species, by = "Species") %>%
    left_join(groups, by = c("taxo_group")) %>%
    mutate(taxo_group = factor(taxo_group, levels = levels(groups$taxo_group)))
  
  # Plot part
  
  # Plot
  oldw <- getOption("warn") # SuppressWarnings does not work here, so silencing warnings at a global level
  
  options(warn = -1)
  
  p <- upset(
    origin_species, realm_name, name = "", min_size = 10,
    annotations = list(
      'Intersection composition'=(
        ggplot(mapping=aes(fill=taxo_group))
        + geom_bar(stat='count', position='fill')
        + scale_y_continuous(labels=scales::percent_format())
        + scale_fill_manual(
            values = levels(origin_species$hex),
            breaks = levels(origin_species$taxo_group),
            guide = "legend", name = ""
        )
        + ylab("Intersection size composition")
        + theme(legend.position = "top") +
          guides(
            color = guide_colorbar(
              title.hjust = .5,
              barwidth = unit(1, "lines"),
              barheight = unit(.5, "lines")
              )
            )
      )
    ),
    matrix=(
      intersection_matrix(
        geom=geom_point(
          size=2.2
        )) + theme_dark()),
    base_annotations = list(
      'Intersection size'=(
        intersection_size(text = list(size = 5))
        + theme(panel.grid.minor = element_blank())
        + ylab('# Observations in intersection')
      )
    ),
    themes = upset_default_themes(
      text = element_text(size = 16),
      title = element_text(size = 18)
    ),
    width_ratio=0.3, height_ratio = 0.8
)
  
  options(warn = oldw) # Reset warning to defaults settings
  
  return(p)
}
