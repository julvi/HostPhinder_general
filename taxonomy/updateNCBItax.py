#!/usr/bin/python

from ete2 import NCBITaxa

ncbi = NCBITaxa()
ncbi.update_taxonomy_database()
