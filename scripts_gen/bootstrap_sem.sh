#!/bin/bash
<<'END'
while getopts i: opt
do
    case "$opt" in
        i) input=$OPTARG;;
    esac
done
for c in 3 4 5 6
do
    echo `cat $input | gawk -F "\t" -v c=$c '{if ( $2 == $c ) { tp++} nn++}END{print tp/nn}' ` #>> $output
done


#<<'END'
for s in $(echo AA | gawk '{ for ( s = 1; s<=100; s++ ) { print s }}')
do
    rm -f $$.tmp

    cat $input | mkbset_long -seed $s -- | xC > $$.data
    for c in 3 4 5 6
    do
    echo $s `cat $$.data | gawk -F "\t" -v c=$c '{if ( $2 == $c ) { tp++} nn++}END{print tp/nn}' ` >> ${input}_bt.out
    done

 #   echo $s `cat $$.tmp | sort -nrk3 | head -1`
done
END
filename="gr1_ann_first_maj10_covThr_alpha_gn.tab.acc"
for c in 2 3 4 5
do
    read mean ssd sem <<<`awk -v c=$c '{sum += $c; sumsq += $c^2} END {
             print sum/NR, sqrt((sumsq-sum^2/NR)/(NR-1)), sqrt((sumsq-sum^2/NR)/(NR-1))/sqrt(NR)}' $filename`
    echo $mean $ssd $sem
done
