#!/bin/bash

while getopts i: opt
do
    case "$opt" in
        i) input=$OPTARG;;
    esac
done

colnum=`awk -F '\t' '{print NF}' $input | sort -nu | tail -n 1`


echo 'Genome_len_percent Accuracy' > ${input}_acc

for c in `seq 3 1 $colnum`
do
    p=$((($c - 2) * 10))
    echo $p `cat $input | gawk -F "\t" -v c=$c '{if ( $2 == $c ) { tp++} nn++}END{print tp/nn}' ` >> ${input}_acc
done


rm -f *.tmp

for s in $(echo AA | gawk '{ for ( s = 1; s<=1000; s++ ) { print s }}')
do
    cat $input | mkbset_long_x86_64 -seed $s -- | xC > $$.data

    for c in `seq 3 1 $colnum`
    do
        p=$((($c - 2) * 10))
        echo $p `cat $$.data | gawk -F "\t" -v c=$c '{if ( $2 == $c ) { tp++} nn++}END{print tp/nn}' ` >> $p.tmp
    done
    

done

# Make table NB! THIS WILL WORK IF *tmp FILES ARE PROPERLY ORDERED BY ls
paste *tmp | awk '{ for (i=1;i<=NF;i+=2) $i="" }1' | \
perl -p -e 's/^ //' > ${input}_bt_acc
#sed -i '1i10 20 30 40 50 60 70 80 90' ${input}_bt_acc 

colnum2=`awk '{print NF}' ${input}_bt_acc | sort -nu | tail -n 1`

# Keep mean ssd sem colnames as they'll be used for graph on R
echo 'Genome_len_percent mean ssd sem' > ${input}_mean_ssd_sem

for c in `seq 1 1 $colnum2`
do
    p=$(($c * 10))
    read mean ssd sem <<<`awk -v c=$c '{sum += $c; sumsq += $c^2} END {
             print sum/NR, sqrt((sumsq-sum^2/NR)/(NR-1)), sqrt((sumsq-sum^2/NR)/(NR-1))/sqrt(NR)}' ${input}_bt_acc`
    echo $p $mean $ssd $sem >> ${input}_mean_ssd_sem
done
