#! /usrlocal/bin/perl
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

    $F[0] =~ /(\w+):[\+\-](\d+)\-(\w+):[\+\-](\d+)/;
    my $chr1 = $1;
    my $pos1 = $2;
    my $chr2 = $3;
    my $pos2 = $4;

    print $chr1 . "\t" . ($pos1 - 5) . "\t" . ($pos1 + 5) . "\t" . $chr2 . "\t" . ($pos2 - 5) . "\t" . ($pos2 + 5) . "\t" . $F[0] . "\t" . "0" . "\t" . "+" . "\t" . "+" . "\n";

}

close(IN);

    

