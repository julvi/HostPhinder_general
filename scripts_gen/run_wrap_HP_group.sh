#!/bin/bash

# Run from PHAGE
# input example:
#./run_wrap_HP_group.sh -g group2 -t species -o HostPhinder/results/traintest

evalue=0.05
kmersize=16
#Process the arguments
while getopts e:g:b:t:o:k: opt
do
   case "$opt" in
      e) evalue=$OPTARG;;
      g) group=$OPTARG;;	
      b) database=$OPTARG;;
      t) taxonomy=$OPTARG;;
      o) outdir=$OPTARG;;
      k) kmersize=$OPTARG;;
   esac
done


#declare an associative array
declare -A gr2db=(
    ["group1"]="train2345"
    ["group2"]="train345" 
    ["group3"]="train245"
    ["group4"]="train235"
    ["group5"]="train234"
)

#"${gr2db[@]}" expands the values, "${!gr2db[@]}" (notice the !) expands the keys

database="PHAGES/HostPhinder/database/${gr2db["$group"]}_$taxonomy.list_step1_kmer16_thres1.0_db"
mkdir -p $outdir

INPUT="ALL_140821"


for f in $(cat groups/${group}_$taxonomy.list); do
	HostPhinder/scripts/wrap_hostPhinder_new.sh -e $evalue -i $INPUT/$f/$f.fsa -b $database -t $taxonomy -o $outdir -k $kmersize
    exit 0
done
