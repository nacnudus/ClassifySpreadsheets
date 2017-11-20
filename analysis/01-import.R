# 1. Import spreadsheets from the Enron corpus
# 2. Filter for cells in the range A1:Z42 (the visible range on my monitor)
# 3. Reshape into a matrix using the row and col, and encoding as 1 if
#    !is_blank, otherwise 0.

# Set the path to your directory of Enron spreadsheets here

enron_path <- "~/R/enron/enron_corpus-master-b26c7bcad107f247f6bc4f4ca5808131a8745ac0/sheets"

# Set the view range here
view_rows <- 1:25
view_cols <- 1:25

# Set the sample size for testing here
sample_size <- 1000

library(tidyverse)
library(tidyxl)
library(here)

all_paths <- list.files(enron_path, full.names = TRUE)

# For testing, look at n random workbooks.
set.seed(2017-11-13)
sample_paths <- sample(all_paths, sample_size)
paths <- sample_paths

# For real, comment the above and uncomment the below
# paths <- all_paths

paths <- sample(list.files(enron_path, full.names = TRUE), sample_size)

books <-
  data_frame(path = paths,
             filename = basename(paths)) %>%
  mutate(id = as.character(row_number()))

view_range <- crossing(row = view_rows, col = view_cols)

load_view_range <- function(x) {
  x %>%
  xlsx_cells() %>%
  filter(!is_blank) %>% # blanks will be reinstated in a moment
  inner_join(view_range, by = c("row", "col")) %>% # filter for the view range
  select(sheet, row, col)
}

view_ranges <-
  map_dfr(books$path, load_view_range, .id = "id") %>%
  inner_join(books, by = "id") %>%
  select(-id) %>%
  mutate(value = 1L) %>% # encode any non-blank cells as 1
  group_by(filename, sheet) %>% # pad each view range with blanks
  complete(row = view_rows, col = view_cols, fill = list(value = 0L)) %>%
  ungroup()

# Check that there is a complete view range for all sheets
nrow(view_ranges) / nrow(view_range) == nrow(distinct(view_ranges, filename, sheet))

# Convert to a matrix, one row per sheet, one column per cell
feature_matrix <-
  view_ranges %>%
  arrange(filename, sheet, row, col) %>%
  rename(y = row, x = col, z = value) %>%
  mutate(z = 1L - z) %>% # Make red = value rather than no value
  pull(z) %>%
  matrix(ncol = nrow(view_range), byrow = TRUE)
feature_names <-
  view_ranges %>%
  distinct(filename, sheet) %>%
  arrange(filename, sheet) %>%
  mutate(rownames = paste(filename, "|", sheet))
rownames(feature_matrix) <- feature_names$rownames

dim(feature_matrix)
# [1] 3258  625 with a sample of 1000 workbooks

# Plot a few of them.  red = value, beige = blank
image_inputs <-
  view_ranges %>%
  rename(x = row, y = col, z = value) %>%
  mutate(z = 1L - z) %>% # Make red = value rather than no value
  group_by(filename, sheet) %>%
  arrange(filename, sheet, desc(x), y) %>% # Flip along a horizontal axis for plotting
  ungroup() %>%
  nest(-filename, -sheet) %>%
  mutate(matrix = map(data, ~ matrix(.x$z, ncol = length(view_cols)))) %>%
  slice(c(54, 4, 58, 55, 1, 3))

par(mfrow = c(2, 3))
par(adj = 0)
pwalk(list(image_inputs$matrix, image_inputs$filename, image_inputs$sheet),
      ~ {image(..1, axes = FALSE); title(..2, sub = ..3)})
par(mfrow=c(1, 1))
par(adj = 0.5)

# Save that visualisation for the vignette
par(mfrow = c(2, 3))
par(adj = 0)
png(here("vignettes", "view-ranges.png"), width = 954, height = 512, units = "px")
  par(mfrow = c(2, 3))
  par(adj = 0)
  pwalk(list(image_inputs$matrix, image_inputs$filename, image_inputs$sheet),
        ~ {image(..1, axes = FALSE); title(..2, sub = ..3)})
dev.off()
par(mfrow=c(1, 1))
par(adj = 0.5)
