#!/bin/bash


# Compare the predictions of column 3 and 4 to the annotation, column 2.
# Find if there's sifnificant outperformance of one method over the other.

while getopts i: opt
do
    case "$opt" in
        i) input=$OPTARG;;
    esac
done


for c in 3 4
do

    echo `cat $input | gawk -F "\t" -v c=$c '{if ( $2 == $c ) { tp++} nn++}END{print tp/nn}' ` #>> $output
done

rm -f ${input}_bt.out
for s in $(echo AA | gawk '{ for ( s = 1; s<=1000; s++ ) { print s }}')
do
    rm -f $$.tmp
    cat $input | mkbset_long -seed $s -- | xC > $$.data
    for c in 3 4
    do
        echo `cat $$.data | gawk -F "\t" -v c=$c '{if ( $2 == $c ) { tp++} nn++}END{print tp/nn}' ` >> $$.tmp
    done
    echo $s `cat $$.tmp` >> ${input}_bt.out
 #   echo $s `cat $$.tmp | sort -nrk3 | head -1`
done
<<'END'
read mean ssd sem <<<`awk '{sum += $2; sumsq += $2^2} END {
         print sum/NR, sqrt((sumsq-sum^2/NR)/(NR-1)), sqrt((sumsq-sum^2/NR)/(NR-1))/sqrt(NR)}' ${input}_bt.out`
echo $mean $ssd $sem
END
