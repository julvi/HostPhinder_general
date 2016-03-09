NR == 1 {
        for (i = 1; i <= NF; i++) headers[i] = $i;
        next
}

{
        # find maximum value
        max = $2
        for (i = 3; i <= NF; i += 1) if ($i > max) max = $i;
        # print row id
        printf "%s", $1
        # print all column headers of the max value columns
        sep = OFS
        for (i = 2; i <= NF; i += 1) {
                if ($i == max) {
                        printf "%s%s", sep, headers[i];
                        sep = ","
                }
        }
        printf "\n"
}

# call it:
#awk -f best_perf.awk id_ann_preds_gn.tab.acc 
