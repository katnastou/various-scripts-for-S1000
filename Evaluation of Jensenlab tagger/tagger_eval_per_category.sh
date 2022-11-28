#!/bin/sh

# S1000 test set eval tagger

## Process to generate evaluation results on entire test set

### get the S1000 corpus and the jensenlab tagger results on S1000 from here: https://jensenlab.org/resources/s1000/
wget https://zenodo.org/api/files/b8a0e221-3cc3-4db5-a2e9-f19a1bd2e5cb/S1000-corpus.tar.gz?versionId=150883e3-5e15-4cad-8a54-51b9a77b8410
wget https://zenodo.org/api/files/b8a0e221-3cc3-4db5-a2e9-f19a1bd2e5cb/S1000-jensenlab-tagger.tar.gz?versionId=d8d9c9f5-ee3b-4738-aefa-a4a95475d25d
tar -xzvf S1000-corpus.tar.gz
tar -xzvf S1000-jensenlab-tagger.tar.gz

## Process to generate evaluation results on 8-category split set
arr=( "bac" "bot" "ent" "med" "myc" "pro" "vir" "zoo" )
for i in "${arr[@]}"; do
    echo $i;
    python evalso.py S1000-corpus/per-journal-category/${i}/test S1000-jensenlab-tagger/per-journal-category/${i}/test --filtertypes Class,Family,Kingdom,Order,Out-of-scope,Phylum,Genus,Strain --overlap
done

