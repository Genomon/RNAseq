#! /usr/loca/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input = $ARGV[0];
open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    # remove filter information
    $F[0] =~ s/\s[\S]+//;    

    my $ID = $F[0];
    my $seq = $F[9];
    my $qual = $F[10];
    my $ID2 = "+";

    if ($F[1] eq 4) {
        print ">" . $ID . "|" . $seq . "|" . $ID2 . "|" . $qual . "\n" . $seq . "\n";
    }
}
close(IN);
