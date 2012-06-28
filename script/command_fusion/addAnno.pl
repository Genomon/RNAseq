#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input = $ARGV[0];
my $anno1 = $ARGV[1];
my $anno2 = $ARGV[2];

my %junc2anno1 = ();
my %junc2anno2 = ();
open(IN, $anno1) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $junc2anno1{$F[0]} = $F[1];
}
close(IN);

open(IN, $anno2) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $junc2anno2{$F[0]} = $F[1];
}
close(IN);


open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $janno1 = exists $junc2anno1{$F[0]} ? $junc2anno1{$F[0]} : "---";
    my $janno2 = exists $junc2anno2{$F[0]} ? $junc2anno2{$F[0]} : "---";

    print join("\t", @F) . "\t" . $janno1 . "\t" . $janno2 . "\n";
}
close(IN);
