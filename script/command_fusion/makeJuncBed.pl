#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input = $ARGV[0];

my $chr1 = "";
my $pos1 = "";
my $strand1 = "";
my $chr2 = "";
my $pos2 = "";
my $strand2 = "";

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);


    $F[0] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)/;
    $chr1 = $1;
    $pos1 = $3;
    $strand1 = $2;

    $chr2 = $4;
    $pos2 = $6;
    $strand2 = $5; 

    my $start1 = 0;
    my $end1 = 0;
    if ($strand1 eq "+") {
        $start1 = $pos1 - 24;
        $end1 = $pos1;
    } else { 
        $start1 = $pos1 - 1;
        $end1 = $pos1 + 23;
    }

    my $start2 = 0;
    my $end2 = 0;
    if ($strand2 eq "+") {
        $start2 = $pos2 - 24;
        $end2 = $pos2;
    } else {
        $start2 = $pos2 - 1;
        $end2 = $pos2 + 23;
    }

    print $chr1 . "\t" . $start1 . "\t" . $end1 . "\t" . $chr1 . ":" . $strand1 . $pos1 . "\n";
    print $chr2 . "\t" . $start2 . "\t" . $end2 . "\t" . $chr2 . ":" . $strand2 . $pos2 . "\n";
}
close(IN);
    

