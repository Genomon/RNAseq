#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#
#

use strict;
use warnings;

my $input = $ARGV[0];
my %junc2gene = ();

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if ($F[6] =~ /chr/) {

        if (not exists $junc2gene{$F[3]}) {
            $junc2gene{$F[3]} = $F[9];
        } else {
            $junc2gene{$F[3]} = $junc2gene{$F[3]} . "," . $F[9];
        } 

    }
}
close(IN);


foreach my $junc (sort keys %junc2gene) {
    print $junc . "\t" . $junc2gene{$junc} . "\n";
}

