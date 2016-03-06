#!/bin/bash

# Author: Julia Villarroel
# Print a percentage (p) of a fasta file (f)

while getopts p:f: opt
do 
    case "$opt" in
        p) percent=$OPTARG;;
        f) file=$OPTARG;; # fasta file
    esac
done


echo `head -1 $file`

length=`awk '/^>/ { seqlen=0;next; } { seqlen = seqlen +length($0)}END{print seqlen}' $file`

# Rounded percentage 
rounded=`awk -v per="$percent" -v len="$length" 'BEGIN{printf "%.0f", len/100 * per }'`

awk '/^>/ {next; } { printf("%s",$0);}  END {printf("\n");}' $file | colrm $((rounded+1))
