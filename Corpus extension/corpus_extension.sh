# Generate a TSV file with the PMIDs for each genus
wget ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.dat.gz
gzip -d uniprot_sprot.dat.gz


#get NCBI taxonomy dump
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
tar -xvzf taxdump.tar.gz
#cut columns from taxonomy files
cut -f1,3,5 nodes.dmp > id_parent_type.dmp
cut -f 1,3,7 names.dmp | egrep $'\t''scientific name' | cut -f 1,2 > scientific_names.tsv
#concatenate files
paste id_parent_type.dmp scientific_names.tsv > id_parent_type_with_name.tsv

## Positive Class
#get species and genera from S800
#Use UniProt/Swiss-Prot annotations to identify categories of articles aligning with the original 
#S800 categories that mention at least one genus or species that is not already annotated in S800. 
#This will also include all genera of species in the S800 corpus which will be retrieved from mapping 
#of species to their parental ranks in NCBI taxonomy.
#Process for filtering out “known” species/genera, to get the unique taxids and their corresponding NCBI 
#Taxonomy scientific names from the current iteration of the annotation

wget https://jensenlab.org/assets/s1000/S800-reannotated.tar.gz
tar xvzf S800.tar.gz
cat S800/*.ann | egrep '^N' | cut -f 2 | perl -pe 's/^Reference T\d+ Taxonomy:// or die' | sort -n | uniq > unique-taxids.txt

cut -f 1,5 nodes.dmp > ranks.tsv
paste scientific_names.tsv ranks.tsv | cut -f 1,2,4 > scientific_names_and_ranks.tsv
egrep '('$(tr '\n' '|' < unique-taxids.txt | perl -pe 's/\|$//')')'$'\t' scientific_names_and_ranks.tsv > unique_annotated_names_and_ranks.tsv

#Four taxids were in the data that were not found in this release of the taxonomy 27380, 67004, 891394, and 891400. 
#These have been included in the final list (unique_annotated_names_and_ranks.tsv)
#Filter down to species and genus

egrep "species$|genus$" unique_annotated_names_and_ranks.tsv > unique_annotated_names_and_ranks_only_species_genus.tsv

#get species mentions
egrep "species$" unique_annotated_names_and_ranks.tsv > unique_annotated_names_and_ranks_only_species.tsv

#find direct parents of species in S800
awk -F"\t" 'NR==FNR{a[$1];next}{if($1 in a){print $0}}' ../unique_annotated_names_and_ranks_only_species.tsv id_parent_type_with_name.tsv> species_in_s800.tsv

cut -f2 species_in_s800.tsv > parents_of_species_in_s800.tsv
#find which are genera
awk -F"\t" 'NR==FNR{a[$1];next}{if($1 in a && $3=="genus"){print $0}}' parents_of_species_in_s800.tsv id_parent_type_with_name.tsv> genera_names.tsv
awk -F"\t" '{printf("%s\t%s\t%s\n", $1,$5,$3)}' genera_names.tsv > genera_of_species_in_s800.tsv

#add this in unique_annotated_names_and_ranks_only_species_genus.tsv
cat ../unique_annotated_names_and_ranks_only_species_genus.tsv genera_of_species_in_s800.tsv > ../unique_annotated_species_genus_and_species_genera.tsv
sort -u unique_annotated_species_genus_and_species_genera.tsv > tmp && mv tmp unique_annotated_species_genus_and_species_genera.tsv

#Generate files with papers per journal category in swissprot
perl get_organisms_from_swissprot.pl
mkdir -p unique_documents
#sort -u all files
for i in papers*.tsv; do sort -u $i > tmp && mv tmp ./unique_documents/$i ; done

#select 25 random documents for each category
for i in ./unique_documents/*; do shuf -n 25 $i > ./unique_documents/$(basename $i .tsv)-selected.tsv; done

# get results per genus
cut -f2-4 uniprot_organisms_fields_papers.tsv > uniprot_species-taxid_category_PMIDs.tsv
sort -u uniprot_species-taxid_category_PMIDs.tsv > tmp && mv tmp uniprot_species-taxid_category_PMIDs.tsv
awk -F"\t" 'NR==FNR{a[$1]=$2;next}{if($1 in a){printf("%s\t%s\n",a[$1],$0)}}' ./taxdump/id_parent_type_with_name.tsv uniprot_species-taxid_category_PMIDs.tsv > uniprot_parent_taxid_species-taxid_category_PMIDs.tsv
sort -u  uniprot_parent_taxid_species-taxid_category_PMIDs.tsv > tmp && mv tmp  uniprot_parent_taxid_species-taxid_category_PMIDs.tsv

perl group_by_genera.pl
perl get_unique_elements_last_column.pl

## Negative Class

#Use the tagger outputs to sample articles in which (presumably) no species mentions occur 
#and then tag them with a recent model to assess whether the models have a tendency to overtag 
#due to the training data being enriched for species mentions (by comparison to a random sample of PubMed)
#Create a sample of PMIDs without organism mentions 
#Process:

mkdir -p no-organism-mention-docs
cd no-organism-mention-docs

#get tagger results with organisms dictionary
#I need to set up tagger first https://github.com/larsjuhljensen/tagger
#the dictionary files and the corpus can be downloaded from https://jensenlab.org/resources/S1000
# wget 
# wget 
# tar -xzvf 
# tar -xzvf 

gzip -cd `ls -1 data/databases/pmc/*.en.merged.filtered.tsv.gz` `ls -1r data/databases/pubmed/*.tsv.gz` | cat data/textmining/excluded_documents.txt - | tagcorpus --threads=40 --types=../organisms_types.tsv --entities=../organisms_entities_filtered_cellular.tsv --names=../organisms_names_filtered_cellular.tsv --groups=../organisms_groups_filtered_cellular.tsv --stopwords=../all_global.tsv --local-stopwords=../all_local.tsv --out-matches=all_matches.tsv --out-segments=all_segments.tsv 

cut -f 1,7 all_matches.tsv | egrep $'\t''-2$' | cut -f 1 | uniq > organism-mention-pmids.txt
cut -f 1 database_documents.tsv > all-pmids.txt
split -l 1000000 all-pmids.txt all-pmids-
for f in all-pmids-*; do echo $f; sort $f > sorted-$f; done
sort -m sorted-all-pmids-* > sorted-all-pmids.txt
rm all-pmids-* sorted-all-pmids-*
split -l 1000000 organism-mention-pmids.txt organism-mention-pmids-
for f in organism-mention-pmids-*; do echo $f; sort $f > sorted-$f; done     
sort -m sorted-organism-mention-pmids-* > sorted-organism-mention-pmids.txt
rm organism-mention-pmids-* sorted-organism-mention-pmids-*
comm -2 -3 sorted-all-pmids.txt sorted-organism-mention-pmids.txt > no-organism-mention-pmids.txt

shuf -n 25 no-organism-mention-pmids > ./negative-selected.tsv
