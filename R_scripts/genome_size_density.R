#dev.off()
rm(list=ls())
# Dataframe: each field is a data partition and each value is a genome size
setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/vulcano_charts")
#install.packages('reshape')
library(reshape)
library(ggplot2)

############### 16mers on 16mers based partitioning host&size sorted ##########
### GENUS
phages <- read.table("groups_sizes_gn.tab", sep="\t", 
                     header = T, as.is = T, fill = T)

png("part_size_distr_gnAA.png",    # create PNG for the heat map                
    width = 5*900,       # 5 x 900 pixels
    height = 5*900,      
    res = 300,            # 300 pixels per inch
    pointsize = 80)

### SPECIES
phages <- read.table("groups_sizes_sp.tab", sep="\t", 
                     header = T, as.is = T, fill = T)

png("part_size_distr_spAA.png",    # create PNG for the heat map                
    width = 5*900,       # 5 x 900 pixels
    height = 5*900,      
    res = 300,            # 300 pixels per inch
    pointsize = 80)

phages<-melt(phages)
colnames(phages)<-c("data_partition","genome_size")

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

####STOP!!!######

############### 16mers on 16mers based partitioning ###########################

if (FALSE) {
### SPECIES
phages <- read.table("16mers_16mers_host_sort/groups_sizes_sp.tab", sep="\t", 
                     header = T, as.is = T, fill = T)



### GENUS
phages <- read.table("16mers_16mers_host_sort/groups_sizes150528.tab", sep="\t", 
                     header = T, as.is = T, fill = T)

}
phages<-melt(phages)
colnames(phages)<-c("data_partition","genome_size")


p1<-
ggplot(phages, aes(x = genome_size)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
               fill = "grey50", colour = "grey50",
               geom = "ribbon", position = "identity") +
  facet_grid(. ~ data_partition) +
  theme(panel.background = element_blank(),
        axis.text.x = element_text(color="black", size=7),
        axis.ticks.x = element_line(color="white")) +
  xlab("genome size in [bp]") +
  coord_flip()
dev.off()
p1


###############################################################################
phages <- read.table("15mers_host_sort/genome_sizes_part.tab", sep="\t", 
                     header = T, as.is = T, fill = T)

#install.packages('reshape')
library(reshape)
phages<-melt(phages)
colnames(phages)<-c("data_partition","genome_size")

library(ggplot2)
p1<-ggplot(phages, aes(x = genome_size)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
               fill = "grey50", colour = "grey50",
               geom = "ribbon", position = "identity") +
  facet_grid(. ~ data_partition) +
  theme(panel.background = element_blank(),
        axis.text.x = element_text(color="white"),
        axis.ticks.x = element_line(color="white")) +
  xlab("genome size in [bp]") +
  coord_flip()
p1


phages <- read.table("15mers_host_sort/phage13_14genomeSizes.tab", sep="\t", 
                     header = T, as.is = T, fill = T)

#library(reshape)
phages<-melt(phages)

# Data description:
#str(phages)
#'data.frame':  4392 obs. of  2 variables:
#  $ variable: Factor w/ 2 levels "phage2013","phage2014": 1 1 1 1 1 1 1 1 1 1 ...
#$ value   : int  168903 37370 40739 43785 60942 61670 36717 39600 6087 7349 ...

colnames(phages)<-c("dataset","genome_size")

library(ggplot2)
p1<-ggplot(phages, aes(x = genome_size)) +
  stat_density(aes(ymax = ..density..,  ymin = -..density..),
               fill = "grey50", colour = "grey50",
               geom = "ribbon", position = "identity") +
  facet_grid(. ~ dataset) +
  theme(panel.background = element_blank(),
        axis.text.x = element_text(color="white"),
        axis.ticks.x = element_line(color="white")) +
  xlab("genome size in [bp]") +
  coord_flip()
p1
