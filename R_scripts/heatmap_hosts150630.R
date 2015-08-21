#-----------------------------------------------------------------------------
# Heatmap
#-----------------------------------------------------------------------------

#clear the workspace
rm(list=ls())


# http://sebastianraschka.com/data/scripts/heatmaps_in_r.R
#########################################################
### A) Installing and loading required packages
#########################################################

if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer", dependencies = TRUE)
  library(RColorBrewer)
}

#########################################################
### B) Reading in data and transform it into matrix format
#########################################################

setwd("~/GoogleDrive/PhD/HostPhinder_general/Argentina/heatmap")


myReadTable<-function(mytablefile, rownamesfile, colnamesfile){
  # read table from file return it with column names
  mytable <- read.table(mytablefile, as.is=T, sep='\t')
  row_names <- read.table(rownamesfile, as.is=T)
  col_names <- read.table(colnamesfile, as.is=T)
  mytable <- mytable[,-1] 
  
  # Name the rows by host name
  rownames(mytable) <- row_names[,1]
  colnames(mytable) <- col_names[,1]
  
  return(mytable)
}

# read all files into list of tables
# GENERA
host2 <- myReadTable('ann_vs_pred_50gn_150630.tab', 'ann_gn_row_names', 'ann_gn_col_names')

# SPECIES
#host2 <- myReadTable('ann_vs_pred_87sp_150630.tab', 'ann_sp_row_names', 'ann_sp_col_names')


host_matrix <- data.matrix(host2)


#########################################################
### C) Customizing and plotting the heat map
#########################################################
# create heatmap pdf
pdf("genera.pdf", width=10, height = 10)
#pdf("species.pdf", width=10, height = 12)

my_palette <- colorRampPalette(c("white", "yellow", "red"))(n = 299)


heatmap.2(host_matrix, 
          #cellnote = host_matrix,  # same data set for cell labels
          #main = "Annotated host species vs. predicted species", # heat map title
          main = "Annotated host genera vs. predicted genera",
          #notecol="black",      # change font color of cell labels to black
          density.info="none",  # turns off density plot inside color legend

          # level trace
          trace='none',         # turns off trace lines inside the heat map
          #tracecol="cyan",
          #hline=median(breaks),
          #vline=median(breaks),
          #linecol=tracecol,
          
          # block sepration
          colsep=1:ncol(host_matrix),
          rowsep=1:nrow(host_matrix),
          sepcolor="gray",
          sepwidth=c(0.1,0.1),
          
          margins =c(10,12),     # widens margins around plot SPECIES
          #margins =c(10,10),  # GENUS
          col=my_palette,       # use on color palette defined earlier 
          #col=heat.colors(256),
          #breaks=col_breaks,    # enable color transition at specified limits
          dendrogram="none",     # only draw a row dendrogram
          #scale="both",
          Rowv="NA",
          Colv="NA",            # turn off column clustering
          lmat=rbind(c(0,3),c(2,1),c(0,4)) ,
          #lhei=c(0.4,4,0.5), #SPECIES
          lhei=c(0.4,4,0.6), #GENUS
          lwid=c(0.2,4),
          key.xlab="Fraction of shared prediction")

dev.off()
# close the pdf device