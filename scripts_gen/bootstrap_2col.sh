#!/bin/bash

# Author: Julia Villarroel

# Compare the prediction column 3 to the annotation column 2.
# Column 1 represents the ID

#while getopts i:r: opt
while getopts i: opt
do
    case "$opt" in
        i) input=$OPTARG;;
#	r) resampling==$OPTARG;;
    esac
done

echo `cat $input | gawk -F "\t" '{if ( $2 == $3 ) { tp++} nn++}END{print tp/nn}' ` #>> $output

rm -f ${input}_bt.out
#for s in $(echo AA | gawk -v rs=$resampling '{ for ( s = 1; s<=$rs; s++ ) { print s }}')
for s in $(echo AA | gawk '{ for ( s = 1; s<=1000; s++ ) { print s }}')
do

    cat $input | mkbset_long_x86_64 -seed $s -- | xC > $$.data
    echo $s `cat $$.data | gawk -F "\t" '{if ( $2 == $3 ) { tp++} nn++}END{print tp/nn}' ` >> ${input}_bt.out

 #   echo $s `cat $$.tmp | sort -nrk3 | head -1`
done
read mean ssd sem <<<`awk '{sum += $2; sumsq += $2^2} END {
         print sum/NR, sqrt((sumsq-sum^2/NR)/(NR-1)), sqrt((sumsq-sum^2/NR)/(NR-1))/sqrt(NR)}' ${input}_bt.out`
echo $mean $ssd $sem
