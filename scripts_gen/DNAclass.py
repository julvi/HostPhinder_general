#!/usr/bin/env python

from itertools import groupby, chain

class DNA:
    """Class representing DNA as a string sequence."""

    basecomplement = {'A': 'T', 'C': 'G', 'T': 'A', 'G': 'C'}

    def __init__(self, s):
        """Create DNA instance initialized to string s."""
        self.seq = s

    def length(self):
        """ Return sequence length """
        return len(self.seq)

    def transcribe(self):
        """Return as rna string."""
        return self.seq.replace('T', 'U')

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

    def gc(self):
        """Return the percentage of dna composed of G+C."""
        s = self.seq
        gc = s.count('G') + s.count('C')
        return gc * 100.0 / len(s)

    def codons(self):
        """Return list of codons for the dna string."""
        s = self.seq
        end = len(s) - (len(s) % 3) - 1
        codons = [s[i:i+3] for i in range(0, end, 3)]
        return codons

    def windows(self, kmersize, stepsize):
        s = self.seq
        for i in range(0, len(s) - kmersize +1, stepsize):
            yield s[i : i + kmersize]

    def countwindows(self, kmersize, stepsize):
        s= self.seq
        return divmod((((len(s) - kmersize) / stepsize) + 1),1)[0]

def fasta_iter(fasta_name):
    """
    given a fasta file. yield tuples of header, sequence
    """
    fh = open(fasta_name)
    # ditch the boolean (x[0]) and just keep the header or sequence since
    # we know they alternate.
    faiter = (x[1] for x in groupby(fh, lambda line: line[0] == ">"))
    for header in faiter:
        # drop the ">"
        header = header.next()[1:].strip()
        # join all sequence lines to one.
        seq = "".join(s.strip() for s in faiter.next())
        yield header, seq
fasta_generator=fasta_iter('fake.fsa')
for head_seq_tuple in fasta_generator:
    header, sequence = head_seq_tuple
    header = header.split()
    name = header[0]

sequence=DNA(sequence)
revcom=DNA(sequence.reversecomplement())
dirandrevcom = chain(sequence.windows(16, 3), revcom.windows(16, 3))
#for item in dirandrevcom:
 #   print item

print sequence.countwindows(16,3)
