require(ggplot2)

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
    ylab("Accuracy")
  return(x)
}

myReadTable<-function(file){
  # read table from file return it with column names
  x <- read.table(file, as.is=T, header=T) #[-1,] -> x
  
  return(x)
}