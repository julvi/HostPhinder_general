rm(list=ls())
##############################################################################
# Figure 1
##############################################################################
setwd("~/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pie_chart")

myReadTable<-function(file){
  # read table from file return it with column names
  x <- read.table(file, check.names=FALSE, header = T, sep="\t",
                  as.is = T, fill = T, row.names = 1)
  return(x)
}
# read all files into list of tables
lot <- lapply(c('species_distr_1871.tab','genera_distr_2196.tab'),myReadTable)

myFrequentHosts <- function(table){
  high_freq_hosts <- table[which(table$Percentage >= 2),]
  low_freq_hosts <- table[which(table$Percentage < 2),]
  freq_hosts <- rbind(high_freq_hosts, c(sum(low_freq_hosts$Count),
                                         sum(low_freq_hosts$Percentage)))
  rownames(freq_hosts)[nrow(freq_hosts)] <- 'Other'
  return(freq_hosts)
}

mypie <- function(freq_hosts, colours) {
  slices <- freq_hosts$Percentage
  lbls <- row.names(freq_hosts)
  pct <- format(round(freq_hosts$Percentage, 1), nsmall=1)
  lbls <- paste(lbls, pct) # add percents to labels
  lbls <- paste(lbls, "%", sep="") # add % to labels
  plot1 <- pie(slices, labels = lbls, col=colours, cex=1.4) #,
  return(plot1)
}

freq_hosts_lot <- lapply(lot, myFrequentHosts)

species_colours <- c("#fce94f", "#fcaf3e", "#e9b96e", "#8ae234", "#729fcf",
                     "#ad7fa8", "#ef2929", "#888a85")

genera_colours <-  c("#c4a000", "#ce5c00", "#fce94f", "#fcaf3e", "#e9b96e",
                     "#8ae234", "#729fcf", "#ad7fa8", "#5c3566", "#ef2929",
                     "#888a85", "#a40000", "#8f5902", "#4e9a06", "#204a87",
                     "#f57900")


setwd("~/Desktop")
par(mar=c(0, 0, 0, 0))

pdf("host_species.pdf", width=10.6,height=7)
mypie(freq_hosts_lot[[1]], species_colours) #, "Distribution of host species")
dev.off()

pdf("host_genera.pdf", width=10.6,height=7)
mypie(freq_hosts_lot[[2]], genera_colours) #, "Distribution of host genera")
dev.off()

##############################################################################
# Figure 2
##############################################################################
#clear the workspace
rm(list=ls())

require(ggplot2)
require(gridExtra)

setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pred_curves")

#-------------------- Criterion 3 CLUSTERING ---------------------------------#
myReadTable<-function(file){
  # read table from file return it with column names
  x <- read.table(file, as.is=T, header=T)
  colnames(x)[1] <- "value"
  # remove column containg ssd and sem
  x <- subset(x, , -c(ssd, sem))
  x$CImin <- NA
  x$CImax <- NA
  x[x$mean == max(x$mean), ]$CImin <- min(x[x$mean >= max(x$mean)*0.99,1])
  x[x$mean == max(x$mean), ]$CImax <- max(x[x$mean >= max(x$mean)*0.99,1])
  return(x)
}

lot_cr3_noCLUST <- lapply(c('f_mean_ssd_sem_234gn_no_clust.tab',
                            'f_mean_ssd_sem_235gn_no_clust.tab',
                            'f_mean_ssd_sem_245gn_no_clust.tab',
                            'f_mean_ssd_sem_345gn_no_clust.tab'), myReadTable)

lot_cr3_noCLUST_sp <- lapply(c('f_mean_ssd_sem_234sp_no_clust.tab',
                               'f_mean_ssd_sem_235sp_no_clust.tab',
                               'f_mean_ssd_sem_245sp_no_clust.tab',
                               'f_mean_ssd_sem_345sp_no_clust.tab'), myReadTable)


myplot4<-function(mytable) { 
  # take the first column name (f or alpha)
  plot1 <- ggplot(NULL,aes(x=value, y=mean)) +    
    geom_point(data = mytable[[1]], size = 3, color="#73d216") +# 234 => green
    geom_line(data = mytable[[1]], size = 1, color="#73d216") + 
    geom_errorbarh(data = mytable[[1]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#73d216") +
    geom_point(data = mytable[[2]], size = 3, color="#3465a4") +# 235 => blue
    geom_line(data = mytable[[2]], size = 1, color="#3465a4") + 
    geom_errorbarh(data = mytable[[2]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#3465a4") +
    geom_point(data = mytable[[3]], size = 3, color="#cc0000") +# 245 => red
    geom_line(data = mytable[[3]], size = 1, color="#cc0000") + 
    geom_errorbarh(data = mytable[[3]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#cc0000") +
    geom_point(data = mytable[[4]], size = 3, color="#555753") +# 345 => black
    geom_line(data = mytable[[4]], size = 1, color="#555753") + 
    geom_errorbarh(data = mytable[[4]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#555753") +
    scale_x_continuous(breaks=0:10*0.1) +
    xlab(expression(italic("f"))) +
    ylab("accuracy mean") +
    theme(axis.title.x = element_text(size=50),
          axis.title.y = element_text(size=50),
          axis.text.x  = element_text(size=25),
          axis.text.y  = element_text(vjust=0.5, size=25))
  
  return(plot1)
}

pl1 <- myplot4(lot_cr3_noCLUST_sp) 
pl2 <- myplot4(lot_cr3_noCLUST) 

setwd("~/Desktop")
pdf("cr3_sp.pdf", width=10, height = 10)
pl1
dev.off()
pdf("cr3_gn.pdf", width=10, height = 10)
pl2
dev.off()


##############################################################################
# Figure 3
##############################################################################
rm(list=ls())

require(ggplot2)
require(gridExtra)

setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pred_curves")


#-------------------- Criterion 4 CLUSTERING ---------------------------------#

myReadTable_alpha<-function(file){
  # read table from file return it with column names
  x <- read.table(file, as.is=T)
  colnames(x) <- c("value", "mean") 
  x$CImin <- NA
  x$CImax <- NA
  x[x$mean == max(x$mean), ]$CImin <- min(x[x$mean >= max(x$mean)*0.99,1])
  x[x$mean == max(x$mean), ]$CImax <- max(x[x$mean >= max(x$mean)*0.99,1])
  
  return(x)
}

myplot5<-function(mytable) { 
  # take the first column name (f or alpha)
  plot1 <- ggplot(NULL,aes(x=value, y=mean)) +    
    geom_point(data = mytable[[1]], size = 3, color="#73d216") +# 234 => green
    geom_line(data = mytable[[1]], size = 1, color="#73d216") + 
    geom_errorbarh(data = mytable[[1]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#73d216") +
    geom_point(data = mytable[[2]], size = 3, color="#3465a4") +# 235 => blue
    geom_line(data = mytable[[2]], size = 1, color="#3465a4") + 
    geom_errorbarh(data = mytable[[2]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#3465a4") +
    geom_point(data = mytable[[3]], size = 3, color="#cc0000") +# 245 => red
    geom_line(data = mytable[[3]], size = 1, color="#cc0000") + 
    geom_errorbarh(data = mytable[[3]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#cc0000") +
    geom_point(data = mytable[[4]], size = 3, color="#555753") +# 345 => black
    geom_line(data = mytable[[4]], size = 1, color="#555753") + 
    geom_errorbarh(data = mytable[[4]], aes(xmax = CImax, xmin = CImin, height = .002), size = 1, color="#555753") +
    scale_x_continuous(breaks=0:10) +
    xlab(expression(italic(alpha))) +
    ylab("accuracy mean") +
    theme(axis.title.x = element_text(size=50),
          axis.title.y = element_text(size=50),
          axis.text.x  = element_text(size=25),
          axis.text.y  = element_text(vjust=0.5, size=25))
  
  return(plot1)
}


lot_cr4_noCLUST <- lapply(c('id_ann_preds_234gn_alpha_no_clust.tab_alpha_vs_accMean',
                            'id_ann_preds_235gn_alpha_no_clust.tab_alpha_vs_accMean',
                            'id_ann_preds_245gn_alpha_no_clust.tab_alpha_vs_accMean',
                            'id_ann_preds_345gn_alpha_no_clust.tab_alpha_vs_accMean'), myReadTable_alpha)


lot_cr4_noCLUST_sp <- lapply(c('id_ann_preds_234sp_alpha_no_clust.tab_alpha_vs_accMean',
                               'id_ann_preds_235sp_alpha_no_clust.tab_alpha_vs_accMean',
                               'id_ann_preds_245sp_alpha_no_clust.tab_alpha_vs_accMean',
                               'id_ann_preds_345sp_alpha_no_clust.tab_alpha_vs_accMean'), myReadTable_alpha)


pl1 <- myplot5(lot_cr4_noCLUST_sp) 
pl2 <- myplot5(lot_cr4_noCLUST) 

setwd("~/Desktop")

pdf("cr4_sp.pdf", width=10, height = 10)
pl1
dev.off()

pdf("cr4_gn.pdf", width=10, height = 10)
pl2
dev.off()


##############################################################################
# Figure 4
##############################################################################
#clear the workspace
rm(list=ls())
setwd("~/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pred_hist")


myReadTable<-function(file){
  # read table from file return it with column names
  read.table(file)->x
  names(x)<-c('range', 'accuracy', 'count')
  return(x)
}
# read all files into list of tables
lot <- lapply(c('eval_cov_bins_acc_all_sp.tab','eval_cov_bins_acc_all_gn.tab'),
              myReadTable)

bnames <- c("0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8",
            "0.9")

mybarplot <-function(mytable, bnames){ 
  par(las=2) # --> make barplot write all labels
  myhist <- barplot(height=mytable$accuracy, axisnames=TRUE,
                    ylab = 'Accuracy', 
                    xlab = 'Coverage ranges',
                    ylim=c(0,1), panel.first=grid(), 
                    names.arg = bnames,
                    # tango palette colours
                    #cex.lab = 1.2, # axes names size
                    #cex.main = 1.5, # title font size
                    col= c("#babdb6", "#8ae234", "#8ae234", "#8ae234",
                           "#8ae234", "#8ae234", "#8ae234", "#8ae234",
                           "#4e9a06", "#4e9a06"))
  
  par(las=0)
  par(new=T)
  plot(mytable$range, mytable$count, axes=F, ylim=c(0,max(mytable$count)), 
       ylab = "", xlab="",lty=2, lwd=2)
  axis(4, ylim=c(0,max(mytable$count)),lwd=1,line=1)
  lines(mytable$range, mytable$count,pch=20)
  mtext(4,text="Count",line=3.5, cex=1)
  
  return(myhist)
}


setwd("~/Desktop")

par(mar=c(5, 5, 3, 7) + 0.1)
#par(mfrow=c(1,2))
par(mfrow=c(1,1))
#pdf("hist_eval_sp.pdf", width=7, height = 10)
plot1 <- mybarplot(lot[[1]], bnames)
#dev.off()


#pdf("hist_eval_gn.pdf", width=10, height = 10)
plot2 <- mybarplot(lot[[2]], bnames) 
#dev.off()



##############################################################################
# Figure 5
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
# GENERA
#host2 <- myReadTable('ann_vs_pred_50gn_150630.tab', 'ann_gn_row_names_par', 'ann_gn_col_names_par')

# SPECIES
host2 <- myReadTable('ann_vs_pred_87sp_150630.tab', 
                     'ann_sp_row_names_par', 
                     'ann_sp_col_names_par')


host_matrix <- data.matrix(host2)
my_palette <- colorRampPalette(c("white", "red"))(n = 299)
#my_palette <- colorRampPalette(c("white", "yellow", "red"))(n = 299)
#########################################################
### C) Customizing and plotting the heat map
#########################################################
# create heatmap pdf
setwd("~/Desktop")
#pdf("genera2.pdf", width=10, height = 10)
pdf("species2.pdf", width=12, height = 12)
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
          #margins =c(10,10),  # GENUS
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
          #lhei=c(0.1,3,0.1,0.42), #GENUS
          # width of each element determined by each column in the matrix above
          lwid=c(0.05,1,0.05),
          key.xlab="Fraction of shared prediction",
          keysize = 0.1)  # consider removing keysize, does not change anything
# SPECIES
mtext(expression(bold(Predicted ~ host ~ species ~ (Phage ~ occurrencies ~ within ~ phages["train-test,species"]))), 1, line=-2)  # xlabel
mtext(expression(bold(Annotated ~ host ~ species ~ (Phage ~ occurrencies ~ within ~ phages["eval,species"]))), 4, line=0) # ylabel

# GENUS

#mtext(expression(bold(Predicted ~ host ~ genus ~ (Phage ~ occurrencies ~ within ~ phages["train-test,genus"]))), 1, line=-2)  # xlabel
#mtext(expression(bold(Annotated ~ host ~ genus ~ (Phage ~ occurrencies ~ within ~ phages["eval,genus"]))), 4, line=0) # ylabel
dev.off()



##############################################################################
# Figure 6
##############################################################################
#clear the workspace
rm(list=ls())
setwd("~/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pred_hist")


myReadTable<-function(file){
  # read table from file return it with column names
  read.table(file)->x
  names(x)<-c('range', 'accuracy', 'count')
  return(x)
}
# read all files into list of tables
lot <- lapply(c('cov_bins_right_all_sp.tab', 'cov_bins_right_all_gn.tab',
                'MVP_cov_bins_acc_count_sp.tab', 'MVP_cov_bins_acc_count_gn.tab'),
              myReadTable)



bnames <- c("0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8",
            "0.9")

mybarplot <-function(mytable, bnames){ 
  par(las=2) # --> make barplot write all labels
  myhist <- barplot(height=mytable$accuracy, axisnames=TRUE,
                    ylab = 'Accuracy', 
                    xlab = 'Coverage ranges',
                    ylim=c(0,1), panel.first=grid(), 
                    names.arg = bnames,
                    col= c("#babdb6", "#8ae234", "#8ae234", "#8ae234",
                           "#8ae234", "#8ae234", "#8ae234", "#8ae234",
                           "#4e9a06", "#4e9a06"))
  par(las=0)
  par(new=T)
  plot(mytable$range, mytable$count, axes=F, ylim=c(0,max(mytable$count)), 
       ylab = "", xlab="",lty=2, lwd=2)
  axis(4, ylim=c(0,max(mytable$count)),lwd=1,line=1)
  lines(mytable$range, mytable$count,pch=20)
  mtext(4,text="Count",line=3.5, cex=1)
  
  return(myhist)
}


par(mar=c(5, 5, 3, 7) + 0.1)

par(mfrow=c(1,1))

plot1 <- mybarplot(lot[[1]], bnames)
plot2 <- mybarplot(lot[[2]], bnames)
plot3 <- mybarplot(lot[[3]], bnames)
plot4 <- mybarplot(lot[[4]], bnames)



##############################################################################
# Supplementary Figure 2
##############################################################################

library(ggplot2)
setwd("~/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/col_host_hist")
require(grid)

### SPECIES
gr_id_sp <- read.table("gr_accn_sp.tab", sep='\t')
colnames(gr_id_sp) <- c("group","ID", "host")

setwd("~/Desktop")
pdf("part_host_distr_sp.pdf", width=15, height = 23)

ggplot(gr_id_sp, aes(host)) + geom_bar(aes(fill=factor(host))) +
  facet_wrap(~ group, nrow = 5, ncol = 1) +
  theme(legend.key.size = unit(0.27, "cm"),
        strip.text.x = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        axis.text.x = element_text(color="white"),
        axis.ticks.x = element_line(color="white"),
        axis.title.y = element_text(size = 20),
        axis.text.y = element_text(size=15))

dev.off()


### GENUS
#16 mers host and size sorted
gr_id_gn <- read.table("gr_accn_gn.tab", sep='\t')
colnames(gr_id_gn) <- c("group","ID", "host")

setwd("~/Desktop")
pdf("part_host_distrAA.pdf", width=15, height = 15)

ggplot(gr_id_gn, aes(host)) + geom_bar(aes(fill=factor(host))) +
  facet_wrap(~ group, nrow = 5, ncol = 1) +
  theme(legend.key.size = unit(0.29, "cm"),
        strip.text.x = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        axis.text.x = element_text(color="white"),
        axis.ticks.x = element_line(color="white"),
        axis.title.y = element_text(size = 20),
        axis.text.y = element_text(size=15))

dev.off()



##############################################################################
# Supplementary Figure 3
##############################################################################

rm(list=ls())
# Dataframe: each field is a data partition and each value is a genome size
setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/vulcano_charts")
#install.packages('reshape')
library(reshape)
library(ggplot2)

############### 16mers on 16mers based partitioning host&size sorted ##########
### SPECIES
phages <- read.table("groups_sizes_sp.tab", sep="\t", 
                     header = T, as.is = T, fill = T)
### GENUS
phages <- read.table("groups_sizes_gn.tab", sep="\t", 
                     header = T, as.is = T, fill = T)

phages<-melt(phages)
colnames(phages)<-c("data_partition","genome_size")

setwd("~/Desktop")
pdf("part_size_distr_gn.pdf", width=15, height = 15)
png("part_size_distr_gnAA.png",    # create PNG for the heat map                
    width = 5*900,       # 5 x 900 pixels
    height = 5*900,      
    res = 300,            # 300 pixels per inch
    pointsize = 80)

pdf("part_size_distr_sp.pdf", width=15, height = 15)
png("part_size_distr_spAA.png",    # create PNG for the heat map                
    width = 5*900,       # 5 x 900 pixels
    height = 5*900,      
    res = 300,            # 300 pixels per inch
    pointsize = 80)

ggplot(phages, aes(x = genome_size)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
               fill = "grey50", colour = "grey50",
               geom = "ribbon", position = "identity") +
  facet_grid(. ~ data_partition) +
  theme(panel.background = element_blank(),
        strip.text.x = element_text(size = 30,
                                    hjust = 0.5, vjust = 0.5),
        axis.title.x = element_text(color="black", size=30),
        axis.text.x = element_text(color="white"),
        axis.ticks.x = element_line(color="white"),
        axis.title.y = element_text(color="black", size=30),
        axis.text.y = element_text(color="black", size=20)) +
  xlab("genome size in [bp]") +
  coord_flip()

dev.off()





