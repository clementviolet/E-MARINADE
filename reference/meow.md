# Marine Ecoregion Of the World

A `sf object` containing the Marine Ecoregions of the World described by
@Spalding_2007, a nested system of realms, provinces, and ecoregions
This dataset can be useful when working with the database
programmatically.

## Usage

``` r
meow
```

## Format

### `meow`

A `tibble` data frame with 232 rows and 9 columns:

- ECO_CODE:

  Code of the Province.

- ECOREGION:

  Ecoregion name.

- PROV_CODE:

  Code of the Province.

- PROVINCE:

  Province name.

- RLM_CODE:

  Code of the Realm.

- REALM:

  Realm Name.

- ECO_CODE_X:

  Code of the Ecoregion in a short format.

- Lat_Zone:

  Latitudinal zone where the Ecoregion is located.

- WKT:

  Well-known text describing the Ecoregion polygon. The CRS is WGS84.

## Source

Spalding, Mark D., Helen E. Fox, Gerald R. Allen, Nick Davidson, Zach A.
Ferdaña, Max Finlayson, Benjamin S. Halpern, Miguel A. Jorge, Al
Lombana, Sara A. Lourie, Kirsten D. Martin, Edmund McManus, Jennifer
Molnar, Cheri A. Recchia, and James Robertson. 2007. “Marine Ecoregions
of the World: A Bioregionalization of Coastal and Shelf Areas.”
BioScience 57(7):573–83.
doi:[10.1641/B570707](https://doi.org/10.1641/B570707).
