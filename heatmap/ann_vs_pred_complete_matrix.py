#!/usr/bin/env python

# ./ann_vs_pred_matrix.py -l heatmap_hosts_genus -t genus
#
# Import Modules
#
import argparse
import csv
import re

#
# Parse arguments
#
parser=argparse.ArgumentParser(description='create annotated vs predicted host')
parser.add_argument('-l', '--hostlist', type=str, help='SORTED list of hosts\
 file')
parser.add_argument('-t', '--taxonomy', type=str, choices=['species', 'genus'],
 help='taxonomy level')
args = parser.parse_args()

#
# Set variable values according to taxonomy
#
meta = ''
eval_accn_list = []
ann_vs_pred_file = ''
if args.taxonomy == 'species':
    meta='../meta_1871_species_150506.tab'
    eval_accn_list = [line.strip() for line in open('../../groups/group1_species.list')]
    ann_vs_pred_file = '../../evaluation/id_ann_pred_alpha_sp_gr1.tab'
    host_repr_file = 'species_repr_eval'
elif args.taxonomy == 'genus':
    meta='../meta_2196_genus_150506.tab'
    eval_accn_list = [line.strip() for line in open('../../groups/group1_genus.list')]
    ann_vs_pred_file = '../../evaluation/id_ann_pred_alpha_gn_gr1.tab'
    host_repr_file = 'genus_repr_eval'
#
# Read metadata into accn => annotated host
#
lol = list(csv.reader(open(meta, 'rt'), delimiter='\t'))
ann_hosts = {}
for l in range(len(lol)):
    ann_hosts[lol[l][0]] = lol[l][7] 


#
# Read prediction into accn => predicted host
#
lol_pred = list(csv.reader(open(ann_vs_pred_file, 'rt'), delimiter='\t'))
accn_vs_pred = {}
for l in range(len(lol_pred)):
    accn_vs_pred[lol_pred[l][0]] = lol_pred[l][2]

#
# Read host annotation frequency in eval into host => how many annotations
#
lol_ann_eval=list(csv.reader(open(host_repr_file, 'rt'), delimiter='\t'))
#print('\n'.join(map(str,lol_ann_eval)))
eval_ann_hosts = {}
for l in range(len(lol_ann_eval)):
    eval_ann_hosts[lol_ann_eval[l][1]] = lol_ann_eval[l][0]

#for key, value in eval_ann_hosts.iteritems():
 #   print key + " => " + value



#
# Create matrix 1 row per host and for columns as many 0 as the number of hosts
# 
hosts_list = [line.strip() for line in open(args.hostlist)]
hosts_list =  sorted(hosts_list)
hosts = dict((el, [0] * len(hosts_list)) for el in hosts_list)

for accn in eval_accn_list:
    # accn for which there's no prediction won't be present in the pred list
    try:
        hosts[ann_hosts[accn]][hosts_list.index(accn_vs_pred[accn])] += 1
    except KeyError:
        pass


# Devide host prediction occurancies by its annotation occurences
for key, value in hosts.items():
    den = float(1)
    try:
        den = float(eval_ann_hosts[key])
    except KeyError:
        pass
    value = [num / den for num in value]
    hosts[key] = value

#
# print the host_host_matrix
#
print '\n'.join(str(key + '\t' +'\t'.join(str(val) for val in value)) for key, value in sorted(hosts.items()))
