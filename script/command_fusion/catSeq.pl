#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;

my $input = $ARGV[0];

my $tempGene = "";
my $tempSeq = "";
open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    $F[0] =~ s/.\d+$//;

    if ($tempGene ne $F[0]) {
        if ($tempGene ne "") {

            print ">" . $tempGene . "\n" . $tempSeq . "\n";
        }
    
        $tempGene = $F[0];
        $tempSeq = "";
    }

    $tempSeq = $tempSeq . $F[1];
}
close(IN);

print ">" . $tempGene . "\n" . $tempSeq . "\n";


