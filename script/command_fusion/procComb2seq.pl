#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input = $ARGV[0];

my %comb2seq = ();
my %comb2ID = ();
open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $comb = $F[0] . "\t" . $F[1];

    if (not exists $comb2seq{$comb}) {
        $comb2seq{$comb} = $F[3];
        $comb2ID{$comb} = $F[2];
    } else {
        $comb2seq{$comb} = $comb2seq{$comb} . "," . $F[3];
        $comb2ID{$comb} = $comb2ID{$comb} . "," . $F[2];
    }
}
close(IN);

foreach my $comb (sort keys %comb2seq) {
    print $comb . "\t" . $comb2ID{$comb} . "\t" . $comb2seq{$comb} . "\n";
}

