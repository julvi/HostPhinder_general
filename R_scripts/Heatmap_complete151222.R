##############################################################################
# Heat maps complete
##############################################################################

rm(list=ls())


if (!require("gplots")) {
  install.packages("gplots", dependencies = TRUE)
  library(gplots)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer", dependencies = TRUE)
  library(RColorBrewer)
}

### B) Reading in data and transform it into matrix format

setwd("~/GoogleDrive/PhD/HostPhinder_general/Argentina/heatmap")


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
host2 <- myReadTable('ann_vs_pred_compl_109sp_151222.tsv', 
                     'ann_sp_row_names_complete', 
                     'ann_sp_col_names_complete')


host_matrix <- data.matrix(host2)
my_palette <- colorRampPalette(c("white", "red"))(n = 299)

#########################################################
### C) Customizing and plotting the heat map
#########################################################
# create heatmap pdf
setwd("~/Desktop")
#pdf("genera2.pdf", width=10, height = 10)
pdf("species_complete.pdf", width=12, height = 12)
heatmap.2(host_matrix, 
          density.info="none",  # turns off density plot inside color legend         
          # level trace
          trace='none',         # turns off trace lines inside the heat map
          # block sepration
          colsep=1:ncol(host_matrix),
          rowsep=1:nrow(host_matrix),
          sepcolor="gray",
          sepwidth=c(0.1,0.1),          
          margins =c(12, 12),     # widens margins around plot SPECIES
       
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="none",     # only draw a row dendrogram
          #scale="both",
          Rowv="NA",
          Colv="NA",            # turn off column clustering
          # Matrix determining the position of 
          #     [,1] [,2] [,3]
          #[1,]    0    3    0
          #[2,]    2    1    0
          #[3,]    0    0    0
          #[4,]    0    4    0
          #1. Heatmap,
          #2. Row dendrogram,
          #3. Column dendrogram,
          #4. Key
          # Rows or columns of 0's were added to introduce space
          lmat=rbind(c(0,3,0),c(2,1,0),c(0,0,0),c(0,4,0)) ,
          # heigh of each element determined by each row in the matrix above
          lhei=c(0.1,3,0.05,0.35), #SPECIES
          # width of each element determined by each column in the matrix above
          lwid=c(0.05,1,0.05),
          key.xlab="Fraction of shared prediction",
          keysize = 0.1)  # consider removing keysize, does not change anything
# SPECIES
mtext(expression(bold(Predicted ~ host ~ species ~ (Phage ~ occurrencies ~ within ~ phages["train-test,species"]))), 1, line=-2)  # xlabel
mtext(expression(bold(Annotated ~ host ~ species ~ (Phage ~ occurrencies ~ within ~ phages["eval,species"]))), 4, line=0) # ylabel

dev.off()



setwd("~/GoogleDrive/PhD/HostPhinder_general/Argentina/heatmap")
#GENERA
host2 <- myReadTable('ann_vs_pred_compl_76gn_151222.tsv', 'ann_gn_row_names_complete', 'ann_gn_col_names_complete')

host_matrix <- data.matrix(host2)
my_palette <- colorRampPalette(c("white", "red"))(n = 299)
# create heatmap pdf
setwd("~/Desktop")
pdf("genera_complete.pdf", width=10, height = 10)

heatmap.2(host_matrix, 
          density.info="none",  # turns off density plot inside color legend         
          # level trace
          trace='none',         # turns off trace lines inside the heat map
          # block sepration
          colsep=1:ncol(host_matrix),
          rowsep=1:nrow(host_matrix),
          sepcolor="gray",
          sepwidth=c(0.1,0.1),          
          margins =c(10,10),  # GENUS
          col=my_palette,       # use on color palette defined earlier 
          dendrogram="none",     # only draw a row dendrogram
          #scale="both",
          Rowv="NA",
          Colv="NA",            # turn off column clustering
          # Matrix determining the position of 
          #     [,1] [,2] [,3]
          #[1,]    0    3    0
          #[2,]    2    1    0
          #[3,]    0    0    0
          #[4,]    0    4    0
          #1. Heatmap,
          #2. Row dendrogram,
          #3. Column dendrogram,
          #4. Key
          # Rows or columns of 0's were added to introduce space
          lmat=rbind(c(0,3,0),c(2,1,0),c(0,0,0),c(0,4,0)) ,
          # heigh of each element determined by each row in the matrix above
          lhei=c(0.1,3,0.1,0.42), #GENUS
          # width of each element determined by each column in the matrix above
          lwid=c(0.05,1,0.05),
          key.xlab="Fraction of shared prediction",
          keysize = 0.1)  # consider removing keysize, does not change anything

# GENUS
mtext(expression(bold(Predicted ~ host ~ genus ~ (Phage ~ occurrencies ~ within ~ phages["train-test,genus"]))), 1, line=-2)  # xlabel
mtext(expression(bold(Annotated ~ host ~ genus ~ (Phage ~ occurrencies ~ within ~ phages["eval,genus"]))), 4, line=0) # ylabel
dev.off()

