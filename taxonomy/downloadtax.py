#!/usr/bin/python

from ete2 import NCBITaxa 
#http://etetoolkit.org/docs/2.3/tutorial/tutorial_ncbitaxonomy.html
import argparse

parser = argparse.ArgumentParser(description='Download lineage of a given \
species or genus.')
parser.add_argument('-i', '--input', dest='host', type=str, 
		    help='species or genus')
args =  parser.parse_args()

host = args.host

ncbi = NCBITaxa()

name2taxid = ncbi.get_name_translator([host])

for key, value in name2taxid.iteritems():
    taxid = value[0]

lineage = ncbi.get_lineage(taxid)

rank = ncbi.get_rank(lineage)

#allowed_ranks = ['phylum', 'class', 'order', 'family', 'genus', 'species']
allowed_ranks = ['phylum', 'order', 'genus', 'species']

ranks = ["" for x in range(len(allowed_ranks))]

for key, value in rank.iteritems():
    if value in allowed_ranks:
        ranks[allowed_ranks.index(value)] = key
try:
    names = ncbi.get_taxid_translator(ranks)
    ranks = [names[taxid] for taxid in ranks]
    print '\t'.join(ranks)

except ValueError:
    print host + ' has problems##########################################'
