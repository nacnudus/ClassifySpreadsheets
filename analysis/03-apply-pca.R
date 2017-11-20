# Choose the number of dimensions to pay attention to
ncp <- 12

library(here)
# source(here("analysis", "01-import.R"))

library(FactoMineR)
library(factoextra)
library(stringr)
library(gridExtra)

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
plotdim1 <-
  contributions %>%
    gather(dim, contribution, starts_with("Dim.")) %>%
    filter(dim == "Dim.1") %>%
    ggplot(aes(col, row, fill = abs(contribution))) +
      geom_tile() +
      scale_x_continuous(limits = range(view_rows)) +
      scale_y_reverse(limits = rev(range(view_cols))) +
      scale_fill_viridis_c(guide = FALSE) +
      ggtitle("Dimension 1") +
      theme_void()
plotdim2 <-
  contributions %>%
    gather(dim, contribution, starts_with("Dim.")) %>%
    filter(dim == "Dim.2") %>%
    ggplot(aes(col, row, fill = abs(contribution))) +
      geom_tile() +
      scale_x_continuous(limits = range(view_rows)) +
      scale_y_reverse(limits = rev(range(view_cols))) +
      scale_fill_viridis_c(guide = FALSE) +
      ggtitle("Dimension 2") +
      theme_void()
plotdim3 <-
  contributions %>%
    gather(dim, contribution, starts_with("Dim.")) %>%
    filter(dim == "Dim.3") %>%
    ggplot(aes(col, row, fill = abs(contribution))) +
      geom_tile() +
      scale_x_continuous(limits = range(view_rows)) +
      scale_y_reverse(limits = rev(range(view_cols))) +
      scale_fill_viridis_c(guide = FALSE) +
      ggtitle("Dimension 3") +
      theme_void()
plotind12 <- fviz_pca_ind(pca, axes = c(1, 2), label = "none") + coord_fixed()
plotind13 <- fviz_pca_ind(pca, axes = c(1, 3), label = "none") + coord_fixed()
plotind23 <- fviz_pca_ind(pca, axes = c(2, 3), label = "none") + coord_fixed()

p <- grid.arrange(arrangeGrob(plotdim1, plotdim2), plotind12, nrow = 1)
ggsave(here("vignettes", "fviz_pca_ind_1-2.png"), p, width = 25.14187, height = 13.51111, units = "cm")

p <- grid.arrange(arrangeGrob(plotdim1, plotdim3), plotind13, nrow = 1)
ggsave(here("vignettes", "fviz_pca_ind_1-3.png"), p, width = 25.14187, height = 13.51111, units = "cm")

p <- grid.arrange(arrangeGrob(plotdim2, plotdim3), plotind23, nrow = 1)
ggsave(here("vignettes", "fviz_pca_ind_2-3.png"), p, width = 25.14187, height = 13.51111, units = "cm")

# Get the file/sheet of the extremes in each of the first two dimensions
individuals <-
  pca$ind$coord[, 1:3] %>%
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
