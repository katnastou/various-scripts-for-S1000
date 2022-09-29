#!/bin/bash

#Copy text from C2 other dir

tar -xzvf S1000-corpus.tar.gz
mkdir S1000-jensenlab-tagger/entire-corpus/test

#copy all text from brat format
cp S1000-corpus-split/entire-corpus/test/*.txt S1000-jensenlab-tagger/entire-corpus/test


#get all fields from latest version of database documents
#I need a list of PMIDs as input, and the database documents for tagger
for i in `ls -1 S1000-jensenlab-tagger/entire-corpus/test/*.txt`; do s="${i##*/}"; echo "${s%.txt}" >> s1000_test_pmids.list;  done
 
#remove last column for text, we want to add the text from BRAT standoff not the text currently in STRING
# && remove second column of identifiers
#get the database_documents file from here: https://jensenlab.org/resources/s1000/
#wget
#tar -xzvf
awk -F"\t" 'NR==FNR{a[$0];next}$1 in a' s1000_test_pmids.list database_documents.tsv > database_docs_s1000_test.tsv
awk -F"\t" '{printf("%s\t%s\t%s\t%s\n"),$1,$3,$4,$5}' database_docs_s1000_test.tsv > s1000_test_no_text.tsv
#replace double new lines with tab

#https://stackoverflow.com/a/3535826/8041304
mkdir -p intermediate
for i in S1000-corpus-split/entire-corpus/test/*.txt; do  perl -p -0 -w -e "s/\n\n/\n/g" $i | perl -p -0 -w -e "s/\n/\t/g" > intermediate/${i##*/}; done

#create file with PMIDs and text 
for i in intermediate/*.txt ; do text=`cat $i`; i=${i##*/};echo -e "${i%.txt}\t$text";done > s1000_test_brat_standoff_pmid_text.tsv
rm -rf intermediate
#generate tagger input file
#REMEMBER TO PRINT PMID: IN FRONT otherwise tagger fails to run
awk -F"\t" 'NR==FNR{a[$1]=$0;next}$1 in a{printf("PMID:%s\t%s\n"),$0,a[$1]}' s1000_test_brat_standoff_pmid_text.tsv s1000_test_no_text.tsv | cut -f1-4,6- > s1000_test_brat_text.tsv


#run tagger with correct dictionary files
# get the dictionary files for tagger from here: https://jensenlab.org/resources/s1000/
# and the tagger from here: https://github.com/larsjuhljensen/tagger
#wget 
#tar -xzvf
cat s1000_test_brat_text.tsv | tagcorpus --threads=1 --types=organisms_types.tsv --entities=organisms_entities_filtered_cellular.tsv --names=organisms_names_filtered_cellular.tsv --groups=organisms_groups_filtered_cellular.tsv --stopwords=all_global.tsv --local-stopwords=all_local.tsv --out-matches=s1000_test_matches.tsv --out-segments=s1000_test_segments.tsv 

#cat s1000_test_brat_text.tsv | /home/projects/ku_10024/apps/tagger-jan2021/tagcorpus --threads=10 --types=../organisms_types.tsv --entities=../organisms_entities_filtered_cellular.tsv --names=../organisms_names_filtered_cellular.tsv --groups=../organisms_groups_filtered_cellular.tsv --stopwords=../all_global.tsv --local-stopwords=../all_local.tsv --out-matches=s1000_test_matches.tsv --out-segments=s1000_test_segments.tsv 


#run create matches twice for the two sets to get the taxids to find the rank

./create_matches.pl s1000_test_matches.tsv s1000_test_matches_with_txids.tsv

#add rank info
python3 add_rank.py s1000_test_matches_with_txids.tsv > s1000_test_matches_with_txids_and_ranks.tsv

#keep all species (even the ones that are lower level, we want to show) 
#e.g. 	Microsporum gypseum CBS118893 is tagged as strain, but I will also keep the species mentions.
sed -nr '/\b(species)$/p' s1000_test_matches_with_txids_and_ranks.tsv > s1000_test_matches_with_txids_and_ranks_only_species.tsv


#sort to keep the same order
sort -k1,1rn s1000_test_matches_with_txids_and_ranks_only_species.tsv > tmp && mv tmp s1000_test_matches_with_txids_and_ranks_only_species_sorted.tsv 

#some times the same thing corresponds to multiple species... 
awk '!seen[$1,$2,$3,$4,$5,$6,$7]++' s1000_test_matches_with_txids_and_ranks_only_species_sorted.tsv > s1000_test_matches_with_txids_and_ranks_only_species_sorted_unique.tsv

#remove PMID: from input documents
perl -pe 's/^PMID://g' s1000_test_brat_text.tsv >  s1000_test_brat_text_no_pmid.tsv
sort -k1,1rn s1000_test_brat_text_no_pmid.tsv > tmp && mv tmp s1000_test_brat_text_no_pmid.tsv 

#convert actual "\t" to '\t'
awk -F"\t" '{printf("%s\tPMID:%s\t%s\t%s\t%s\t%s\\t\n", $1, $1, $2, $3, $4, $5)}' s1000_test_brat_text_no_pmid.tsv > s1000_test_brat_text_no_pmid_concat_notext.tsv
paste -d ' ' s1000_test_brat_text_no_pmid_concat_notext.tsv <(cut -f6- s1000_test_brat_text_no_pmid.tsv | perl -pe "s/\t/ /g") > s1000_test_brat_text_no_pmid_concat.tsv


#from here
python3 tagger2standoff.py s1000_test_brat_text_no_pmid_concat.tsv s1000_test_matches_with_txids_and_ranks_only_species_sorted_unique.tsv S1000-jensenlab-tagger/entire-corpus/test/


#copy test set data to new directories
cp -r S1000-jensenlab-tagger/entire-corpus/test/ S1000-jensenlab-tagger/entire-corpus/test-filtered
#Replace species with Species
for f in S1000-jensenlab-tagger/entire-corpus/test/*.ann; do egrep '^T[0-9]+'$'\t''(species) [0-9]' $f | perl -pe 's/(T\d+\t)(\S)/$1\U$2/' > $(dirname $f)-filtered/$(basename $f); done

#Do the text alignment
cp -r S1000-jensenlab-tagger/entire-corpus/test-filtered{,-aligned}

for f in S1000-jensenlab-tagger/entire-corpus/test-filtered/*.ann; do python3 annalign.py $f ${f%.ann}.txt S1000-corpus-split/entire-corpus/test/$(basename $f .ann).txt > S1000-jensenlab-tagger/entire-corpus/test-filtered-aligned/$(basename $f); done

#run the evaluation script -- python2
python ./evalso.py S1000-corpus-split/entire-corpus/test S1000-jensenlab-tagger/entire-corpus/test-filtered-aligned --filtertypes Class,Family,Kingdom,Order,Out-of-scope,Phylum,Genus,Strain --overlap