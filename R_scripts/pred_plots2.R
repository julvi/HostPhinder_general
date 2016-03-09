#clear the workspace
rm(list=ls())
#dev.off()

require(ggplot2)
#install.packages("gridExtra")
require(gridExtra)


setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pred_curves")

myReadTable<-function(file){
  # read table from file return it with column names
  x <- read.table(file, as.is=T, header=T) #[-1,] -> x
  
  return(x)
}

#-------------------- Criterion 3 CLUSTERING ---------------------------------#
myReadTable<-function(file){
  # read table from file return it with column names
  x <- read.table(file, as.is=T, header=T)
  colnames(x)[1] <- "value"
  # remove column containg ssd and sem
  x <- subset(x, , -c(ssd, sem))
  x$CImin <- NA
  x$CImax <- NA
  # Give as CImin of the value with the highest accuracy
  # x[x$mean == max(x$mean), ]$CImin
  # the min value at which the accuracy is 0.99 the highest accuracy 
  # min(x[x$mean >= max(x$mean)*0.99,1])
  x[x$mean == max(x$mean), ]$CImin <- min(x[x$mean >= max(x$mean)*0.99,1])
  # Give to the value with the highest accuracy
  # x[x$mean == max(x$mean), ]$CImax
  # the maxvalue at which the accuracy is 0.99 the highest accuracy as CImin
  # max(x[x$mean >= max(x$mean)*0.99,1])
  x[x$mean == max(x$mean), ]$CImax <- max(x[x$mean >= max(x$mean)*0.99,1])
  
  return(x)
}

lot_cr3_CLUST <- lapply(c('f_mean_ssd_sem_234gn_clust.tab',
                'f_mean_ssd_sem_235gn_clust.tab',
                'f_mean_ssd_sem_245gn_clust.tab',
                'f_mean_ssd_sem_345gn_clust.tab'), myReadTable)
lot_cr3_noCLUST <- lapply(c('f_mean_ssd_sem_234gn_no_clust.tab',
                'f_mean_ssd_sem_235gn_no_clust.tab',
                'f_mean_ssd_sem_245gn_no_clust.tab',
                'f_mean_ssd_sem_345gn_no_clust.tab'), myReadTable)

lot_cr3_CLUST_sp <- lapply(c('f_mean_ssd_sem_234sp_clust.tab',
                          'f_mean_ssd_sem_235sp_clust.tab',
                          'f_mean_ssd_sem_245sp_clust.tab',
                          'f_mean_ssd_sem_345sp_clust.tab'), myReadTable)
lot_cr3_noCLUST_sp <- lapply(c('f_mean_ssd_sem_234sp_no_clust.tab',
                            'f_mean_ssd_sem_235sp_no_clust.tab',
                            'f_mean_ssd_sem_245sp_no_clust.tab',
                            'f_mean_ssd_sem_345sp_no_clust.tab'), myReadTable)


myplot4<-function(mytable) { #, mytitle){
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
    # ggtitle(mytitle) +
    theme(axis.title.x = element_text(face="bold", size=12),
          axis.title.y = element_text(face="bold", size=12),
          axis.text.x  = element_text(face="bold", size=10),
          axis.text.y  = element_text(face="bold", vjust=0.5, size=10))
    
  return(plot1)
}

pl1 <- myplot4(lot_cr3_noCLUST_sp) #, "Species")
pl2 <- myplot4(lot_cr3_noCLUST) #, "Genus")

setwd("~/Desktop")
pdf("cr3_sp.pdf", width=10, height = 10)
pl1
dev.off()
pdf("cr3_gn.pdf", width=10, height = 10)
pl2
dev.off()

pdf("thr_no_clust.pdf", width=10, height = 5)
grid.arrange(pl1, pl2, nrow=1, ncol=2)
dev.off()

pl1 <- myplot4(lot_cr3_CLUST, "Genus w/- Clustering")
pl2 <- myplot4(lot_cr3_noCLUST, "Genus w/o Clustering")
pl3 <- myplot4(lot_cr3_CLUST_sp, "Species w/- Clustering")
pl4 <- myplot4(lot_cr3_noCLUST_sp, "Species w/o Clustering")


pdf("thr.pdf", width=10, height = 10)
grid.arrange(pl1, pl2, pl3, pl4, nrow=2, ncol=2)
dev.off()


myplot3<-function(mytable, colour){
  # take the first column name (f or alpha)
#  plot1 <- ggplot(NULL,aes(x=f, y=mean)) +
  plot1 <- ggplot(mytable, aes(f, mean)) +    
    geom_point(data = mytable, size = 14, color=colour) + # 234 => green
    geom_line(data = mytable, size = 7, color=colour) +
    scale_x_continuous(breaks=0:10*0.1) +
    xlab("value") +
    ylab("accuracy") +
    theme(axis.title.x = element_text(face="bold", size=20),
          axis.title.y = element_text(face="bold", size=20),
          axis.text.x  = element_text(face="bold", size=16),
          axis.text.y  = element_text(face="bold", vjust=0.5, size=16)) +
    geom_errorbarh(aes(xmax = CImax, xmin = CImin, height = .002), size = 3, color=colour)
  return(plot1)
}

myplot3(lot[[1]], "#73d216")

#-------------------- Criterion 4 CLUSTERING ---------------------------------#

myReadTable_alpha<-function(file){
  # read table from file return it with column names
  x <- read.table(file, as.is=T)
  colnames(x) <- c("value", "mean")
  
  x$CImin <- NA
  x$CImax <- NA
  # Give as CImin of the value with the highest accuracy
  # x[x$mean == max(x$mean), ]$CImin
  # the min value at which the accuracy is 0.99 the highest accuracy 
  # min(x[x$mean >= max(x$mean)*0.99,1])
  x[x$mean == max(x$mean), ]$CImin <- min(x[x$mean >= max(x$mean)*0.99,1])
  # Give to the value with the highest accuracy
  # x[x$mean == max(x$mean), ]$CImax
  # the maxvalue at which the accuracy is 0.99 the highest accuracy as CImin
  # max(x[x$mean >= max(x$mean)*0.99,1])
  x[x$mean == max(x$mean), ]$CImax <- max(x[x$mean >= max(x$mean)*0.99,1])
  
  return(x)
}

myplot5<-function(mytable) { #, mytitle){
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
  xlab(expression(alpha)) +
  ylab("accuracy mean") +
    #ggtitle(mytitle) + 
  theme(axis.title.x = element_text(face="bold", size=12),
        axis.title.y = element_text(face="bold", size=12),
        axis.text.x  = element_text(face="bold", size=10),
        axis.text.y  = element_text(face="bold", vjust=0.5, size=10))
  
  return(plot1)
}

lot_cr4_CLUST <- lapply(c('id_ann_preds_234gn_alpha_clust.tab_alpha_vs_accMean',
                          'id_ann_preds_235gn_alpha_clust.tab_alpha_vs_accMean',
                          'id_ann_preds_245gn_alpha_clust.tab_alpha_vs_accMean',
                          'id_ann_preds_345gn_alpha_clust.tab_alpha_vs_accMean'), myReadTable_alpha)
lot_cr4_noCLUST <- lapply(c('id_ann_preds_234gn_alpha_no_clust.tab_alpha_vs_accMean',
                            'id_ann_preds_235gn_alpha_no_clust.tab_alpha_vs_accMean',
                            'id_ann_preds_245gn_alpha_no_clust.tab_alpha_vs_accMean',
                            'id_ann_preds_345gn_alpha_no_clust.tab_alpha_vs_accMean'), myReadTable_alpha)

lot_cr4_CLUST_sp <- lapply(c('id_ann_preds_234sp_alpha_clust.tab_alpha_vs_accMean',
                             'id_ann_preds_235sp_alpha_clust.tab_alpha_vs_accMean',
                             'id_ann_preds_245sp_alpha_clust.tab_alpha_vs_accMean',
                             'id_ann_preds_345sp_alpha_clust.tab_alpha_vs_accMean'), myReadTable_alpha)
lot_cr4_noCLUST_sp <- lapply(c('id_ann_preds_234sp_alpha_no_clust.tab_alpha_vs_accMean',
                               'id_ann_preds_235sp_alpha_no_clust.tab_alpha_vs_accMean',
                               'id_ann_preds_245sp_alpha_no_clust.tab_alpha_vs_accMean',
                               'id_ann_preds_345sp_alpha_no_clust.tab_alpha_vs_accMean'), myReadTable_alpha)


pl1 <- myplot5(lot_cr4_noCLUST_sp) #, "Species")
pl2 <- myplot5(lot_cr4_noCLUST) #, "Genus")

setwd("~/Desktop")

pdf("cr4_sp.pdf", width=10, height = 10)
pl1
dev.off()


pdf("cr4_gn.pdf", width=10, height = 10)
pl2
dev.off()

pdf("alpha_no_clust.pdf", width=10, height = 5)
grid.arrange(pl1, pl2, nrow=1, ncol=2)
dev.off()

pl1 <- myplot5(lot_cr4_CLUST, "Genus w/- Clustering")
pl2 <- myplot5(lot_cr4_noCLUST, "Genus w/o Clustering")
pl3 <- myplot5(lot_cr4_CLUST_sp, "Species w/- Clustering")
pl4 <- myplot5(lot_cr4_noCLUST_sp, "Species w/o Clustering")

setwd("~/Desktop")
pdf("alpha.pdf", width=10, height = 10)
grid.arrange(pl1, pl2, pl3, pl4, nrow=2, ncol=2)
dev.off()

#-----------------------------------------------------------------------------#
#                     Combined Bootstrap                                      #
#-----------------------------------------------------------------------------#
# read all files into list of tables
if (FALSE) {
lot <- lapply(c('f_mean_ssd_sem_all_sp_no_clust.tab',
                'f_mean_ssd_sem_all_gn_no_clust.tab',
                'alpha_mean_ssd_sem_all_sp_no_clust.tab', 
                'alpha_mean_ssd_sem_all_gn_no_clust.tab'),myReadTable)

png("cov_f_alpha_no_clust.png",
    width = 5*500,        # for transpose matrix species
    #height = 5*900,       # for transpose matrix
    height = 5*500,
    res = 300,            # 300 pixels per inch
    pointsize = 20)

myplot<-function(mytable, mytitle, myylim, mybreaks, myxlab){
  # take the first column name (f or alpha)
  myx <- names(mytable)[1]
  x <- ggplot(mytable, aes_string(x= myx, y = "mean")) +
    geom_point(size = 2, color='black') +
    geom_errorbar(aes(ymax = mean+sem, ymin = mean-sem), color='black') +
    ggtitle(mytitle) +    
    coord_cartesian(ylim=myylim) +
    scale_x_continuous(breaks=mybreaks)  +
    xlab(myxlab) +
    ylab("accuracy")
  return(x)
}


plot1 <- myplot(lot[[1]], expression(paste('f x coverage'[1], " species")),
                c(0.754,0.778), 0:10*0.1, "f")

plot2 <- myplot(lot[[2]], expression(paste('f x coverage'[1], " genus")),
                c(0.789,0.822), 0:10*0.1, "f")

plot3 <- myplot(lot[[3]], expression(paste(alpha, " species")),
                c(0.729,0.78), 0:10, expression(alpha))

plot4 <- myplot(lot[[4]], expression(paste(alpha, " genus")),
                c(0.76,0.825), 0:10, expression(alpha))
#0:20*0.5
grid.arrange(plot1, plot2, plot3, plot4, nrow=2, ncol=2)

dev.off()
}




if (FALSE) {
###############################################################################
pred234 <- read.table('f_mean_ssd_sem_234gn_clust.tab', as.is=T, header=T)
pred235 <- read.table('f_mean_ssd_sem_235gn_clust.tab', as.is=T, header=T)
pred245 <- read.table('f_mean_ssd_sem_245gn_clust.tab', as.is=T, header=T)
pred345 <- read.table('f_mean_ssd_sem_345gn_clust.tab', as.is=T, header=T)
plot1 <- ggplot(NULL,aes(x=f, y=mean)) +
  geom_point(data = pred234, size = 4, color="#73d216") + # 234 => green
  geom_line(data = pred234, color="#73d216") +
  #geom_errorbar(data=pred234, aes(ymax = mean+sem, ymin = mean-sem), color='green') +
  geom_point(data =pred235, size = 4, color="#3465a4") + # 235 => blue
  geom_line(data = pred235, color="#3465a4") +
  #geom_errorbar(data=pred235, aes(ymax = mean+sem, ymin = mean-sem), color='blue') +
  geom_point(data =pred245, size = 4, color="#cc0000") + # 245 => red
  geom_line(data = pred245, color="#cc0000") +
  #geom_errorbar(data=pred245, aes(ymax = mean+sem, ymin = mean-sem), color='red') +
  geom_point(data =pred345, size = 4, color="#555753") + # 345 => black
  geom_line(data = pred345, color="#555753") +
  #geom_errorbar(data=pred345, aes(ymax = mean+sem, ymin = mean-sem), color='black') +
  scale_colour_hue(name="partitions",    # Legend label, use darker colors
                   labels=c("234", "235", "245", "345"),
                   l=40) +                    # Use darker colors, lightness=40
  ggtitle("genus clust") +
  #  expand_limits(y=0) +                        # Expand y range
  scale_x_continuous(breaks=0:10*0.1) +         # Set tick every 0.1
  theme_bw() +
  theme(legend.justification=c(1,0),
        legend.position=c(1,0))               # Position legend in bottom right

setwd("~/Desktop")

myplot2<-function(mytable, colour){
  # take the first column name (f or alpha)
  plot1 <- ggplot(NULL,aes(x=f, y=mean)) +
    geom_point(data = mytable, size = 14, color=colour) + # 234 => green
    geom_line(data = mytable, size = 7, color=colour) +
    scale_x_continuous(breaks=0:10*0.1) +
    xlab(expression(paste("parameter value (f or ", alpha, ")"))) +
    ylab("accuracy mean") +
    theme(axis.title.x = element_text(face="bold", size=50),
          axis.title.y = element_text(face="bold", size=50),
          axis.text.x  = element_text(face="bold", size=25),
          axis.text.y  = element_text(face="bold", vjust=0.5, size=25))
  return(plot1)
}



pdf("234.pdf", width=15, height = 10)
myplot2(pred234, "#73d216")
dev.off()

pdf("235.pdf", width=15, height = 10)
myplot2(pred235, "#3465a4")
dev.off()

pdf("245.pdf", width=15, height = 10)
myplot2(pred245, "#cc0000")
dev.off()

pdf("345.pdf", width=15, height = 10)
myplot2(pred345, "#555753")
dev.off()

pred234 <- read.table('f_mean_ssd_sem_234gn_no_clust.tab', as.is=T, header=T)
pred235 <- read.table('f_mean_ssd_sem_235gn_no_clust.tab', as.is=T, header=T)
pred245 <- read.table('f_mean_ssd_sem_245gn_no_clust.tab', as.is=T, header=T)
pred345 <- read.table('f_mean_ssd_sem_345gn_no_clust.tab', as.is=T, header=T)

plot2 <- ggplot(NULL,aes(x=f, y=mean)) +
  geom_point(data = pred234, size = 4, color='green') +
  geom_errorbar(data=pred234, aes(ymax = mean+sem, ymin = mean-sem), color='green') +
  geom_point(data =pred235, size = 4, color='blue') +
  geom_errorbar(data=pred235, aes(ymax = mean+sem, ymin = mean-sem), color='blue') +
  geom_point(data =pred245, size = 4, color='red') +
  geom_errorbar(data=pred245, aes(ymax = mean+sem, ymin = mean-sem), color='red') +
  geom_point(data =pred345, size = 4, color='black') +
  geom_errorbar(data=pred345, aes(ymax = mean+sem, ymin = mean-sem), color='black') +
  scale_colour_hue(name="partitions",    # Legend label, use darker colors
                   labels=c("234", "235", "245", "345"),
                   l=40) +                    # Use darker colors, lightness=40
  ggtitle("genus no clust") +
  #  expand_limits(y=0) +                        # Expand y range
  scale_x_continuous(breaks=0:10*0.1) +         # Set tick every 0.1
  theme_bw() +
  theme(legend.justification=c(1,0),
        legend.position=c(1,0))               # Position legend in bottom right

pred234 <- read.table('f_mean_ssd_sem_234sp_clust.tab', as.is=T, header=T)
pred235 <- read.table('f_mean_ssd_sem_235sp_clust.tab', as.is=T, header=T)
pred245 <- read.table('f_mean_ssd_sem_245sp_clust.tab', as.is=T, header=T)
pred345 <- read.table('f_mean_ssd_sem_345sp_clust.tab', as.is=T, header=T)
plot3 <- ggplot(NULL,aes(x=f, y=mean)) +
  geom_point(data = pred234, size = 4, color='green') +
  geom_errorbar(data=pred234, aes(ymax = mean+sem, ymin = mean-sem), color='green') +
  geom_point(data =pred235, size = 4, color='blue') +
  geom_errorbar(data=pred235, aes(ymax = mean+sem, ymin = mean-sem), color='blue') +
  geom_point(data =pred245, size = 4, color='red') +
  geom_errorbar(data=pred245, aes(ymax = mean+sem, ymin = mean-sem), color='red') +
  geom_point(data =pred345, size = 4, color='black') +
  geom_errorbar(data=pred345, aes(ymax = mean+sem, ymin = mean-sem), color='black') +
  scale_colour_hue(name="partitions",    # Legend label, use darker colors
                   labels=c("234", "235", "245", "345"),
                   l=40) +                    # Use darker colors, lightness=40
  ggtitle("species clust") +
  #  expand_limits(y=0) +                        # Expand y range
  scale_x_continuous(breaks=0:10*0.1) +         # Set tick every 0.1
  theme_bw() +
  theme(legend.justification=c(1,0),
        legend.position=c(1,0))               # Position legend in bottom right


pred234 <- read.table('f_mean_ssd_sem_234sp_no_clust.tab', as.is=T, header=T)
pred235 <- read.table('f_mean_ssd_sem_235sp_no_clust.tab', as.is=T, header=T)
pred245 <- read.table('f_mean_ssd_sem_245sp_no_clust.tab', as.is=T, header=T)
pred345 <- read.table('f_mean_ssd_sem_345sp_no_clust.tab', as.is=T, header=T)
plot4 <- ggplot(NULL,aes(x=f, y=mean)) +
  geom_point(data = pred234, size = 4, color='green') +
  geom_errorbar(data=pred234, aes(ymax = mean+sem, ymin = mean-sem), color='green') +
  geom_point(data =pred235, size = 4, color='blue') +
  geom_errorbar(data=pred235, aes(ymax = mean+sem, ymin = mean-sem), color='blue') +
  geom_point(data =pred245, size = 4, color='red') +
  geom_errorbar(data=pred245, aes(ymax = mean+sem, ymin = mean-sem), color='red') +
  geom_point(data =pred345, size = 4, color='black') +
  geom_errorbar(data=pred345, aes(ymax = mean+sem, ymin = mean-sem), color='black') +
  scale_colour_hue(name="partitions",    # Legend label, use darker colors
                   labels=c("234", "235", "245", "345"),
                   l=40) +                    # Use darker colors, lightness=40
  ggtitle("species no clust") +
  #  expand_limits(y=0) +                        # Expand y range
  scale_x_continuous(breaks=0:10*0.1) +         # Set tick every 0.1
  theme_bw() +
  theme(legend.justification=c(1,0),
        legend.position=c(1,0))               # Position legend in bottom right

grid.arrange(plot1, plot2, plot3, plot4, nrow=2, ncol=2)


#pred234 <- read.table('f_mean_min_max_234gn_clust.tab', as.is=T, header=T)
#pred235 <- read.table('f_mean_min_max_235gn_clust.tab', as.is=T, header=T)
#pred245 <- read.table('f_mean_min_max_245gn_clust.tab', as.is=T, header=T)
#pred345 <- read.table('f_mean_min_max_345gn_clust.tab', as.is=T, header=T)

}