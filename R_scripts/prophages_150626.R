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
lot <- lapply(c('eval_cov_bins_acc_all_sp.tab','eval_cov_bins_acc_all_gn.tab',
         'cov_bins_right_all_sp.tab', 'cov_bins_right_all_gn.tab'),myReadTable)



bnames <- c("0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8",
            "0.9")

mybarplot <-function(mytable, title, bnames){
  par(las=2) # --> make barplot write all labels
  myhist <- barplot(height=mytable$accuracy, axisnames=TRUE,
                    main = title,
                    ylab = 'Accuracy', 
                    xlab = 'Coverage ranges',
                    ylim=c(0,1), panel.first=grid(), 
                    names.arg = bnames,
                    # tango palette colours
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

#Define Margins. Give as much space possible on the left margin (second value)


pdf("eval_acc_bins_all.pdf", width=10, height=5)
par(mar=c(5, 5, 4, 5) + 0.1)
par(mfrow=c(1,2))
plot1 <- mybarplot(lot[[1]], expression('phages'[eval_species]), bnames)
plot2 <- mybarplot(lot[[2]], expression('phages'[eval_genus]), bnames)
dev.off()
pdf("proph_acc_bins_all.pdf", width=10, height = 5)
par(mar=c(5, 5, 4, 5) + 0.1)
par(mfrow=c(1,2))
plot3 <- mybarplot(lot[[3]], expression('prophages'[species]), bnames)
plot4 <- mybarplot(lot[[4]], expression('prophages'[genus]), bnames)
dev.off()




#####------------------------- POSTER figure ------------------------##########
if (FALSE) {
mybarplot_col <-function(mytable, title, bnames){
  par(las=2) # --> make barplot write all labels
  myhist <- barplot(height=mytable$accuracy, axisnames=TRUE,
                    main = title,
                    ylab = 'Accuracy', 
                    xlab = 'Coverage ranges',
                    ylim=c(0,1), panel.first=grid(), 
                    names.arg = bnames,
                    cex.axis=1.5, cex.names=1.5,
                    cex.lab=1.5,
                    col= c("#babdb6", "#8ae234", "#8ae234", "#8ae234",
                           "#8ae234", "#8ae234", "#8ae234", "#8ae234",
                           "#4e9a06", "#4e9a06"))
  par(las=0)
  par(new=T)
  plot(mytable$range, mytable$count, axes=F, ylim=c(0,max(mytable$count)), 
       ylab = "", xlab="",lty=2, lwd=2)
  axis(4, ylim=c(0,max(mytable$count)),lwd=1,line=1, cex.axis=1.5)
  lines(mytable$range, mytable$count,pch=20)
  mtext(4,text="Count",line=3.5, cex=1.5)
  
  return(myhist)
}
png("poster_acc_bins_all.png",
    width = 5*900,       # 5 x 900 pixels
    height = 5*900,      
    res = 250,            # 300 pixels per inch
    pointsize = 30)
par(mar=c(5, 5, 3, 7) + 0.1)
poster_plot <- mybarplot_col(lot[[2]], '', bnames)
dev.off()
}
