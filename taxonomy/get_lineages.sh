#!/bin/bash

while getopts i: opt
do
    case "$opt" in
        i) infile=$OPTARG;;
    esac
done

while read host; do
    ./downloadtax.py -i "$host"
done < $infile
