# Incorporate formats among the features

# Choose the number of dimensions to pay attention to
ncp <- 12

library(here)
# source(here("analysis", "01-import.R"))

library(FactoMineR)
library(factoextra)
library(stringr)

# Convert to a matrix, one row per sheet, one column per cell
feature_matrix_formats <-
  view_ranges %>%
  gather(feature, value, -filename, -sheet, -row, -col) %>%
  arrange(filename, sheet, row, col, feature) %>%
  rename(y = row, x = col, z = value) %>%
  mutate(z = as.integer(z)) %>% # encode blanks as 0
  pull(z) %>%
  matrix(ncol = nrow(view_range) * 8, byrow = TRUE) # 8 types of feature (is_blank, biu, etc.)

feature_names <-
  view_ranges %>%
  distinct(filename, sheet) %>%
  arrange(filename, sheet) %>%
  mutate(rownames = paste(filename, "|", sheet))
rownames(feature_matrix_formats) <- feature_names$rownames

dim(feature_matrix_formats)
# [1] 3322 5000 with a sample of 1000 workbooks

pca_formats <- PCA(feature_matrix_formats, ncp = ncp, graph = FALSE)

# One dimension explains ~12% of the variation
fviz_eig(pca_formats, ncp = ncp)
ggsave(here("vignettes", "fviz_eig_formats.png"),
       width = 25.14187, height = 13.51111, units = "cm")

# Individuals are not very influential
fviz_contrib(pca_formats, choice = "ind") +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())
ggsave(here("vignettes", "fviz_contrib_ind_formats.png"),
       width = 25.14187, height = 13.51111, units = "cm")

# Visualize the contribution of each cell to each dimension
contributions_formats <-
  pca_formats$var$contrib %>%
  as_data_frame(rownames = "var") %>%
  mutate(row = rep(view_rows, each = length(view_cols) * 8),
         col = rep(view_cols, times = length(view_rows) * 8),
         feature = rep(c("character",
                         "numeric",
                         "date",
                         "is_blank",
                         "biu",
                         "fill",
                         "border",
                         "indent"),
                       times = length(view_rows) * length(view_cols)))

contributions_formats %>%
  gather(dim, contribution, starts_with("Dim.")) %>%
  mutate(dim = as.integer(str_sub(dim, 5L))) %>%
  filter(dim <= 8L) %>%
  ggplot(aes(col, row, fill = abs(contribution))) +
    geom_tile() +
    scale_x_continuous(limits = range(view_rows)) +
    scale_y_reverse(limits = rev(range(view_cols))) +
    scale_fill_viridis_c() +
    facet_grid(feature~dim)
ggsave(here("vignettes", "cell_contributions_formats.png"), width = 25.14187, height = 13.51111, units = "cm")

# Vizualise the first two dimensions
fviz_pca_ind(pca_formats, label = "none")
ggsave(here("vignettes", "fviz_pca_ind_formats_1-2.png"),
       width = 25.14187, height = 13.51111, units = "cm")

# Vizualise the first and third dimensions
fviz_pca_ind(pca_formats, axes = c(1, 3), label = "none")
ggsave(here("vignettes", "fviz_pca_ind_formats_1-3.png"),
       width = 25.14187, height = 13.51111, units = "cm")

# Vizualise the second and third dimensions
fviz_pca_ind(pca_formats, axes = c(2, 3), label = "none")
ggsave(here("vignettes", "fviz_pca_ind_formats_2-3.png"),
       width = 25.14187, height = 13.51111, units = "cm")


# Get the file/sheet of the extremes in each of the first two dimensions
individuals <-
  pca_formats$ind$coord[, 1:3] %>%
  as_data_frame() %>%
  mutate(file_sheet = rownames(feature_matrix)) %>%
  select(file_sheet, everything())

individuals %>%
  filter(Dim.1 %in% range(Dim.1)
         | Dim.2 %in% range(Dim.2)
         | Dim.3 %in% range(Dim.3)) %>%
  group_by(Dim.1, Dim.2, Dim.3) %>%
  slice(1) %>%
  ungroup() %>%
  arrange(Dim.1, Dim.2)
