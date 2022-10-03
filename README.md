# Various Scripts for S1000

This repository contains scripts to support different steps of the analyses performed in the S1000 paper. 
It has been split in 6 different directories for clarity

For various scripts it is necessary to set up Jensenlab tagger before invoking them. The tagger and instructions on how to set it up can be found [here](https://github.com/larsjuhljensen/tagger)

## Corpus extension

As described in the paper, the final revision step of the corpus was its extension with 200 additional documents. There are four scripts in this directory to replicate the process of extension: one shell script (corpus_extension.sh) and three perl scripts (get_organisms_from_swissprot.pl, get_unique_elements_last_column.pl, group_by_genera.pl). You only need to invoke the shell script, but before doing that you need to make sure that you have a working version of tagger in the correct directory. 

```shell
./corpus_extension.sh
```

The script will first gather the necessary files from the uniprot and NCBI FTPs, then get the revised S800 and generate the candidate documents about genera not present in S800. Then for the negative class tagger will be run and 25 documents without any species mentions will be selected. 

## Corpus statistics

There are three scripts in this directory to replicate the process of calculating corpus statistics as described in the Results and Discussion section of the manuscript. 
Once again you only need to invoke the shell script in the directory.

```shell
./corpus_stats.sh
```

For word counting of the documents BERT basic tokenization is used, with the implementation found [here](https://github.com/spyysalo/bert-vocab-eval).

## Evaluation of Jensenlab tagger

This directory contains several scripts and the process is split in two parts. This process recreates the numbers shown for Jensenlab tagger for Figure 2 in the manuscript. 

The first step is to run tagger on S1000. In order to make sure the results are comparable the text of `database_documents.tsv` is replaced with the text in the S1000 corpus before running tagger. Then tagger is run with the updated organisms dictionary downloaded from Zenodo as described in the manuscript. Afterwards, only species mentions are kept and the tagger2standoff script is used to convert the tagger output to BRAT standoff format. Finally, the text is filtered and aligned and the evaluation script is run on the entire corpus. 

```shell
./run_tagger_on_S1000.sh
```

Finally, to generate the numbers for Figure 2, the evaluation script is run for each category.

```shell
./tagger_eval_per_category.sh
```

## Error analysis of Jensenlab tagger

For the error analysis the evaluation script `evalso.py` is used to detect False Positives and False Negatives in each document of the test set. To invoke the command in the entire Jensenlab tagged corpus using the S1000 annotated corpus as a gold standard a shell script is provided.

```shell
./tagger_error_analysis.sh
```

## Large scale tagging for Jensenlab tagger

For the large scale tagging, the [tagger](https://github.com/larsjuhljensen/tagger) needs to be set up first (See above). Then one needs to execute the shell script and the results that are also available in [Zenodo](add_link_here) can be obtained. 

```shell
./tagger-run.sh
```

## Plotting

To generate the plots for Figure 1 and Figure 2 in the manuscript one needs to execute the following commands

For Figure 1:

```shell
python3 plot_prec_rec_progression.py \
        --input_file=progression_precision_recall.tsv \
        --task="Precision-Recall Plot for Progression" \
        --output_file=progression_plot.pdf
```

For Figure 2:

```shell
python3 plot_prec_rec_s1000.py \
        --ml_method_file=Jouni-species-test-S1000-pr-rec-f1.tsv \
        --jensenlab_method_file=Jensenlab-species-test-S1000-pr-rec-f1.tsv \
        --task="Precision-Recall Plot for S1000" \
        --output_file=S1000_plot.pdf
```

The figures generated from these commands are then further processed in Adobe Illustrator to place the legends properly and do some final polishing. 