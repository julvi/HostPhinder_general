###############################################################################
# HostPhinder accuracy on percentages of genome length
###############################################################################
setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/HP_on_percentages")
source("/Users/juliavi/HostPhinder/R_scripts/plot_table_funn_mean_ssd_sem.R")

lot <- lapply(c('id_ann_pred_from10to100_species.tsv_mean_ssd_sem',
                'id_ann_pred_from10to100_genus.tsv_mean_ssd_sem'),
              myReadTable)


myplot(lot[[1]], 
       expression('Accuracy vs Genome Length Percent, Phages'[eval_species]),
       c(0.82,0.84), 1:9*10, "Genome Length (% of total length)")

myplot(lot[[2]], 
       expression('Accuracy vs Genome Length Percent, Phages'[eval_genus]),
       c(0.88,0.895), 1:9*10, "Genome Length (% of total length)")


#myplot(lot2[[1]], 
 #      expression('Accuracy vs Genome Length Percent, Phages'[eval_species]),
  #     c(0.73,0.83), 1:9*10, "Genome Length (% of total length)")

#myplot(lot2[[2]], 
 #      expression('Accuracy vs Genome Length Percent, Phages'[eval_genus]),
  #     c(0.81,0.89), 1:9*10, "Genome Length (% of total length)")
###############################################################################

#clear the workspace
rm(list=ls())
setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general/HP_on_percentages")
source("/Users/juliavi/HostPhinder/R_scripts/plot_table_funn_mean_ssd_sem.R")

# read all files into list of tables
lot <- lapply(c('length_acc_nr_species','length_acc_nr_genus'),
              myReadTable)


mybarplot <-function(mytable, graphtitle) {
  par(las=2) # --> make barplot write all labels
  myhist <- barplot(height=mytable$accuracy, axisnames=TRUE,
                    ylab = 'Accuracy', 
                    xlab = 'Genome lenght (%)',
                    main = graphtitle,
                    ylim=c(0,1), panel.first=grid(),
                    names.arg=mytable$Genome_length, las=1)
  
  par(las=0)
  par(new=T)
  plot(mytable$Genome_length, mytable$predictions, axes=F, ylim=c(0,100), 
       ylab = "", xlab="",lty=2, lwd=2)
  axis(4, ylim=c(0,100),lwd=1,line=1, las=1)
  lines(mytable$range, mytable$count,pch=20)
  mtext(4,text="Predictions (%)",line=3.5, cex=1)
  
  return(myhist)
}


setwd("~/Desktop")

par(mar=c(5, 5, 3, 7) + 0.1)
#par(mfrow=c(1,2))
par(mfrow=c(1,1))
#pdf("hist_eval_sp.pdf", width=7, height = 10)
plot1 <- mybarplot(lot[[1]], 
                   expression('Accuracy and % of Predictions, Phages'[eval_species]))
#dev.off()


#pdf("hist_eval_gn.pdf", width=10, height = 10)
plot2 <- mybarplot(lot[[2]], 
                   expression('Accuracy and % of Predictions, Phages'[eval_genus])) 
#dev.off()
