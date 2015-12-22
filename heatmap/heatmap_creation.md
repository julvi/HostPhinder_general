#Host representation in eval test
grep -wf ../groups/group1_species.list ../meta_1871_species_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq -c > species_repr_eval
grep -wf ../groups/group1_genus.list ../meta_2196_genus_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq -c > genus_repr_eval

#Host representation in train_test set
grep -wf ../train_databases/train2345_species.list ../meta_1871_species_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq -c > species_repr_train_test
grep -wf ../train_databases/train2345_genus.list ../meta_2196_genus_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq -c > genus_repr_train_test

# Modify the files by alligning to the left and converting the first space to tab on VI:
:%le 	# left alignment --> remove leading space (the % indicates that should apply to all lines)
:%s/\s/\t/ 	# convert first space into tab

#If the prediction is not equal to annotation add predicted and annotated host into final heatmap host
awk -F '\t' '{if($2!=$3)print $0}' id_ann_pred_alpha_gn_gr1.tab | awk -F '\t'  '{ for (i=2; i<=3; i++) print $i }' | sort | uniq > heatmap_hosts_genus #→ 54
awk -F '\t' '{if($2!=$3)print $0}' id_ann_pred_alpha_sp_gr1.tab | awk -F '\t' '{ for (i=2; i<=3; i++) print $i }' | sort | uniq > heatmap_hosts_species #→ 81

# FOR COMPLETE HEATMAP
awk -F '\t'  '{ for (i=2; i<=3; i++) print $i }' id_ann_pred_alpha_gn_gr1.tab | sort | uniq > heatmap_complete_hosts_genus #-> 73
awk -F '\t' '{ for (i=2; i<=3; i++) print $i }' id_ann_pred_alpha_sp_gr1.tab | sort | uniq > heatmap_complete_hosts_species # ->105

#Check which host have not been predicted
awk -F '\t' '{print $1}' id_ann_pred_alpha_gn_gr1.tab > accn_pred_gn_eval.list
awk -F '\t' '{print $1}' id_ann_pred_alpha_sp_gr1.tab > accn_pred_sp_eval.list

comm -23 group1_species.list accn_pred_sp_eval.list | grep -f - meta_1871_species_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq | comm -13 heatmap_hosts_species - | cat - heatmap_hosts_species > tmp; mv tmp heatmap_hosts_species → 87

# For complete heatmap
comm -23 ../groups/group1_species.list accn_pred_sp_eval.list | grep -f - ../meta_1871_species_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq | comm -13 heatmap_complete_hosts_species - | cat - heatmap_complete_hosts_species > tmp; mv tmp heatmap_complete_hosts_species # -> 109


#comm -23 outputs the entries unique to group1_species.list (i.e. the non predicted ones)
#grep -f - meta… greps piped patterns (-f option tells to grep from file and - specifies the standard output, i.e. pipe)
#awk -F '\t' '{print $NF}' prints the annotated host associated with that accn
#sort | comm -13 heatmap_hosts_species - sorts the output and pipe it to the comm cmd which prints those not already present among the hosts
#cat - heatmap_hosts_species > tmp; mv tmp heatmap_hosts_species concatenates the resulting species (non predicted ones) to heatmap_species

comm -23 group1_genus.list accn_pred_gn_eval.list | grep -f - meta_2196_genus_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq | comm -13 heatmap_hosts_genus - | cat - heatmap_hosts_genus > tmp; mv tmp heatmap_hosts_genus #→ 58

# For complete heatmap
comm -23 ../groups/group1_genus.list accn_pred_gn_eval.list | grep -f - ../meta_2196_genus_150506.tab | awk -F '\t' '{print $NF}' | sort | uniq | comm -13 heatmap_complete_hosts_genus - | cat - heatmap_complete_hosts_genus > tmp; mv tmp heatmap_complete_hosts_genus #→ 76

./ann_vs_pred_matrix.py -l heatmap_hosts_genus -t genus > ann_vs_pred_58gn_150630.tab
./ann_vs_pred_matrix.py -l heatmap_hosts_species -t species > ann_vs_pred_87sp_150630.tab

# For complete heatmap
./ann_vs_pred_matrix.py -l heatmap_complete_hosts_genus -t genus > ann_vs_pred_compl_76gn_151222.tab
./ann_vs_pred_matrix.py -l heatmap_complete_hosts_species -t species > ann_vs_pred_compl_109sp_151222.tab


