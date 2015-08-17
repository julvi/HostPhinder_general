#clear the workspace
rm(list=ls())
#dev.off()

require(ggplot2)
#install.packages("gridExtra")
require(gridExtra)


myReadTable<-function(file){
  # read table from file return it with column names
  read.table(file, as.is=T, header=T)[-1,] -> x
  
  return(x)
}

setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/plots_and_Rscripts/pred_curves")

# read all files into list of tables
lot <- lapply(c('f_mean_ssd_sem_all_sp_no_clust.tab','f_mean_ssd_sem_all_gn_no_clust.tab',
                'alpha_mean_ssd_sem_all_sp_no_clust.tab', 'alpha_mean_ssd_sem_all_gn_no_clust.tab'),myReadTable)

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





if (FALSE) {
###############################################################################
pred234 <- read.table('f_mean_ssd_sem_234gn_clust.tab', as.is=T, header=T)
pred235 <- read.table('f_mean_ssd_sem_235gn_clust.tab', as.is=T, header=T)
pred245 <- read.table('f_mean_ssd_sem_245gn_clust.tab', as.is=T, header=T)
pred345 <- read.table('f_mean_ssd_sem_345gn_clust.tab', as.is=T, header=T)
plot1 <- ggplot(NULL,aes(x=f, y=mean)) +
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
  ggtitle("genus clust") +
  #  expand_limits(y=0) +                        # Expand y range
  scale_x_continuous(breaks=0:10*0.1) +         # Set tick every 0.1
  theme_bw() +
  theme(legend.justification=c(1,0),
        legend.position=c(1,0))               # Position legend in bottom right


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