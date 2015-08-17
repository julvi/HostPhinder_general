# ggplot object
#http://docs.ggplot2.org/0.9.2.1/guides.html

setwd("/Users/juliavi/GoogleDrive/PhD/HostPhinder_general")
sp_accuracy <- read.table("meas_sp_accur_noMatch.tab", header=TRUE)#, row.names = 1)
sp_accuracy <- sp_accuracy[order(-sp_accuracy$accuracy),]

#sp_accuracy <- as.data.frame(accuracy)

gn_accuracy <- read.table("meas_gn_accur_noMatch.tab", header=TRUE)#, row.names = 1)
gn_accuracy <- gn_accuracy[order(-gn_accuracy$accuracy),]


sp_accuracy_16mers <- read.table("meas_sp_accur_noMatch_16mers.tab", header=TRUE)#, row.names = 1)
sp_accuracy_16mers <- sp_accuracy_16mers[order(-sp_accuracy_16mers$accuracy),]


gn_accuracy_16mers <- read.table("meas_gn_accur_noMatch_16mers.tab", header=TRUE)#, row.names = 1)
gn_accuracy_16mers <- gn_accuracy_16mers[order(-gn_accuracy_16mers$accuracy),]

accuracy <- c(sp_accuracy$accuracy, sp_accuracy_16mers$accuracy)
matchWOpred <- c(sp_accuracy$matchWOpred, sp_accuracy_16mers$matchWOpred)
measure <- c(sp_accuracy$measure, sp_accuracy_16mers$measure)
####
x <- accuracy #accuracy$accuracy
y <- matchWOpred #accuracy$matchWOpred
a <- measure #accuracy$measure

library(ggplot2)
p <- ggplot(accuracy, aes(x, y, colour = a)) + geom_point()

p
###

kmersize = factor(rep(c(12,14,15,16,17,18,20,30,50), each = 25))
prefix = factor(rep(c("A", "T", "G", "C", "step2"), each = 5, times = 9))
measure = factor(rep(c("score", "z-score", "frac_q", "frac_d", "coverage"),
                     times = 45))
df <- data.frame(kmersize, prefix, measure)

?ggplot