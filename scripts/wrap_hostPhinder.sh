#!/bin/bash

# ./wrap_hostPhinder.sh -i /panfs1/cge/people/juliavi/PHAGES/prophages/prophage_fnas/Acinetobacter_baumannii_BJAB0715_uid210972/NC_021734_1/prophage.1.fna -b ../database/2196accn_genus.list_step2_kmer15_thres0.7_db -t genus

# Julia Villarroel 141005
# Last modified 150316

#default arguments
evalue=0.05
decision=frac_d
output="results"
#create: and define hash to get column after which should be sorted
hash_get() {
    local _table="$1";
    local _key="$2";
    local _value="${_table}[@]";
    local "${!_value}";
    eval echo "\$${_key}";
}

columns=(
	Score=2
	z=4
	frac_q=6
	frac_d=7
	coverage=8
)


#Process the arguments
while getopts e:i:o:d:b:t: opt
do
   case "$opt" in
      e) evalue=$OPTARG;;
      i) input=$OPTARG;;
      o) output=$OPTARG;; # output folder
      d) decision=$OPTARG;;
      b) database=$OPTARG;;	
      t) taxonomy=$OPTARG;;
   esac
done

col_dec=`hash_get "columns" "$decision"`
valdir="$output/summ"
mkdir -p $valdir
# cge-s2:
#work_dir='/panfs1/cge/people/juliavi/HostPhinder'

#------------------------ Find templates in database with match ---------------
#output_1="$output/${input##*/}""_pred"
# This perl oneliner takes the last two branches of a path
# (last branch and leaf)
output_1="$output/$(echo $input | perl -ne '/\/.*\/(.*)\/(.*)$/; print "$1_$2"')_${taxonomy}_pred"

python2.7 scripts/findtemplate_scipy.py -t $database -p -k 15 -o $output_1 -i $input -e $evalue
# cge-s2:
#/tools/opt/anaconda/bin/python $work_dir/scripts/findtemplate_scipy.py -t $database -p -k 15 -o $output_1 -i $input -e $evalue


#----------------- Add host column, remove Description column -----------------
scripts/find_host.py -f $output_1 -t $taxonomy
# cge-s2
#/tools/bin/python2.7 $work_dir/scripts/find_host.py -f $output_1 -t $taxonomy

output_2=$output_1.new #new table with description column removed but host column added
rm $output_1


#------------------------------ Sort and get results --------------------------
# Sort according to the column the user chooses
sort_output=${output_2%.*}_sorted
sort -rgk $col_dec $output_2 > $sort_output
rm $output_2

#------------------------ SPECIES --> Alpha 2.004 ------------------------------
if [ $taxonomy = species ]
	then
		#mkdir -p ${output}_sp_alpha
		scripts/get_host_alpha.py -a 2.004 -f $sort_output >> $valdir/sp_alpha_values #${output}_sp_alpha/values
		# cge-s2
#		/tools/bin/python2.7 $work_dir/scripts/get_host_alpha.py -a 2.004 -f $sort_output >> ${output}_sp_alpha/values
fi

#------------------------ GENUS --> First hit ----------------------------------
# Take the first hit
if [ $taxonomy = genus ]
	then
		#mkdir -p ${output}_first
		acc="$(echo $sort_output | perl -ne '/\/?.*\/(.*)$/; print "$1"')"
                # Check if there is a predictions, i.e. there's more than one line
		if [[ $(wc -l $sort_output | awk '{print $1}') -ge 2 ]]
		then
		   pred=`grep -v Template $sort_output | sed -n '1p' | awk '{print $11}'`
		   value=`grep -v Template $sort_output | sed -n '1p' | awk '{print $7}'`
		   echo -e "$acc\t$pred\t$value" >> $valdir/gn_first_values #${output}_first/values
		else
		   echo -e "$acc\tNo_significant_match_found" >> $output/gn_first_values #${output}_first/values

		fi
fi
