#!/usr/bin/env python

# Takes sorted result file with hosts, decision measure and alpha and returns accn\tpredicted_host
# input example:
# /tools/bin/python2.7 get_host_alpha.py -a 2.797 -f /panfs1/cge/people/juliavi/HostPhinder/results/100eval/NC_007058.fsa_pred_sorted
# /tools/bin/python2.7 get_host_alpha.py -a 2.797 -f /panfs1/cge/people/juliavi/HostPhinder/results/NC_023715.fsa_pred_sorted
# /tools/bin/python2.7 get_host_alpha.py -a 2.797 -f /panfs1/cge/people/juliavi/HostPhinder/results/2196_genera/NC_007817.fsa_pred_sorted

# Julia Villarroel
# last modified: 150219

import argparse
import sys
from compiler.ast import flatten
import os

parser= argparse.ArgumentParser(description='Get prediction and result from ALL table for best result.')

parser.add_argument('-f','--file', type=str, help="File that contains results \
with host SORTED by user decision")

parser.add_argument('-d','--decision', type=str, default='frac_d', 
help='Value which should be chosen to find majority host: Score, z, frac_q, frac_d or coverage')

# W/- Clust Species
parser.add_argument('-a','--alpha', type=float, default=2.004,
# W/- Clust Genus
#parser.add_argument('-a','--alpha', type=float, default=6.296,
# W/O Clust Species:
#parser.add_argument('-a','--alpha', type=float, default=4.346,
 help='alpha value; what is the real name?')

parser.add_argument('-c', '--clustering', choices=['TRUE', 'FALSE'],
 default='TRUE', help='performs homology clustering by default.\
 If set to FALSE it does not')

args = parser.parse_args()

get_col = {
	'Score' : 1,
	'z' : 3,
	'frac_q' : 5,
	'frac_d' : 6,
	'coverage' : 7
}

if not args.file:
	sys.stderr.write('WARNING: Please specify the sorted results file with hosts!\n')
	sys.exit(2)

#------------------------------------------------------------------------------
# Cluster similar phages
#------------------------------------------------------------------------------
#links = open('skipped2196_0.7.txt', 'r')
# on cge-s2:
links = open('/panfs1/cge/people/juliavi/PHAGES/data/skipped2196_0.7.txt',
 'r')

# Use the kept genome as key and append the skipped ones in the corresponding
# value list.
clusters={}

for line in links:
        line = line.split(' ')
        if line[10] in clusters:
                clusters[line[10]].append(line[3])
        else:
                clusters[line[10]] = [line[3]]

# Convert the dictionary into a list of lists
merged = [flatten(subtuple) for subtuple in clusters.items()]


#------------------------------------------------------------------------------
#	Read predictions
#------------------------------------------------------------------------------
accnname = args.file.split('/')[-1]#.strip('.fna_pred_sorted')
#if file is empty
if os.path.getsize(args.file) == 103 or os.path.getsize( args.file ) == 110: 
#103= lenght of the first line find_host.py outputfile; 110=length of the first line findtemplate.py outputfile.
	print accnname + '\t' + 'No_significant_match_found'
	#sys.stderr.write("No_significant_match_found\n")
	exit
else:
	# Save predictions into a list of lists
	pred = [pred.strip().split('\t') for pred in open(args.file) if not pred.startswith('Template')]
	#accnname = args.file.split('/')[-1].strip('.fsa_pred_sorted')

#------------------------------------------------------------------------------
#	frac threshold
#------------------------------------------------------------------------------
# First hit value
	first_value = float(pred[0][get_col[args.decision]])

# Remove hits that belong to the same clusters of higher hits
	if args.clustering == 'TRUE':
		groupset = set()	
		remove = []
		for sublist in pred:
			accn = sublist[0].strip(' ')
		# Save accn to remove because already in a group
			for group1 in groupset:
                        	if accn in group1:
                                	remove.append(accn)
                                	break
		# Save the represented groups into a set
			group = [group for group in merged if accn in group]
			groupset.add(tuple(flatten(group)))	
	# Consider only prediction for accn that are not in remove	
		pred = [hit for hit in pred if not hit[0].strip(' ') in remove]

	hosts = {}
	for hit in pred:
		hit[get_col[args.decision]] = (float(hit[get_col[args.decision]]) / first_value)**args.alpha
		if hit[-1] in hosts:
                        hosts[hit[-1]] += hit[get_col[args.decision]]
                else:
			hosts[hit[-1]] = hit[get_col[args.decision]]


	# Take host with highest value
	key,value = max(hosts.iteritems(), key=lambda x:x[1])
	#print hosts
	print '%s\t%s\t%s' % (accnname, key, value)
	#print key
