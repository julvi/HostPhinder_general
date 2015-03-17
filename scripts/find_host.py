#!/usr/bin/python

import argparse
import re
import sys
import csv

parser= argparse.ArgumentParser(description='Get host for matches from ALL table.')

parser.add_argument('--file','-f', type=str, help='Results file from findtemplate.py')
parser.add_argument('--taxonomy','-t', type=str, choices=['species', 'genus'],
default='species', help='which taxonomic level you want to question')

args = parser.parse_args()

if not args.file:
	sys.stderr.write("Please specify file. For more information use -h\n")
	sys.exit(1)


meta = ''
if args.taxonomy == 'species':
  meta='meta_1871_species.tab'
  # on cge-s2	
  #meta='/panfs1/cge/people/juliavi/PHAGES/data/meta_1871_species.tab'
elif args.taxonomy == 'genus':
  meta='meta_2196_141211.tab'
  # on cge-s2
  #meta='/panfs1/cge/people/juliavi/PHAGES/data/meta_2196_141211.tab'
lol = list(csv.reader(open(meta, 'rt'), delimiter=' '))
ann_hosts = {}

for l in range(len(lol)):
	if args.taxonomy == 'species':
	        host = lol[l][7].split('; ')[0]
        	host = re.sub(' ', '_', host)
	        ann_hosts[lol[l][0]] = host
	elif args.taxonomy == 'genus':
	        host = lol[l][7].split(' ')
	        genus = host[0]
        	if len(host) > 1 and host[1][0].isupper():
                	genus = genus + '_' + host[1]
        	ann_hosts[lol[l][0]] =  genus


#loop over predictions and get host 
preds = open(args.file, 'r')
out   = open("%s.new"% args.file, 'w')

#add host to header line
header = preds.readline().rstrip('\n')
header = re.sub('\tDescription', '', header)
out.write('%s\thost\n'% header)


for l in preds.readlines():
	line = l.rstrip('\n').split('\t')
	host_p = re.sub( '\s', '', line[0])
	host = ann_hosts[host_p]
	out.write('%s\t%s\n'% ('\t'.join(line[0:10]), host))
