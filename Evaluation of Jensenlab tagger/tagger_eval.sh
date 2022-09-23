#!/bin/sh

# S1000 test set eval tagger

## Process to generate evaluation results on entire test set

### get the S1000 corpus and the jensenlab tagger results on S1000 from here: https://jensenlab.org/resources/s1000/
tar -xzvf S1000-corpus.tar.gz
tar -xzvf S1000-jensenlab-tagger.tar.gz

python ./evalso.py S1000-corpus-split/entire-corpus/test S1000-jensenlab-tagger/entire-corpus/test --filtertypes Class,Family,Kingdom,Order,Out-of-scope,Phylum,Genus,Strain --overlap

## Process to generate evaluation results on 8-category split set
arr=( "bac" "bot" "ent" "med" "myc" "pro" "vir" "zoo" )
for i in "${arr[@]}"; do
    echo $i;
    python evalso.py S1000-corpus-split/per-journal-category/${i}/test S1000-jensenlab-tagger/per-journal-category/${i}/test --filtertypes Class,Family,Kingdom,Order,Out-of-scope,Phylum,Genus,Strain --overlap
done

