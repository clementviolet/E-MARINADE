cumsum_nis_all_eu <- function(){
  cumsum_nis <- dm_data[['inv_tbl']] %>%
    filter(!is.na(Year), Year >= 1492) %>%
    arrange(SpeciesID, Year) %>%
    distinct(SpeciesID, .keep_all = TRUE) %>%
    count(Year) %>%
    complete(Year = min(Year):max(Year), fill = list(count = 0)) %>%
    mutate(n = replace_na(n, 0), cumsum = cumsum(n))
  
  
  p <- ggplot() +
    geom_point(
      data = cumsum_nis %>% filter(n > 0),
      aes(x = Year, y = cumsum)
    ) +
    labs(y = "Cumulative number of NIS") +
    coord_cartesian(expand = FALSE, clip = "off") +
    theme_minimal()
  
  return(p)
}

cumsum_nis_eco <- function(){
  
  cumsum_nis <- dm_data[['inv_tbl']] %>%
    filter(!is.na(Year), Year >= 1492) %>%
    distinct(SpeciesID, Year, Ecoregion_Code, .keep_all = TRUE) %>%
    count(Ecoregion_Code, Year) %>%
    group_by(Ecoregion_Code) %>%
    complete(Year = min(Year):max(Year), fill = list(count = 0)) %>%
    arrange(Ecoregion_Code, Year) %>%
    mutate(
      count = replace_na(n, 0),
      cumsum = cumsum(count)
    ) %>%
    ungroup() %>%
    # Add Ecoregion label to the table
    left_join(
      select(
        distinct(st_drop_geometry(meow_eco), ECO_CODE_X, .keep_all = TRUE),
        ECO_CODE_X, ECOREGION
        ), 
      by = c("Ecoregion_Code" = "ECO_CODE_X")
    )
  
  p <- ggplot(
    cumsum_nis,
    aes(x = Year, y = cumsum, color = ECOREGION)
    ) +
    geom_line() +
    scale_color_discrete(name = "Ecoregion") +
    labs(y = "Cumulative number of NIS") +
    theme_minimal()
  
  return(p)
  
}