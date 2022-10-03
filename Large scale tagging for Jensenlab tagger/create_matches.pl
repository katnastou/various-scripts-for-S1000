#!/usr/bin/perl -w

use strict;
use POSIX;

my %serial_type_identifier = ();
open IN, "< ../organisms_entities_filtered_cellular.tsv";
while (<IN>) {
	s/\r?\n//;
	my ($serial, $type, $identifier) = split /\t/;
	$serial_type_identifier{$serial} = $type."\t".$identifier;
}
close IN;
open IN, "<", $ARGV[0];
open OUT, ">", $ARGV[1];
while (<IN>) {
	s/\r?\n//;
	my ($document, $paragraph, $sentence, $start, $stop, $match, $type, $serial) = split /\t/;
	print OUT $document, "\t", $paragraph, "\t", $sentence, "\t", $start, "\t", $stop, "\t", $match, "\t", $serial_type_identifier{$serial}, "\n" if exists $serial_type_identifier{$serial};
}
close IN;
close OUT;

close STDERR;
close STDOUT;
POSIX::_exit(0);
