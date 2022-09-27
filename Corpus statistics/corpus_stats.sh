#!/bin/sh
# Do the counts for corpus statistics

## get the corpus from here: https://jensenlab.org/resources/s1000/
wget https://jensenlab.org/assets/s1000/S1000-corpus.tar.gz
tar -xzcf S1000-corpus.tar.gz
cd S1000-corpus-split

### Calculate total mentions

#### Calculate for the entire corpus

##### Get all mentions from the anns
#on linux
for i in entire-corpus/{train,dev,test}/*.ann; do
   grep -P "^T\d+\tSpecies" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> all_mentions_species.list
   grep -P "^T\d+\tGenus" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> all_mentions_genus.list
   grep -P "^T\d+\tStrain" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> all_mentions_strain.list
done
#on mac
# for i in entire-corpus/{train,dev,test}/*.ann; do
#    egrep "^T\d+\tSpecies" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> all_mentions_species.list
#    egrep "^T\d+\tGenus" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> all_mentions_genus.list
#    egrep "^T\d+\tStrain" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> all_mentions_strain.list
# done
cat all_mentions_species.list all_mentions_genus.list all_mentions_strain.list > all_mentions.list

#count
wc -l all_mentions* > counts_all.txt

#### Calculate per category
arr=( "bac" "bot" "ent" "med" "myc" "pro" "vir" "zoo" )
#on linux
for j in "${arr[@]}"; do    
    for i in per-journal-category/${j}/{train,dev,test}/*.ann; do
        grep -P "^T\d+\tSpecies" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> per-journal-category/${j}/${j}_mentions_species.list
        grep -P "^T\d+\tGenus" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> per-journal-category/${j}/${j}_mentions_genus.list
        grep -P "^T\d+\tStrain" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> per-journal-category/${j}/${j}_mentions_strain.list
    done
    cat per-journal-category/${j}/${j}_mentions_species.list per-journal-category/${j}/${j}_mentions_genus.list per-journal-category/${j}/${j}_mentions_strain.list > per-journal-category/${j}/${j}_mentions.list
    wc -l per-journal-category/${j}/${j}_mentions* >> per-journal-category/counts_per_category.txt
done
#on mac
# for j in "${arr[@]}"; do    
#     for i in per-journal-category/${j}/{train,dev,test}/*.ann; do
#         egrep "^T\d+\tSpecies" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> per-journal-category/${j}/${j}_mentions_species.list
#         egrep "^T\d+\tGenus" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> per-journal-category/${j}/${j}_mentions_genus.list
#         egrep "^T\d+\tStrain" ${i}  | perl -pe 's/^T\d+\t\w+\s\d+\s\d+\t(.*)$/$1/' >> per-journal-category/${j}/${j}_mentions_strain.list
#     done
#     cat per-journal-category/${j}/${j}_mentions_species.list per-journal-category/${j}/${j}_mentions_genus.list per-journal-category/${j}/${j}_mentions_strain.list > per-journal-category/${j}/${j}_mentions.list
#     wc -l per-journal-category/${j}/${j}_mentions* >> per-journal-category/counts_per_category.txt
# done

for j in "${arr[@]}"; do  
    wc -l per-journal-category/${j}/${j}_mentions.list
done

### Calculate unique mentions   

#### Calculate for the entire corpus
for i in all_mentions*; do
    echo $i;
    sort -u $i | wc -l 
done

#### Calculate per category

for j in "${arr[@]}"; do   
    echo $j;
    for i in per-journal-category/${j}/${j}_mentions*; do
        echo $i;
        sort -u $i | wc -l 
    done
done

### Calculate number of words with berttokenizer
#### entire corpus
python3 brat_txt_stats.py --dir entire-corpus/ > number_of_words_tok.list

#### per category
for j in "${arr[@]}"; do 
    echo $j;
    python3 brat_txt_stats.py --dir per-journal-category/${j} >> ${j}_number_of_words_tok.list
done

