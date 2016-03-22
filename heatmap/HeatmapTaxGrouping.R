##############################################################################
# Heat maps grouping
##############################################################################

rm(list=ls())


if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}

setwd("~/HostPhinder/heatmap/data")

myReadTable<-function(mytablefile, rownamesfile, colnamesfile){
  # read table from file return it with column names
  mytable <- read.table(mytablefile, as.is=T, sep='\t')
  row_names <- read.table(rownamesfile, as.is=T, sep='\t')
  col_names <- read.table(colnamesfile, as.is=T, sep='\t')
  mytable <- mytable[,-1] 
  
  # Name the rows by host name
  rownames(mytable) <- row_names[,1]
  colnames(mytable) <- col_names[,1]
  
  return(mytable)
}

# read all files into list of tables

# SPECIES
host <- myReadTable('ann_vs_pred_compl_109sp_taxSorted.tsv', 
                     'ann_sp_row_names_compl_taxSorted', 
                     'ann_sp_col_names_compl_taxSorted')

sp_taxonomy <- read.table("species.tax", sep = '\t')

tax_as_num <- as.numeric(unlist(sp_taxonomy[1]))
ncolrs <- length(unique(tax_as_num))
colrs  <- c('#7fc97f','#beaed4','#fdc086','#ffff99','#386cb0','#f0027f','#bf5b17','#666666')
#colrs  <- topo.colors(ncolrs) 
xcolrs <- colrs[tax_as_num] 


host_matrix <- data.matrix(host)

# Add attribute to matrix
#attr(host_matrix, 'Phylum') = sp_taxonomy[1]



my_palette <- colorRampPalette(c("white", "red"))(n = 299)
dev.off()

# create heatmap pdf
setwd("~/Desktop")
#pdf("genera2.pdf", width=10, height = 10)

#par('mar')
#[1] 5.1 4.1 4.1 2.1



par()$din # R.O.; the device dimensions, (width, height), in inches
#[1] 18.18056 14.68056
par()$fin # The figure region dimensions, (width, height), in inches.
#[1] 18.18056 14.68056
par()$pin # The current plot dimensions, (width, height), in inches.
#[1] 18.18056 14.68056
par()$omi

      
pdf("species_grouping.pdf", width=10, height = 10)
par(mar = c(0,0,0,0))
#par(mar=c(5,4,4,2) + 0.1)
par(pin=c(5,2))
par(plt = c(0,0,0,0))
heatmap.2(host_matrix, 
          density.info="none",  # turns off density plot inside color legend         
          # level trace
          trace='none',         # turns off trace lines inside the heat map
          # block sepration
          colsep=1:ncol(host_matrix),
          rowsep=1:nrow(host_matrix),
          sepcolor="gray",
 #         sepwidth=c(0.1,0.1),          
          margins =c(12, 12),     # widens margins around plot SPECIES
          
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="none",     # only draw a row dendrogram
          #scale="both",
          Rowv="NA",
          Colv="NA",            # turn off column clustering
          
          RowSideColors=xcolrs, ColSideColors=xcolrs, #
          legend("topright", 
                 legend=c("Actinobacteria", "Bacteroidetes", "Chlamydiae",
                  "Cyanobacteria", "Deinococcus-Thermus", "Firmicutes",
                  "Proteobacteria", "Tenericutes"), 
                 fill = colrs, bty="n"),  
          # Rows or columns of 0's were added to introduce space
          #lmat=rbind(c(0,3,3,0),c(2,1,1,0),c(2,1,1,0),c(0,4,4,0)) ,
          # heigh of each element determined by each row in the matrix above
          #lhei=c(0,1,1,0.35), #SPECIES
          # width of each element determined by each column in the matrix above
          #lwid=c(0,1,1,0.05),
          key.xlab="Fraction of shared prediction",
          keysize = 0.1)

mtext(expression(bold(Predicted ~ host ~ species ~ (Phage ~ occurrencies ~ within ~ phages["train-test,species"]))), 1, line=-2)  # xlabel
mtext(expression(bold(Annotated ~ host ~ species ~ (Phage ~ occurrencies ~ within ~ phages["eval,species"]))), 4, line=0) # ylabel
dev.off()
