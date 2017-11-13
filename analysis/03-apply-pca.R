# Choose the number of dimensions to pay attention to
ncp <- 12

library(here)
# source(here("analysis", "01-import.R"))

library(FactoMineR)
library(factoextra)
library(stringr)

pca <- PCA(feature_matrix, ncp = ncp, graph = FALSE)

# Two dimensions explain ~12% of the variation
fviz_eig(pca, ncp = ncp)
ggsave(here("vignettes", "fviz_eig.png"), width = 25.14187, height = 13.51111, units = "cm")

# Individuals are not very influential
fviz_contrib(pca, choice = "ind") +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())
ggsave(here("vignettes", "fviz_contrib_ind.png"), width = 25.14187, height = 13.51111, units = "cm")

# Visualize the contribution of each cell to each dimension
contributions <-
  pca$var$contrib %>%
  as_data_frame(rownames = "var") %>%
  mutate(row = rep(view_rows, each = length(view_cols)),
         col = rep(view_cols, times = length(view_rows)))
contributions %>%
  gather(dim, contribution, starts_with("Dim.")) %>%
  mutate(dim = as.integer(str_sub(dim, 5L))) %>%
  ggplot(aes(col, row, fill = contribution)) +
    geom_tile() +
    scale_x_continuous(limits = range(view_rows)) +
    scale_y_reverse(limits = rev(range(view_cols))) +
    scale_fill_viridis_c() +
    facet_wrap(~dim)
ggsave(here("vignettes", "cell_contributions.png"), width = 25.14187, height = 13.51111, units = "cm")

# Vizualise the first two dimensions
fviz_pca_ind(pca, label = "none")
ggsave(here("vignettes", "fviz_pca_ind.png"), width = 25.14187, height = 13.51111, units = "cm")

# Get the file/sheet of the extremes in each of the first two dimensions
individuals <-
  pca$ind$coord[, 1:2] %>%
  as_data_frame() %>%
  mutate(file_sheet = rownames(feature_matrix)) %>%
  select(file_sheet, everything())

extremes <-
  individuals %>%
  filter(Dim.1 == min(Dim.1) | Dim.1 == max(Dim.1)
         | Dim.2 == min(Dim.2) | Dim.2 == max(Dim.2)) %>%
  arrange(Dim.1, Dim.2)
