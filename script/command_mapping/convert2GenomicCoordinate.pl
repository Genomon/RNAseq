#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
# use warnings;

my $inputSam = $ARGV[0];
my $inputDB = $ARGV[1];

my %known2chr = ();
my %known2start = ();
my %known2site = ();
my %known2gap = ();

open(IN, $inputDB) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    $known2chr{$F[0]} = $F[1];
    $known2start{$F[0]} = $F[2];
    $known2site{$F[0]} = $F[3];
    $known2gap{$F[0]} = $F[4];
}
close(IN);


open(IN, $inputSam) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $flag = $F[1];
    
    if ($F[0] =~ /^\@/) {
        # skip header line

    } elsif ($flag != 4) {

        my $known  = $F[2];
        my $start  = $F[3];
        my $length = $F[5];
        $length =~ s/M//g;
        my $tempSite = $start;
        my $chr = $known2chr{$known};

        my @knownStarts = split(",", $known2start{$known});
        my @knownSites  = split(",", $known2site{$known});
        my @knownGaps   = split(",", $known2gap{$known});

        my $cigar = "";
        my $tind = 0;
        while($knownSites[$tind] < $start) {    
            $tind = $tind + 1;
        }
        my $gstart = $knownStarts[$tind - 1] + ($start - $knownSites[$tind - 1]);

        while($knownSites[$tind] < $start + $length - 1 and $tind < $#knownSites) {
            $cigar = $cigar . ($knownSites[$tind] - $tempSite + 1) . "M";
            $cigar = $cigar . $knownGaps[$tind - 1] . "N";
            $tempSite = $knownSites[$tind] + 1;
            $tind = $tind + 1;
        }
        
        if ($start + $length - $tempSite > 0) {
            $cigar = $cigar . ($start + $length - $tempSite) . "M";
        }

        print $F[0] . "\t" . $flag . "\t" . $chr . "\t" . $gstart . "\t" . $F[4] . "\t" . $cigar . "\t" . join("\t", @F[6 .. $#F]) . "\n";     

    } else {
        print join("\t", @F) . "\n";
    } 

}
close(IN);
