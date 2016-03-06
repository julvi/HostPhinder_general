# bootstrap_2col.sh #
Take a 3 tab separated column file as input. It outputs the mean,ssd,sem 
of the accuracy after bootstrap 1000x
The input columns are fastaID, annotation, prediction.

# takeFastaPercent.sh #
Take a percentage (-p <90|30|..>) and a fasta filename containing ONLY ONE ENTRY
It outputs the header and the sequence as a single string having the percentage
of the total length as specified in the -p option
