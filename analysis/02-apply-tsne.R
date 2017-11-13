library(here)
# source(here("analysis", "01-import.R"))

library(Rtsne)

dim(feature_matrix)
tsne <- Rtsne(feature_matrix, check_duplicates = FALSE) # Takes a few minutes

png(here("vignettes", "tsne-1000.png"), width = 954, height = 512, units = "px")
  plot(tsne$Y, main = "t-SNE of Enron: 3258 sheets in 1000 workbooks A1:Y25")
dev.off()
