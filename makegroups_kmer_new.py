#!/usr/bin/env python

#python makegroups_kmer.py -f skipped2196_0.7.txt

import argparse
from compiler.ast import flatten
import itertools as it
import csv
import operator
import numpy

#------------------------- Handle options -------------------------------------
parser= argparse.ArgumentParser(description='Make 5 partitions with equally\
 represented host in each group')

parser.add_argument('-f','--file', type=str, help="File with list of\
 # Skipping entry: JQ740813 in databade due to similarity to JQ740789 frac_q:\
 0.830360153645")

args = parser.parse_args()

if not args.file:
        sys.stderr.write('WARNING: Please specify file (-f option)!\n')
        sys.exit(2)

#------------------------------------------------------------------------------
links = open(args.file, 'r')
# Use the kept genome as key and append the skipped ones in the corresponding
# value list.
clusters={}
for line in links:
	line = line.split(' ')
	if line[10] in clusters:
		clusters[line[10]].append(line[3])
	else:
		clusters[line[10]] = [line[3]]

###############################################################################
# Print value <- key (supplementary material)
###############################################################################
#for key, value in clusters.iteritems():
 #   print "%s\t%s" % (key, key)
  #  for item in value:
   #     print "%s\t%s" % (item, key)
###############################################################################


# Convert the dictionary into a list of lists
merged = [flatten(subtuple) for subtuple in clusters.items()]
#print('\n'.join(map(str,merged)))
groupsizes = []
for group in merged:
	groupsizes.append(len(group))

#print len(merged)
#  15mers: 292 clusters for 2196 phages
# 16mers:293 clusters

# Use relative paths
meta_gn = open('meta_2196_genus_150506.tab', 'r')
meta_sp = open('meta_1871_species_150506.tab', 'r')

# Read metadata into accn => [host, size] dictionary giving priority to species
# info
hosts = {}
for phage in meta_gn.readlines():
	phage = phage.strip().split('\t')
	hosts[phage[0]]=[phage[7], phage[2]]
for phage in meta_sp.readlines():
	phage = phage.strip().split('\t')
        hosts[phage[0]]=[phage[7], phage[2]]

meta_gn.close()
meta_sp.close()
#for key, value in hosts.iteritems():
#	print key + ' => ' + value

#-----------------------------------------------------------------------------
# Make groups
#-----------------------------------------------------------------------------
# list of accession numbers inside groups
flattenmerged = [item for sublist in merged for item in sublist]
#print len(flattenmerged) #1080 --> 1153

#This could be changed to option
allphages = open('accnwhost2196.list', 'r')

# list of accession numbers that do not form groups
single_seq = [phage.strip() for phage in allphages 
              if not phage.strip() in flattenmerged]

for idx in range(len(single_seq)):
    groupsizes.append(1)
print sorted(groupsizes)
######## Supplementary material seq <- group member ###########################
#for seq in single_seq:
 #   print "%s\t%s" % (seq, seq)
###############################################################################
#print sum(groupsizes)/float(len(groupsizes))
# 1.55304101839 mean size for 16mers groups

#print numpy.median(numpy.array(groupsizes))
#print len(single_seq) # 1116 for 2196 phages 
# 1121 16mers
# --> 1122
# 1121 (2274)

# Create dictionary accn --> [host, size] for accn in seeds
unique_seq = {}
for key in clusters:
	unique_seq[key] = hosts[key]
for item in single_seq:
	unique_seq[item] = hosts[item]

#print len(unique_seq)
# 1414 seeds for 16mers
"""
#for key, value in unique_seq.iteritems():
#	print key + '=>' + ' '.join(value)


# Sort unique sequence according to host alphabetically
#sorted_hosts = sorted(unique_seq.iteritems(), key=operator.itemgetter(1))	
sorted_host_size = sorted(unique_seq, key=lambda x: (unique_seq[x][0],
 float(unique_seq[x][1])))
#print sorted_host_size
#for accn in sorted_host_size:
#    print accn + '=>' + ' '.join(unique_seq[accn])

#print len(sorted_host_size) 
# 1414 (1121 single + 293 clusters) 16mers 2196 
# --> 1432 (1122 single + 310 clusters) 2275
# 1431 (1121 single + clusters) 2274

group1, group2, group3, group4, group5 = ([] for i in range(5))

# Append sorted unique sequences to 5 groups alternatively
while len(sorted_host_size) > 0:
	try:
		group1.append(sorted_host_size.pop())
		group2.append(sorted_host_size.pop())
		group3.append(sorted_host_size.pop())
		group4.append(sorted_host_size.pop())
		group5.append(sorted_host_size.pop())
	except IndexError:
		pass


# Check that host are equally represented in each group

def list_grouphosts(group):
	"""""" Return a set of host in the given group""""""
	unique_host = set()
	for each in group:
		unique_host.add(each[1])
	unique_host = sorted(unique_host)
	return unique_host
""""""
print('\n'.join(map(str, list_grouphosts(group1))))
print ''
print('\n'.join(map(str, list_grouphosts(group2))))
print ''
print('\n'.join(map(str, list_grouphosts(group3))))
print ''
print('\n'.join(map(str, list_grouphosts(group4))))
print ''
print('\n'.join(map(str, list_grouphosts(group5))))
print ''
""""""

# Add homologues
def add_homologues(group):
	final_group = []
	for accn in group:
#		accn = couple[0]
            final_group.append(accn)
	    if accn in clusters:
		final_group.extend(clusters[accn])
	return final_group

group1 = add_homologues(group1)
group2 = add_homologues(group2)
group3 = add_homologues(group3)
group4 = add_homologues(group4)
group5 = add_homologues(group5)

# Print lists to files
g1=open('group1_genus.list', 'w')
g2=open('group2_genus.list', 'w')
g3=open('group3_genus.list', 'w')
g4=open('group4_genus.list', 'w')
g5=open('group5_genus.list', 'w')

g1.write('\n'.join(accn for accn in group1)) 
g2.write('\n'.join(accn for accn in group2))
g3.write('\n'.join(accn for accn in group3))
g4.write('\n'.join(accn for accn in group4))
g5.write('\n'.join(accn for accn in group5))

g1.close()
g2.close()
g3.close()
g4.close()
g5.close()
"""
