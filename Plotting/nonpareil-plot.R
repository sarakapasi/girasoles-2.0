install.packages('Nonpareil')
install.packages('RColorBrewer')

library(Nonpareil)
library(RColorBrewer)

files <- list.files(
  "/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/nonpareil_curve-files/",
  pattern="*.npo",
  full.names=TRUE
)

# Load data without plotting
nps <- Nonpareil.set(files, plot=FALSE)

# ---- HIGHLY DISTINGUISHABLE COLORS ----
# Use Set3 or Dark2 palette depending on number of samples
n <- length(files)
if (n <= 12) {
  cols <- brewer.pal(n, "Set3")
} else {
  cols <- colorRampPalette(brewer.pal(12, "Set3"))(n)
}

# Create the plot
png("nonpareil_plot_0630.png", width = 2000, height = 1600, res = 300)

Nonpareil.set(
  files,
  plot.opts = list(
    plot.observed = FALSE,
    model.lwd = 3,
    legend = FALSE,
    col = cols
  )
)
dev.off()

# Create the legend separately
png("nonpareil_legend_0630.png", width = 1200, height = 2500, res = 300)

par(mar=c(0,0,0,0))
plot.new()

raw_names <- basename(files)

legend(
  "topleft",
  legend = raw_names,
  col = cols,
  lwd = 3,
  cex = 0.8,
  bty = "n",
)
dev.off()
