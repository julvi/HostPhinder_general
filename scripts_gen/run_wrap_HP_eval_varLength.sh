#!/bin/bash

# Run from PHAGES/HP_general
# input example:
#./run_wrap_HP_eval_varLength.sh -t species -o HostPhinder/results/traintest

evalue=0.05
kmersize=16
#Process the arguments
while getopts t:o:p: opt
do
   case "$opt" in
      t) taxonomy=$OPTARG;;
      o) outdir=$OPTARG;;
      p) percent=$OPTARG;;
   esac
done



#"${gr2db[@]}" expands the values, "${!gr2db[@]}" (notice the !) expands the keys

database="train_databases/train2345_$taxonomy.list_step1_kmer16_thres1.0_db"
mkdir -p $outdir

INPUT="../ALL_140821"

fasta_out="eval_percentages/$percent"

for f in $(cat groups/group1_$taxonomy.list) 
do
    [ -f $fasta_out/$percent.$f.fsa ] \
      && echo "$fasta_out/$percent.$f.fsa exist" \
      || scripts_gen/takeFastaPercent.sh -p $percent \
      -f $INPUT/$f/$f.fsa > $fasta_out/$percent.$f.fsa

    HostPhinder/scripts/wrap_hostPhinder_new.sh -e $evalue \
      -i $fasta_out/$percent.$f.fsa -b $database -t $taxonomy -o $outdir \
      -k $kmersize
done
