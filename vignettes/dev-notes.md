---
title: "Development Notes"
author: "Duncan Garmonsway"
date: "2017-11-13"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



## Classify spreadsheets

It might be useful to automatically classify spreadsheets that are published on
Data.Gov.UK, to assist in finding data in the desired form (raw data, summary
tables, interactive calculations).  It might also help prioritise revision of
spreadsheets that fall short of best practice for given uses and users.

## Data

A sample of spreadsheets from Data.Gov.UK would be great, but they don't seem to
be centrally hosted, so I've asked the team on slack (#datagovuk) whether
there's a way to access them in bulk.

> Hello, I'm doing some experimental analysis of government spreadsheets and
> have a couple of Qs about data.gov.uk datasets.  Is it possible to filter for
> specifically the XLSX file format (the XLS filter seems to include both .xls
> and .xlsx)?  Is there a way to access the files in bulk, or has anyone
> attempted to scrape a large sample of them before?  Is this a good place for
> these questions?

Meanwhile I'll use the [Enron
corpus](https://figshare.com/articles/Enron_Spreadsheets_and_Emails/1221767)
([via](http://www.felienne.com/archives/3634)), which I already have for testing
[tidyxl](https://nacnudus.github.io/tidyxl).

## Methods

### 1. t-SNE

t-SNE is a dimension reduction technique that Matthew Gregory used to classify
handwritten digits from the MNIST dataset.  It could be used to classify
spreadsheets by the shape of the data in them.

#### Challenges

* Not all spreadsheets have the same 'resolution' (use the same number of cells
  along each dimensions).  It might not be _that_ important, because not all
  digits in the MNIST data are written at the same size (but the images are all
  the same size).  Options:
  * Down/upsample to standardise the resolution
  * Only examine part of each spreadsheet.  Whatever fits on a screen is usually
    enough for a human at first glance to feel that sinking feeling.  On my
    screen, that is the range `A1:Z42` on a blank sheet.


```r
knitr::include_graphics("sheet-view-range-a1z42.png")
```

![plot of chunk unnamed-chunk-1](sheet-view-range-a1z42.png)

```
@inproceedings{hermans2015,
  author    = {Felienne Hermans and
               Emerson Murphy-Hill},
  title     = {Enron's Spreadsheets and Related Emails: A Dataset and Analysis},
  booktitle = {37th International Conference on Software Engineering, {ICSE} '15},
  note     =  {to appear}
  }
```
