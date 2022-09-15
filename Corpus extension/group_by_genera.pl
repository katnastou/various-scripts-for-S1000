#!/usr/bin/perl -w

use strict;
#OBS! FILE HAS TO BE SORTED BY COLUMN 1!
open (my $fh, "<", "uniprot_parent_taxid_species-taxid_category_PMIDs.tsv") or die $!;
open (OUT, ">", "PMIDs_grouped_by_genera_not_unique.tsv") or die $!;
my $previous_line = <$fh>; 
my $counter=0;
while(my $current_line = <$fh>){
	chomp $current_line;
	chomp $previous_line;
	my ($parent_taxid, $species_taxid, $type, $PMIDs) = split(/\t/,$current_line);
	my ($parent_taxid_prev, $species_taxid_prev, $type_prev, $PMIDs_prev) = split(/\t/,$previous_line);
	if (defined $PMIDs_prev){
		if ($PMIDs_prev ne ""){
			#if the first columns do not match
			if ($parent_taxid ne $parent_taxid_prev){
				#when the last thing you had was matching cases add the last element of that
				if($counter>0){
					print OUT "$PMIDs_prev\n";
				}
				#the first time you come back from printing you don't want to print the previous line 
				#because it is already included in the last print
				else{
					print OUT "$parent_taxid_prev\t$type_prev\t$PMIDs_prev\n";
				}
				$counter=0;
			}
			elsif ($parent_taxid eq $parent_taxid_prev){
				#if it's the first time these are equal
				if ($counter==0){
					print OUT "$parent_taxid_prev\t$type_prev\t$PMIDs_prev";
					$counter++;
				}
				else {
					print OUT "$PMIDs_prev";
					$counter++;
				}
			}
		}
	}
	#assign current line into previous line before it go to next line
	$previous_line = $current_line; 
}

close($fh);

