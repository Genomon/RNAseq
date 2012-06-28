#! /usr/loca/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;
use List::Util qw(max);

my $input = $ARGV[0];

my $output1 = $ARGV[1];
my $output2 = $ARGV[2];

my $chr1 = "";
my $pos1 = "";
my $strand1 = "";
my $chr2 = "";
my $pos2 = "";
my $strand2 = "";


open(IN, $input) || die "cannot open $!";
open(OUT1, ">" . $output1) || die "cannot open $!";
open(OUT2, ">" . $output2) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    next if (not $F[0] =~ /(\w+):([\+\-])(\d+)/);

    $F[0] =~ /(\w+):([\+\-])(\d+)-(\w+):([\+\-])(\d+)/;
    $chr1 = $1;
    $pos1 = $3;
    $strand1 = $2;

    $chr2 = $4;
    $pos2 = $6;
    $strand2 = $5;

    print OUT1 $chr1 . "\t" . max(0, $pos1 - 5) . "\t" . ($pos1 + 5) . "\t" . $F[0] . "\t" . join("\t", @F[1 .. 2]) . "\n";
    print OUT2 $chr2 . "\t" . max(0, $pos2 - 5) . "\t" . ($pos2 + 5) . "\t" . $F[0] . "\t" . join("\t", @F[1 .. 2]) . "\n";

}
