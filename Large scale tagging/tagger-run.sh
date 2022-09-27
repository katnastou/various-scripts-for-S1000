#!/bin/sh
mkdir -p large-scale-run
cd large-scale-run

#I need to set up tagger first https://github.com/larsjuhljensen/tagger
#the rest of the files can be downloaded from https://jensenlab.org/resources/S1000
#wget ..
#wget ..
#tar -xzvf 
#tar -xzvf

gzip -cd `ls -1 pmc/*.en.merged.filtered.tsv.gz` `ls -1r pubmed/*.tsv.gz` | cat ../excluded_documents.txt - | tagcorpus --threads=40 --types=../organisms_types.tsv --entities=../organisms_entities_filtered_cellular.tsv --names=../organisms_names_filtered_cellular.tsv --groups=../organisms_groups_filtered_cellular.tsv --stopwords=../all_global.tsv --local-stopwords=../all_local.tsv --out-matches=large_scale_matches.tsv --out-segments=large_scale_segments.tsv 

./create_matches.pl large_scale_matches.tsv large_scale_matches_with_txids.tsv

python3 ./add_rank.py large_scale_matches_with_txids.tsv > large_scale_matches_with_txids_and_ranks.tsv

