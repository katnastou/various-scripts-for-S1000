#!/usr/bin/perl -w

use strict;
open (my $fh, "<", "PMIDs_grouped_by_genera_not_unique.tsv") or die $!;
open (OUT, ">", "PMIDs_grouped_by_genera_unique.tsv") or die $!;
# my @all_pmids="";
while(<$fh>){
	my ($parent_taxid, $type, $PMIDs) = split(/\t/,$_);
	chomp $PMIDs;
	my @pmids = split(/; /,$PMIDs);
	my @unique = uniq( @pmids );
	my $PMIDs_uniq = join ("; ", @unique);
	# push(@all_pmids,@unique);
	print OUT "$parent_taxid\t$type\t$PMIDs_uniq\n";
}

# my @uniqueall = uniq( @all_pmids );
# print (join ("\n", @uniqueall));

sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}