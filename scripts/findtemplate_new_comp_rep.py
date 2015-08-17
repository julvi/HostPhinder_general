#!/usr/bin/env python

# Copyright (c) 2014, Ole Lund, Technical University of Denmark
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# On cge-s2 run with /tools/opt/anaconda/bin/python

##########################################################################
# Import libraries
##########################################################################

import argparse
import sys, time
import os
from math import sqrt
import scipy
from scipy.stats import norm
from operator import itemgetter
from itertools import groupby, chain
import re
import cPickle as pickle

##########################################################################
# FUNCTIONS
##########################################################################

class DNA:
    """Class representing DNA as a string sequence."""

    basecomplement = {'A': 'T', 'C': 'G', 'T': 'A', 'G': 'C', 'Y': 'R',
                      'R': 'Y', 'N': 'N', 'K': 'M', 'M': 'K', 'S': 'S',
                      'W': 'W'}

    def __init__(self, s):
        """Create DNA instance initialized to string s."""
        self.seq = s

    def length(self):
        """ Return DNA length """
        return len(self.seq)

    def reverse(self):
        """Return dna string in reverse order."""
        letters = list(self.seq)
        letters.reverse()
        return ''.join(letters)

    def complement(self):
        """Return the complementary dna string."""
        letters = list(self.seq)
        letters = [self.basecomplement[base] for base in letters]
        return ''.join(letters)

    def reversecomplement(self):
        """Return the reverse complement of the dna string."""
        letters = list(self.seq)
        letters.reverse()
        letters = [self.basecomplement[base] for base in letters]
        return ''.join(letters)

    def windows(self, kmersize, stepsize):
        """ Yield kmers (generator) """
        s = self.seq
        for i in range(0, len(s) - kmersize +1, stepsize):
            yield s[i : i + kmersize]

    def countwindows(self, kmersize, stepsize):
        """ Return expected number of kmers """
        s= self.seq
        return divmod((((len(s) - kmersize) / stepsize) + 1),1)[0]
 


def fasta_iter(fasta_name, key):
    ''' Given a fasta or fastq file, yield tuples of header, sequence 
        key is '>' for fasta and '@' for fastq'''
    fh = open(fasta_name)

    # Create a FASTA ITERATOR
    # groupby groups together items that have the same key
    # --> lines that have the same header
    # x[0] is a boolean (True for lines that start with '>' and False for other)
    # x[1] are the groups (header and sequence)
    faiter = (x[1] for x in groupby(fh, lambda line: line[0] == key))
    for header in faiter:
        # drop the ">"
        header = header.next()[1:].strip()
        # for fastq the next sub-iters are sequence, '+', and quality
        # we concat them into a single string, then split them by '+'
        # fasta is not affected (does not have +)
        seq = "".join(s.strip().upper() for s in faiter.next()).split('+')[0]
        yield header, seq


#--------------------------------------
# save kmers of querysequence:
#--------------------------------------


def save_kmers(queryseq):

    global qtotlen, prefix, queryindex, querymers, uquerymers

    qtotlen += queryseq.length()
    revcompl = DNA(queryseq.reversecomplement())
    # join kmers generators from direct and reverse complement sequencies
    joinwindowgen = chain(queryseq.windows(kmersize, 1), revcompl.windows(kmersize, 1))
    # store kmers in original and reverse complement sequence:
    for submer in joinwindowgen:
        if submer.startswith(prefix):
            if submer in queryindex:
                querymers += 1
                if submer in templates:
                    queryindex[submer] += 1
            else:
                uquerymers += 1
                querymers += 1
                if submer in templates:
                    queryindex[submer] = 1

#-------------------------------------
# search for matches:
#-------------------------------------


def find_matches():

    global queryindex, mincoverage, templates

    templateentries = {}
    templateentries_tot = {}
    Nhits = 0

    for submer in queryindex:
        if queryindex[submer] >= mincoverage:
            matches = templates[submer].split(",")

            # get list of unique matches:
            umatches = list(set(matches))

            # Nhits = sum of scores over all templates:
            Nhits = Nhits + len(umatches)

            for match in umatches:

                # get unique scores:
                if match in templateentries:
                    templateentries[match] += 1
                else:
                    templateentries[match] = 1

                # get total amount of kmers found in template (total score):
                # given by multiple copy of the same kmer in query 
                # (NOT in template)
                if match in templateentries_tot:
                    templateentries_tot[match] += queryindex[submer]
                else:
                    templateentries_tot[match] = queryindex[submer]

    return(templateentries, templateentries_tot, Nhits)


#------------------------------------------------
# Conservative two sided p-value from z-score:
#------------------------------------------------


def z_from_two_samples(r1, n1, r2, n2):
    '''Comparison of two fractions, Statistical methods in medical research, Armitage et al. p. 125'''
    #
    # r1: positives in sample 1
    # n1: size of sample 1
    # r2: positives in sample 2
    # n2: size of sample 2

    p1 = float(r1) / (float(n1) + etta)
    p2 = float(r2) / (float(n2) + etta)
    q1 = 1 - p1
    q2 = 1 - p2
    p = (float(r1) + r2) / (n1 + n2 + etta)
    q = 1 - p
    z = (p1 - p2) / sqrt(p * q * (1 / (n1 + etta) + 1 / (n2 + etta)) + etta)

    return z



#------------------------------------------------------------------------------
# Parse command line options
#------------------------------------------------------------------------------

parser= argparse.ArgumentParser(description='Look for overlapping k-mers between query and templates in the database.')

parser.add_argument("-i", "--inputfile", dest="inputfilename",help="read from INFILE", metavar="INFILE")
parser.add_argument("-t", "--templatefile", dest="templatefilename",help="read from TEMFILE", metavar="TEMFILE")
parser.add_argument("-o", "--outputfile", dest="outputfilename",help="write to OUTFILE", metavar="OUTFILE")
parser.add_argument("-k", "--kmersize", dest="kmersize",help="Size of k-mer, default 16", default=16, metavar="KMERSIZE")
parser.add_argument("-x", "--prefix", dest="prefix", default = '', help="prefix, e.g. ATGAC, default none", metavar="_id")
parser.add_argument("-a", "--printall", dest="printall", action="store_true",help="Print matches to all templates in templatefile unsorted")
# The first hit is the one to which most of query kmers mathch to
# with this option the matching k-mers are then eliminated from the search
parser.add_argument("-w", "--winnertakesitall", dest="wta", action="store_true",help="kmer hits are only assigned to most similar template")
parser.add_argument("-e", "--evalue", dest="evalue", default=0.05, help="Maximum E-value", metavar="EVALUE")
args = parser.parse_args()


# set up prefix filtering
prefix = args.prefix
prefixlen = len(prefix)


# get e-value:
evalue = args.evalue 

# Open files 
t0 = time.time()
if args.inputfilename != None:
    if args.inputfilename == "--":
        inputfile = sys.stdin
    else:
        inputfile = args.inputfilename


# open templatefile
if args.templatefilename != None:
    templatefile = open(args.templatefilename + ".p", "rb" )
    templatefile_lengths = open(args.templatefilename + ".len.p", "rb" )
    templatefile_descriptions = open(args.templatefilename + ".desc.p", "rb" )
    try:
        templatefile_ulengths = open(args.templatefilename + ".ulen.p", "rb" )
    except:
        pass
else:
  sys.exit("No template file specified")


# open outputfile:
if args.outputfilename != None:
    outputfile = open(args.outputfilename,"w")
else:  # If no output filename choose the same as the input filename
    outputfilename = os.path.splitext(args.inputfilename)[0]
    outputfile = open(outputfilename, "w")


# Size of K-mer
kmersize = args.kmersize

##########################################################################
# READ DATABASE OF TEMPLATES
##########################################################################

templates = {}
Ntemplates = 0


# Read Template file:
sys.stdout.write("%s\n" % ("# Reading database of templates and ckecking for database integrity"))
templates = pickle.load(templatefile)
templates_lengths = pickle.load(templatefile_lengths)
try:
    templates_ulengths = pickle.load(templatefile_ulengths)
    #
    # Check for database integrity --> all template must have > 0 unique k-mers
    #
    if any(ulength == 0 for ulength in templates_ulengths.values()):
        sys.stderr.write('ERROR: database did not pass integrity check!\n')
        sys.exit(2)
except:
    sys.stderr.write('No ulen.p file found for database')
    SystemExit()
templates_descriptions = pickle.load(templatefile_descriptions)

# Count number of k-mers, and sum of unique k-mers over all templates:
template_tot_len = 0
template_tot_ulen = 0
Ntemplates = 0
# length added
for name in templates_lengths:
    template_tot_len += templates_lengths[name]
    template_tot_ulen += templates_ulengths[name]
    Ntemplates += 1

##########################################################################
# READ INPUTFILE
##########################################################################

queryseq = ""
queryseqsegments = []
Nquerys = 0
queryindex = {}
qtotlen = 0
querymers = 0
uquerymers = 0
# here introduce timing

t0 = time.time()
sys.stdout.write("%s\n" % ("# Reading inputfile"))
# The first charachter in the first line distinguish fasta from fastq
fasta_generator=fasta_iter(inputfile, open(inputfile).readline()[0])
for head_seq_tuple in fasta_generator:
    header, queryseq = head_seq_tuple
    header = header.split()

    queryseq = DNA(queryseq)
        # Update dictionary of kmers
    save_kmers(queryseq)


##########################################################################
# SEARCH FOR MATCHES
##########################################################################

sys.stdout.write("%s\n" % ("# Searching for matches of input in template"))
mincoverage = 1
templateentries = {}
templateentries_tot = {}
Nhits = 0

(templateentries, templateentries_tot, Nhits) = find_matches()


##########################################################################
#       DO STATISTICS
##########################################################################


minscore = 0
etta = 1.0e-8  # etta is a small number to avoid division by zero

# report search statistics:
sys.stdout.write("%s\n" % ("# Search statistics"))
sys.stdout.write("%s\n" % ("# Total number of hits: %s") % (Nhits))
sys.stdout.write("%s\n" % ("# Total number of kmers in templates : %s") % (template_tot_len))
sys.stdout.write("%s\n" % ("# Minimum number of k-mer hits to report template: %s") % (minscore))
sys.stdout.write("%s\n" % ("# Maximum multiple testing corrected E-value to report match : %s") % (evalue))
sys.stdout.write("%s\n" % ("# Printing best matches"))


# print heading of outputfile:
if args.wta != True:
    outputfile.write("#Template\tScore\tExpected\tz\tp_value\tquery coverage [%]\ttemplate coverage [%]\tdepth\tKmers in Template\tDescription\n")
elif args.wta == True:
    outputfile.write("#Template\tScore\tExpected\tz\tp_value\tquery coverage [%]\ttemplate coverage [%]\tdepth\ttotal query coverage [%]\ttotal template coverage [%]\ttotal depth\tKmers in Template\tDescription\n")

##########################################################################
#       STANDARD SCORING SCHEME
##########################################################################


if not args.wta == True:

    sortedlist = sorted(
        templateentries.iteritems(), key=itemgetter(1), reverse=True)
    for template, score in sortedlist:
        if score > minscore:
            expected = float(
                Nhits) * float(templates_ulengths[template]) / float(template_tot_ulen)
            #z = (score - expected)/sqrt(score + expected+etta)
            #p  = fastp(z)
            #
            # If expected < 1 the above poisson approximation is a poor model
            # Use instead: probabilyty of seing X hits is p**X if probability
            # of seing one hit is p (like tossing a dice X times)
            #
            # if expected <1:
            #  p = expected**score
            #
            # Comparison of two fractions, Statistical methods in medical
            # research, Armitage et al. p. 125:
            z = z_from_two_samples(
                score, templates_ulengths[template], Nhits, template_tot_ulen)
            p = scipy.stats.norm.sf(z)*2

            # Correction for multiple testing:
            p_corr = p * Ntemplates
            frac_q = ( score / (float(uquerymers) + etta)) * 100
            frac_d = (score / (templates_ulengths[template] + etta)) * 100
            coverage = templateentries_tot[
                template] / float(templates_lengths[template])

            # print str(p) + " " + str(p_corr) + " " + str(evalue)
            # p_corr=0
            if p_corr <= evalue:
                outputfile.write("%-12s\t%8d\t%8d\t%8.2f\t%4.1e\t%8.2f\t%8.2f\t%8.2f\t%8d\t%s\n" %
                                 (template, score, int(round(expected)), round(z, 1), p_corr, frac_q, frac_d, coverage, templates_ulengths[template], templates_descriptions[template].strip()))


##########################################################################
#       WINNER TAKES IT ALL
##########################################################################

if args.wta == True:

    w_templateentries = templateentries.copy()
    w_templateentries_tot = templateentries_tot.copy()
    w_Nhits = Nhits

    maxhits = 100
    hitcounter = 1
    stop = False
    while not stop:
        hitcounter += 1
        if hitcounter > maxhits:
            stop = True
        sortedlist = sorted(
            w_templateentries.iteritems(), key=itemgetter(1), reverse=True)
        for template, score in sortedlist:
            if score > minscore:
                expected = float(
                    w_Nhits) * float(templates_ulengths[template]) / float(template_tot_ulen)
                #z = (score - expected)/sqrt(score + expected+etta)
                #p  = fastp(z)
                #
                # If expected < 1 the above poisson approximation is a poor model
                #
                # if expected <1:
                #  p = expected**score
                #
                # Comparison of two fractions, Statistical methods in medical
                # research, Armitage et al. p. 125:
                z = z_from_two_samples(
                    score, templates_ulengths[template], w_Nhits, template_tot_ulen)
                p = scipy.stats.norm.sf(z)*2

                # correction for multiple testing:
                p_corr = p * Ntemplates
                # print score,float(uquerymers),etta
                frac_q = (score / (float(uquerymers) + etta)) * 100
                frac_d = (score / (templates_ulengths[template] + etta)) * 100
                coverage = w_templateentries_tot[
                    template] / float(templates_lengths[template])

                # calculate total values:
                tot_frac_q = (templateentries[template] / (float(uquerymers) + etta)) * 100
                tot_frac_d = (templateentries[template] / (templates_ulengths[template] + etta)) * 100
                tot_coverage = templateentries_tot[template] / float(templates_lengths[template])

                # print results to outputfile:
                if p_corr <= evalue:
                    outputfile.write("%-12s\t%8d\t%8d\t%8.1f\t%4.2e\t%8.2f\t%8.2f\t%4.2f\t%8.2f\t%8.2f\t%4.2f\t%8d\t%s\n" %
                                     (template, score, int(round(expected)), round(z, 1), p_corr, frac_q, frac_d, coverage, tot_frac_q, tot_frac_d, tot_coverage, templates_ulengths[template], templates_descriptions[template].strip()))

                    # remove all kmers in best hit from queryindex
                    for submer in queryindex:
                        matches = templates[submer].split(",")
                        if template in matches:
                            queryindex[submer] = 0

                    # find best hit like before:
                    del w_templateentries
                    del w_templateentries_tot
                    w_templateentries = {}
                    w_templateentries_tot = {}
                    w_Nhits = 0

                    (w_templateentries, w_templateentries_tot,
                     w_Nhits) = find_matches()

                else:
                    stop = True
            break

##########################################################################
# CLOSE FILES
##########################################################################

t1 = time.time()

sys.stdout.write("\r# %s kmers (%s kmers / s). Total time used: %s sec" %("{:,}".format(querymers), "{:,}".format(querymers / (t1 - t0)), int(t1 - t0)))
sys.stdout.flush()
sys.stdout.write("\n")
sys.stderr.write("DONE!")
sys.stdout.write("# Closing files\n")
