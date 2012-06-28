#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input = $ARGV[0];

my $tempID = "";
my @tempMatches = ();
my $targetMatch = 0;
my $crossMatch = 0;
my %site2Match = ();
my $maxMatchSite = ""; 
open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if (not $F[0]) {
        next;
    }
    if (not $F[0] =~ /^\d/) {
        next;
    }

    if ($F[9] ne $tempID) {

        if ($tempID ne "") {
            print $tempID . "\t" . join(",", grep {$_ ne $maxMatchSite and $targetMatch - $site2Match{$_} <= 3} keys %site2Match) . "\t" . $crossMatch . "\n";
        }

        $tempID = $F[9];
        @tempMatches = ();
        $targetMatch = 0;
        $crossMatch = 0;
        %site2Match = ();
        $maxMatchSite = "";
    }
        
    $site2Match{$F[13] . ":" . $F[15] . "-" . $F[16]} = $F[0];
    push @tempMatches, $F[0];
   
    $F[9] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)_contig([12])/;
    my $contigNum = ($7 == 1) ? 1 : -1;

    my $chr1 = "";
    my $strand1 = "";
    my $pos1 = "";
    my $chr2 = "";
    my $strand2 = "";
    my $pos2 = "";

    if ($contigNum == 1) {
        $chr1 = $1;
        $strand1 = ($2 eq "+") ? 1 : -1;
        $pos1 = $3;
        $chr2 = $4;
        $strand2 = ($5 eq "+") ? 1 : -1;
        $pos2 = $6;
    } else {
        $chr1 = $4;
        $strand1 = ($5 eq "+") ? 1 : -1;
        $pos1 = $6;
        $chr2 = $1;
        $strand2 = ($2 eq "+") ? 1 : -1;
        $pos2 = $3;
    }        


    if ($chr1 eq $F[13]) {
        if ($strand1 == 1 and abs($pos1 - $F[16]) <= 5 or $strand1 == -1 and abs($pos1 - $F[15]) <= 5) {
            if ($contigNum * $strand1 * (($F[8] eq "+") ? 1 : -1) == 1) {
                $targetMatch = $F[0];
                $maxMatchSite = $F[13] . ":" . $F[15] . "-" . $F[16];
            }
        }
    }

    if ($chr2 eq $F[13]) {
        if ($pos2 >= $F[15] - 1000 and $pos2 <= $F[16] + 1000) {
            $crossMatch = $F[0] / $F[10];
        }
    }

}
close(IN); 


if ($tempID ne "") {
    print $tempID . "\t" . join(",", grep {$_ ne $maxMatchSite and $targetMatch - $site2Match{$_} <= 3} keys %site2Match) . "\t" . $crossMatch . "\n";
}




