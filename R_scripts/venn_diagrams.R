#install.packages("VennDiagram")
library(VennDiagram)

# SPECIES
area1 <- 1378
area2 <- 1396
area3 <- 1482
n12 <- 1355


# GENUS
area1 <- 1637
area2 <- 1660
area3 <- 1753
n12 <- 1609


#dev.off()
venn.plot <- draw.triple.venn(
  area1, area2, area3, 
  n12, 
  n23 = area2, 
  n13 = area1, 
  n123 = n12, 
  category = c("15mers", "16mers", "all"),
  fill = c("blue", "red", "yellow"),
  lty = "blank",
  cex = 2,
  alpha =  rep(0.5, 3), #circle transparency
  cat.cex = 2,
  cat.pos = c(-40, 40, 180),
  cat.dist = 0.09,
  cat.just = list(c(0, -8), c(-1, 4), c(10.5, 2)),
  ext.pos = 30,
  ext.dist = -0.05,
  ext.length = 0.85,
  ext.line.lwd = 2,
  ext.line.lty = "dashed"
);
#grid.draw(venn.plot);
grid.newpage();

