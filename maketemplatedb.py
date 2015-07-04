#!/usr/bin/env python
#
# Import libraries
#
import sys, time
import os
from optparse import OptionParser
import re
import cPickle as pickle
#
# Functions
#
# Construct the reverse complement from a sequence
#
def reversecomplement(seq):
    '''Reverse complement'''
    comp = ''
    for s in seq:
        if s == 'A': comp = comp + 'T'
        elif s == 'T': comp = comp + 'A'
        elif s == 'C': comp = comp + 'G'
        elif s == 'G': comp = comp + 'C'
        else: comp = comp + s
    return comp[::-1]
#
# Parse command line options
#
parser = OptionParser()
parser.add_option("-i", "--inputfile", dest="inputfilename", help="read from INFILE", metavar="INFILE") 
parser.add_option("-f", "--filterfile", dest="filterfilename", help="filter (ignore) K-mers present in FILTERFILE", metavar="FILTERFILE") 
parser.add_option("-o", "--outputfile", dest="outputfilename", help="write to OUTFILE", metavar="OUTFILE") 
parser.add_option("-k", "--kmersize", dest="kmersize", help="Size of KMER", metavar="KMERSIZE") 
parser.add_option("-s", "--stepsize", dest="stepsize", help="Size of step between K-mers", metavar="STEPSIZE") 
parser.add_option("-x", "--prefix", dest="prefix", help="type of prefix", metavar="PREFIX") 
parser.add_option("-p", "--pickleoutput", dest="pickleoutput",action="store_true", help="use pickle output") 
(options, args) = parser.parse_args() 
# 
# Open file for input sequence with kmers to save in database
# 
if options.inputfilename != None:
  if options.inputfilename == "--":
    inputfile = sys.stdin
  else:
    inputfile = open(options.inputfilename,"r")
#
# Open file to filter on (kmers not to save in database)
#
if options.filterfilename != None:
  filterfile = open(options.filterfilename,"r")
#
# Harcode this to be true so I do not need to use the -p option
#
options.pickleoutput = True
if options.outputfilename != None:
  if options.pickleoutput == True:
    outputfile = open(options.outputfilename+".p", "wb")
    outputfile_lengths = open(options.outputfilename+".len.p", "wb")
    outputfile_descriptions = open(options.outputfilename+".desc.p", "wb")
  else:
    outputfile = open(options.outputfilename,"w")
else:
  outputfile = sys.stdout
#
# Size of K-mer
#
if options.kmersize != None:
  kmersize = int(options.kmersize)
else:
  kmersize = 16
#
# Size of step when looking for K-mers in the sequence
#
if options.stepsize != None:
  stepsize = int(options.stepsize)
else:
  stepsize = 1
#
# Prefix to use fro filtering sequences
#
if options.prefix != None:
  #prefix = int(options.prefix)
  prefix = options.prefix
  prefixlist = [prefix]
  prefixlen = len(prefixlist[0])
else:
  prefix = ''
  prefixlist = [prefix]
  prefixlen = len(prefixlist[0])
#
# Initialize statistics
#
# # of kmers
kmer_count = 0
# Start time to keep track of progress
t0 = time.time()
# Print progress
printfreq = 100000
# frequenct to save sorted list to db
dbsavefreq = 30000000
#
# Read sequences from filterfile ans save K-mers
#
filterseqsegments = []
filters = {}
Nfilters=0
i=0
t1 = time.time()
if options.filterfilename != None:
  sys.stdout.write("%s\n" % ("# Reading filterfile"))
  for line in filterfile:
    line = line.rstrip('\n')
    fields=line.split()
    if len(line)>1:
      if fields[0][0] == ">":
        if (i>0):
	  #
	  # Fasta entry read
	  #
          filterseq = ''.join(filterseqsegments)
	  for seq in [filterseq,reversecomplement(filterseq)]:
            start=0
            while start < len(filterseq)-kmersize:
              submer = filterseq[start:start+kmersize]
	      if prefix == filterseq[start:start+prefixlen]:
                if not submer in filters:
                  filters[submer] = filtername
              kmer_count += 1
              if kmer_count % printfreq == 0:
                t1 = time.time()
                sys.stdout.write("\r%s kmers (%s kmers / s)" % ("{:,}".format(kmer_count), "{:,}".format(kmer_count / (t1-t0))))
                sys.stdout.flush()
              start +=stepsize	
        del filterseqsegments
        filterseqsegments = []
        i=0
        filterseq = ""
        filtername = fields[0][1:] 
      else:
        filterseqsegments.append("")
        filterseqsegments[i] = fields[0]
        i+=1
  filterseq = ''.join(filterseqsegments)
  for seq in [filterseq,reversecomplement(filterseq)]:
    start=0
    while start < len(filterseq)-kmersize:
      submer = filterseq[start:start+kmersize]
      if prefix == filterseq[start:start+prefixlen]:
        if not submer in filters:
          filters[submer] = filtername
      kmer_count += 1
      if kmer_count % printfreq == 0:
        t1 = time.time()
        sys.stdout.write("\r%s kmers (%s kmers / s)" % ("{:,}".format(kmer_count), "{:,}".format(kmer_count / (t1-t0))))
        sys.stdout.flush()
      start +=stepsize	
  #
  # Print final statistics for filterfile
  #
  t1 = time.time()
  sys.stdout.write("\r%s kmers (%s kmers / s)" % ("{:,}".format(kmer_count), "{:,}".format(kmer_count / (t1-t0))))
  sys.stdout.flush()
  sys.stdout.write("\n")
del filterseqsegments
#
# Read input file and save K-mers not in filterfile (if -f option is used)
#
kmer_count = 0
Nstored = 0
Nstored_old = Nstored
inputseqsegments = []
inputs = {}
lengths = {}
descriptions = {}
Ninputs=0
i=0
if options.inputfilename != None:
  sys.stdout.write("%s\n" % ("# Reading inputfile"))
  for line in inputfile:
    line = line.rstrip('\n')
    fields=line.split()
    if len(line)>1:
      if fields[0][0] == ">":
        if (i>0):
          inputseq = ''.join(inputseqsegments)
	  for seq in [inputseq,reversecomplement(inputseq)]:
            start=0
            while start < len(inputseq)-kmersize:
              submer = inputseq[start:start+kmersize]
	      if prefix == inputseq[start:start+prefixlen]:
	        if (options.filterfilename != None and submer not in filters) or options.filterfilename == None:
		  Nstored += 1
                  if submer in inputs:
                    inputs[submer] = inputs[submer]+","+inputname
                  else:
                    inputs[submer] = inputname
              kmer_count += 1
              if kmer_count % printfreq == 0:
                t1 = time.time()
                sys.stdout.write("\r%s kmers (%s kmers / s)" % ("{:,}".format(kmer_count), "{:,}".format(kmer_count / (t1-t0))))
                sys.stdout.flush()
              start +=stepsize	
	  lengths[inputname] = Nstored - Nstored_old
	  #print inputname,lengths[inputname], Nstored, Nstored_old,"i: ",i, len(inputseq)
	  Nstored_old = Nstored
        del inputseqsegments	
        inputseqsegments = []
        i=0
        inputseq = ""
        inputname = fields[0][1:]
	descriptions[inputname] = ' '.join(fields[1:len(fields)])
	kmer_count_old = kmer_count
      else:
        inputseqsegments.append("")
        inputseqsegments[i] = fields[0]
        i = i + 1
  inputseq = ''.join(inputseqsegments)
  lengths[inputname] = Nstored - Nstored_old
  for seq in [inputseq,reversecomplement(inputseq)]:
    start=0
    while start < len(inputseq)-kmersize:
      submer = inputseq[start:start+kmersize]
      if prefix == inputseq[start:start+prefixlen]:
        if (options.filterfilename != None and submer not in filters) or options.filterfilename == None:
	  Nstored += 1
          if submer in inputs:
            inputs[submer] = inputs[submer]+","+inputname
          else:
            inputs[submer] = inputname
      kmer_count += 1
      if kmer_count % printfreq == 0:
        t1 = time.time()
        sys.stdout.write("\r%s kmers (%s kmers / s)" % ("{:,}".format(kmer_count), "{:,}".format(kmer_count / (t1-t0))))
        sys.stdout.flush()
      start +=stepsize	
  lengths[inputname] = Nstored - Nstored_old
  #print inputname,lengths[inputname], Nstored, Nstored_old,"i: ",i, len(inputseq)
  #Nstored_old = Nstored
del inputseqsegments
#
# Print database of nmers
#
if options.pickleoutput == True:
  pickle.dump(inputs, outputfile,2)
  pickle.dump(lengths, outputfile_lengths,2)
  pickle.dump(descriptions, outputfile_descriptions,2)
#
# Print final statistics for inputfile
#
t2 = time.time()
sys.stdout.write("\r%s kmers (%s kmers / s)" % ("{:,}".format(kmer_count), "{:,}".format(kmer_count / (t2-t1))))
sys.stdout.flush()
sys.stdout.write("\n")
sys.stdout.write("# Total time used: %s s\n" % (t2-t0))
#
# Done
#
