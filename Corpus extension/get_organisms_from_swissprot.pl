#!/usr/bin/perl -w

use strict;

open (IN, "<", "uniprot_sprot.dat");
open (IN2, "<", "unique_annotated_species_genus_and_species_genera.tsv");
open (OUT, ">", "uniprot_organisms_fields_papers.tsv");
open (OUTBOT, ">", "papers_botany.tsv");
open (OUTZOO, ">", "papers_zoology.tsv");
open (OUTBAC, ">", "papers_bacteriology.tsv");
open (OUTVIR, ">", "papers_virology.tsv");
open (OUTPAR, ">", "papers_parasitology.tsv");
open (OUTFUN, ">", "papers_mycology.tsv");
open (OUTINS, ">", "papers_entomology.tsv");
my @names="";
my @taxids="";
while (<IN2>){
	#34	Myxococcus xanthus	species
	my ($taxid, $name, $type) = split /\t/;
	push (@names, $name);
	push (@taxids, $taxid);
}

$/="//\n";
while (<IN>) {
	my $os="";
	my $description="";
	my $counter=0;
	my $bot=0;
	my $zoo=0;
	my $bac=0;
	my $vir=0;
	my $par=0;
	my $fun=0;
	my $ins=0;
	if ($_=~/\nDE   (.*)\nGN/s) {
		$description=$1;		
		$description=~s/DE   / /g;
		$description=~s/\n//g;
	}
	if ($_=~/^OS   (.*)\nOC/s) {
		$os=$1;		
		$os=~s/OS   / /g;
		$os=~s/\n//g;
		#print "$os\t";
	}
	my $lineage="";
	if ($_=~/   (.*)\nOX/s) {
		$lineage=$1;		
		$lineage=~s/OC   / /g;
		$lineage=~s/\n//g;
		# print "$lineage\t";
	}

	for (my $i=0;$i<$#names;$i++){
		if ($lineage =~ /$names[$i]/){
			$counter++;
			# print $names[$i];
		}
	}
	if ($counter==0){
		#do a double check, first for lineage to remove genus and then for taxid to remove species
		if ($_=~/   NCBI_TaxID=(\d+).*;/m){
			my $taxid=$1;
			for (my $i=0;$i<$#taxids;$i++){
				if ($taxids[$i] =~ /$taxid/){
					$counter++;
				}
			}
			if ($counter==0){
				print OUT "$os\t$taxid\t";
				if ($lineage =~ /Viridiplantae/){
					print OUT "Botany\t";
					$bot++;
				}
				elsif($lineage =~ /Insecta/){
					print OUT "Entomology\t";
					$ins++;
				}
				elsif($lineage =~ /Metazoa/){
					print OUT "Zoology\t";
					$zoo++;
				}
				elsif($lineage =~ /Bacteria/){
					print OUT "Bacteriology\t";
					$bac++;
				}
				elsif($lineage =~ /Viruses/){
					print OUT "Virology\t";
					$vir++;
				}
				elsif($lineage =~ /Fungi/){
					print OUT "Mycology\t";
					$fun++;
				}
				#if it's none of the above BUT it is Eukaryotes
				elsif($lineage =~ /Eukaryota/){
					print OUT "Parasitology\t";
					$par++;
				}
				while ($_ =~ /PubMed[=|:](\d+)/g){
					print OUT $1."; ";
					print OUTBAC $1."\n" if $bac>0;
					print OUTZOO $1."\n" if $zoo>0;
					print OUTVIR $1."\n" if $vir>0;
					print OUTBOT $1."\n" if $bot>0;
					print OUTFUN $1."\n" if $fun>0;
					print OUTPAR $1."\n" if $par>0;
					print OUTINS $1."\n" if $ins>0;
				}
				while ($description =~ /PubMed[=|:](\d+)/g){
					print OUT $1."; ";
					print OUTBAC $1."\n" if $bac>0;
					print OUTZOO $1."\n" if $zoo>0;
					print OUTVIR $1."\n" if $vir>0;
					print OUTBOT $1."\n" if $bot>0;
					print OUTFUN $1."\n" if $fun>0;
					print OUTPAR $1."\n" if $par>0;
					print OUTINS $1."\n" if $ins>0;
				}
				print OUT "\n";
			}
		}
		
	}
	
}
close IN;
close IN2;
close OUT;
close OUTBAC;
close OUTZOO;
close OUTVIR;
close OUTBOT;
close OUTFUN;
close OUTPAR;
close OUTINS;