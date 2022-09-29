#!/bin/sh

# S1000 test set eval tagger

## Process to generate evaluation results on entire test set

### get the S1000 corpus and the jensenlab tagger results on S1000 from here: https://jensenlab.org/resources/s1000/
# wget 
# wget 
tar -xzvf S1000-corpus.tar.gz
tar -xzvf S1000-jensenlab-tagger.tar.gz

#generate list of FPs, FNs with docids to go through

python ./evalso.py -d -v S1000-corpus-split/entire-corpus/test S1000-jensenlab-tagger/entire-corpus/test --filtertypes Class,Family,Kingdom,Order,Out-of-scope,Phylum,Genus,Strain --overlap
