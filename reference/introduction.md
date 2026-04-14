# Introduction Event data

A `tibble` containing the introduction events present in the Shiny app.
This dataset can be useful when working with the database
programmatically.

## Usage

``` r
introduction
```

## Format

### `introduction`

A `tibble` data frame with 6,077 rows and 10 columns:

- occurenceID:

  An identifier for the occurrence. Identifier specific to the data set

- taxonID:

  An identifier for the set of taxon information. Identifier specific to
  the data set.

- year:

  The four-digit year in which the introduction event occurred,
  according to the Common Era Calendar.

- country:

  Country where the invasion event occurred

- establishmentMeans:

  Statement about whether an organism has been introduced to a given
  place and time through the direct or indirect activity of modern
  humans.

- occurrenceRemarks:

  Comments or notes about the occurrence.

- degreeOfEstablishment:

  The degree to which a dwc:Organism survives, reproduces, and expands
  its range at the given place and time.

- ECO_CODE_X:

  Code of the Ecoregion (sensus Marine Ecoregion of the World according
  to [Spalding et al. 2007](https://doi.org/10.1641/B570707)) of the
  corresponding MSFD sub-region.

- associatedReferences:

  A list of publication, bibliographic reference, global unique
  identifier, URI)of literature associated with the occurrence.

- references:

  A related resource that is referenced, cited, or otherwise pointed to
  by the described resource.

## Source

ANIS-E package
