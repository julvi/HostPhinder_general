#!/bin/bash

# Author: Julia Villarroel

# Compare the prediction column 3 to the annotation column 2.
# Column 1 represents the ID

while getopts i: opt
do
    case "$opt" in
        i) input=$OPTARG;;
    esac
done

# Calculate accuracy rigth predictions / predictions
echo `cat $input | gawk -F "\t" '{if ( $2 == $3 ) { tp++} nn++}END{print tp/nn}' ` 

rm -f ${input}_bt.out

# Perform 1000 times resampling with replacement
for s in $(echo AA | gawk '{ for ( s = 1; s<=1000; s++ ) { print s }}')
do

    cat $input | mkbset_long_x86_64 -seed $s -- | xC > $$.data
    echo $s `cat $$.data | gawk -F "\t" '{if ( $2 == $3 ) { tp++} nn++}END{print tp/nn}' ` >> ${input}_bt.out

done

# Calculate mean, standard deviation and squared error mean
read mean ssd sem <<<`awk '{sum += $2; sumsq += $2^2} END {
         print sum/NR, sqrt((sumsq-sum^2/NR)/(NR-1)), sqrt((sumsq-sum^2/NR)/(NR-1))/sqrt(NR)}' ${input}_bt.out`
echo $mean $ssd $sem
