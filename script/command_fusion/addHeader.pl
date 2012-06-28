#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

print "final junction" . "\t" . "primary junction" . "\t" . "\#consistent read1 (primary)" . "\t" . "\#consistent read2 (primary)" . "\t";
print "pair junction" . "\t" . "\#consistent read1 (pair)" . "\t" . "\#consistent read2 (pair)" . "\t";
print "junction sequence" . "\t" . "gene (primary)" . "\t" . "gene (pair)" . "\t" . "known edge (primary)"  . "\t" . "known edge (pair)" . "\t";
print "chain self" . "\t" . "contig" . "\t" . "contig1" . "\t" . "contig2" . "\t" . "multi map1" . "\t" . "cross map1" . "\t" . "multi map2" . "\t" . "cross map2" . "\t" . "pairNum" . "\t";
print "extended contig1" . "\t" . "extended contig2" . "\t" . "inframe pair" . "\t" . "gene region1" . "\t" . "gene region2" . "\n";

my $input = $ARGV[0];

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    print $_;
}
close(IN);
    

