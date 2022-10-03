# Various Scripts for S1000

This repository contains scripts to support different steps of the analyses performed in the S1000 paper. 
It has been split in 6 different directories for clarity

For various scripts it is necessary to set up Jensenlab tagger before invoking them. The tagger and instructions on how to set it up can be found here: https://github.com/larsjuhljensen/tagger

## Corpus extension

As described in the paper, the final revision step of the corpus was its extension with 200 additional documents. There are four scripts in this directory to replicate the process of extension: one shell script (corpus_extension.sh) and three perl scripts (get_organisms_from_swissprot.pl, get_unique_elements_last_column.pl, group_by_genera.pl). You only need to invoke the shell script, but before doing that you need to make sure that you have a working version of tagger in the correct directory. 

```shell
./corpus_extension.sh
```

The script will first gather the necessary files from the uniprot and NCBI FTPs, then get the revised S800 and generate the candidate documents about genera not present in S800. Then for the negative class tagger will be run and 25 documents without any species mentions will be selected. 

## Corpus statistics

## Error analysis of Jensenlab tagger

## Evaluation of Jensenlab tagger

## Large scale tagging

## Plotting