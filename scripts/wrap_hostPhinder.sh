#!/bin/bash

# Author: Julia Villarroel


evalue=0.05
#decision=frac_d
decision=coverage
outdir="HostPhinder/results"

while getopts e:i:o:d:b:t:k: opt
do
   case "$opt" in
      e) evalue=$OPTARG;;
      i) input=$OPTARG;;
      o) outdir=$OPTARG;; # output folder
      d) decision=$OPTARG;;
      b) database=$OPTARG;;  
      t) taxonomy=$OPTARG;;
      k) kmersize=$OPTARG;;
   esac
done

#create: and define hash to get column after which should be sorted
declare -A meas2col=(
    ["Score"]="2"
    ["z"]="4"
    ["frac_q"]="6"
    ["frac_d"]="7"
    ["coverage"]="8"
)

col_dec=${meas2col["$decision"]}

#mkdir -p $outdir
output_file="${outdir}_${kmersize}_${taxonomy}_alpha_${decision}_evalue$evalue"


if [ $taxonomy = species ]
then
    meta="meta_1871_species_150506.tab"    
elif [ $taxonomy = genus ]
then
    meta="meta_2196_genus_150506.tab"
fi
#------------------------ Find templates in database with match ---------------
# This perl oneliner takes the last two branches of a path
# (last branch and leaf)
#findtempl_out="${outdir%%/*}/$(echo $input |\
#findtempl_out="$outdir/$(echo $input |\
# perl -ne '/\/.*\/(.*)\/(.*)$/; print "$1_$2"')_${taxonomy}_pred_${kmersize}mers_evalue$evalue"
findtempl_out="$outdir/${input##*/}_${taxonomy}_pred_${kmersize}mers_evalue$evalue"

python HostPhinder/scripts/findtemplate_scipy.py -t $database -p -k $kmersize\
 -o $findtempl_out -i $input -e $evalue

# If a prediction has been made --> more than one line (header +..)
if [[ $(wc -l <$findtempl_out) -ge 2 ]]
then
#------------------------- Description --> Host column ------------------------
    predWhost=${findtempl_out}_host #new table with description column removed
					#and host column added
    IFS=$'\n'       # make newlines the only separator
    for line in $(cat $findtempl_out)
    do
        if [[ $line == Template* ]]; then
            continue
        fi
        template=`echo "$line" | awk -F "\t" '{print $1}' | perl -pe 's/\s+$//'`
        pred=`grep $template $meta | awk -F "\t" '{print $NF}'` 
        echo -e "$line$pred" >> $predWhost
    done

#------------------------------ Sort and get results --------------------------
# Sort according to the column the user chooses
    sort_output=${predWhost}_sorted
    sort -rgk $col_dec $predWhost > $sort_output
    rm $predWhost

#------------------------------ Alpha method (=6) ------------------------------
    alpha_out=`HostPhinder/scripts/get_host_alpha.py -f $sort_output \
-d coverage -a 6.0 -c FALSE | sed -n '1p'`
    echo $alpha_out >> $output_file

#rm $findtempl_out
<<'END'
#--------------------------------- First hit -----------------------------------
# Take the first hit
# Check if there is a predictions, i.e. there's more than one line
    pred=`cat $sort_output | sed -n '1p' | cut -f 11`
    value=`cat $sort_output | sed -n '1p' | cut -f $col_dec`
#    echo -e "$acc\t$pred\t$value" >>  $output_file
    echo -e "$input\t$pred\t$value" >>  $output_file
else
#    echo -e "$acc\tNo_significant_match_found" >> $output_file
    echo -e "$input\tNo_significant_match_found" >> $output_file
END
fi

