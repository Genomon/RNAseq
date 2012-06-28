#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input_list = $ARGV[0];
my $input_contig = $ARGV[1];

my %comb2contig = ();
my $comb = "";
open(IN, $input_contig) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
   
    if ($_ =~ s/^>//) {
        $comb = $_;
    } else {
        $comb2contig{$comb} = $_;
    }
}
close(IN);

open(IN, $input_list) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my @contigs = split("\t", $comb2contig{$F[0]});

    
    while($#contigs < 2) {
        push @contigs, "---";
    }        

    print join("\t", @F) . "\t" . join("\t", @contigs) .  "\n";

}

close(IN); 
