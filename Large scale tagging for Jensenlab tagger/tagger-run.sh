#!/bin/sh
mkdir -p large-scale-run
cd large-scale-run

#get tagger results with organisms dictionary
# you need to set up tagger first in case you haven't already
# uncomment the next lines to do so
# git clone https://github.com/larsjuhljensen/tagger tagger
# cd tagger
# make
# cd ..

#the dictionary files and the corpus can be downloaded from https://jensenlab.org/resources/S1000
wget https://zenodo.org/api/files/b8a0e221-3cc3-4db5-a2e9-f19a1bd2e5cb/tagger-organisms-dictionary-S1000.tar.gz?versionId=12618791-8e62-4d59-bf35-b54a30d4a5f7
wget https://a3s.fi/s1000/PubMed-input.tar.gz
wget https://a3s.fi/s1000/PMC-OA-input.tar.gz
tar -xzvf tagger-organisms-dictionary-S1000.tar.gz 
tar -xzvf PubMed-input.tar.gz 
tar -xzvf PMC-OA-input.tar.gz 

gzip -cd `ls -1 home/projects/ku_10024/data/databases/pmc/*.en.merged.filtered.tsv.gz` `ls -1r home/projects/ku_10024/data/databases/pubmed/*.tsv.gz` | cat tagger-organisms-dictionary-S1000/excluded_documents.txt - | tagger/tagcorpus --threads=40 --types=tagger-organisms-dictionary-S1000/organisms_types.tsv --entities=tagger-organisms-dictionary-S1000/organisms_entities_filtered_cellular.tsv --names=tagger-organisms-dictionary-S1000/organisms_names_filtered_cellular.tsv --groups=tagger-organisms-dictionary-S1000/organisms_groups_filtered_cellular.tsv --stopwords=tagger-organisms-dictionary-S1000/all_global.tsv --local-stopwords=tagger-organisms-dictionary-S1000/all_local.tsv --out-matches=large_scale_matches.tsv --out-segments=large_scale_segments.tsv 

./create_matches.pl large_scale_matches.tsv large_scale_matches_with_txids.tsv

python3 ./add_rank.py large_scale_matches_with_txids.tsv > large_scale_matches_with_txids_and_ranks.tsv

