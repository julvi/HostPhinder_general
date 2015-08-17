#!/usr/bin/env python
"""
import time
t0=time.time()
from Bio import SeqIO

fasta_sequences = SeqIO.parse(open('fake.fsa'),'fasta')
for fasta in fasta_sequences:
    name, sequence = fasta.id, fasta.seq
      #new_sequence = some_function(sequence)
    #print name
    #print sequence
    #break

t1 = time.time()
print t1-t0



#t0=time.time()
from itertools import groupby, islice
def fasta_iter(fasta_name, key):
"""    """
    given a fasta file or fastq. yield tuples of header, sequence
    key is '>' for fasta and '@' for fastq
"""    """
    fh = open(fasta_name)
    # ditch the boolean (x[0]) and just keep the header or sequence since
    # we know they alternate.
    faiter = (x[1] for x in groupby(fh, lambda line: line[0] == key))
    for header in faiter:
        # drop the ">"
        header = header.next()[1:].strip()
        #then the next sub-iters are sequence, '+', and qual
        #we concat them into a single string, then split them by '+'
        seq = "".join(s.strip().upper() for s in faiter.next()).split('+')[0]
        yield header, seq

def window(sequence, kmersize, stepsize):
#        kmers_count = ((len(sequence) - kmersize) / stepsize) + 1
        for i in range(0, len(sequence)-kmersize +1, stepsize):
                yield sequence[i : i + kmersize]

#print open('fake.fastq').readline()[0]

fasta_generator=fasta_iter('fake.fastq', open('fake.fastq').readline()[0])
#fasta_generator=fasta_iter('fake.fsa', '>')
for head_seq_tuple in fasta_generator:
    header, sequence = head_seq_tuple
    header = header.split()
    name = header[0]
    description = ' '.join(header[1:])
    print name
    print sequence
'''
    for kmer in window(sequence, 16, 2):
       if kmer.startswith(''):
           print kmer
    break
'''
#t1 = time.time()
#print t1-t0


""""""
#t0=time.time()
i=0
inputseqsegments = []
inputfile= open('fake.fsa', 'r')
for line in inputfile:
    line = line.rstrip('\n')
    fields=line.split() #each line in a list
    if len(line)>1:
      if fields[0][0] == ">":
        if (i>0):
          inputseq = ''.join(inputseqsegments)

        del inputseqsegments
        inputseqsegments = []
        i=0
        inputseq = ""
        inputname = fields[0][1:]
        print ' '.join(fields[1:len(fields)])
      else:
        inputseqsegments.append("")
        inputseqsegments[i] = fields[0].upper()
        i += 1
#t1 = time.time()
#print t1-t0
"""
i=0
inputseqsegments = []
queryseqsegments = []
inputfile= open('fake.fastq', 'r')
for line in inputfile:
    line = line.rstrip('\n')
    fields=line.split() #each line in a list
    if len(fields)>=1:

        if fields[0][0] == "@":
            # Fastq file
            if (i > 0):
                queryseq = ''.join(queryseqsegments)

                    # Update dictionary of kmers:
            #        save_kmers(queryseq)

            del queryseqsegments
            queryseqsegments = []
            i = 0
            queryseq = ""

            try:
                line = inputfile.next()
                fields = line.split()
                queryseqsegments.append("")
                queryseqsegments[i] = fields[0]
                i += 1
                line = inputfile.next()
                line = inputfile.next()
            except:
                break
        else:
            queryseqsegments.append("")
            queryseqsegments[i] = fields[0].upper()
            i += 1
queryseq = ''.join(queryseqsegments)
print queryseq

