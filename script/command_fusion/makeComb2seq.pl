#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_comb2ID = $ARGV[0];
my $input_sam = $ARGV[1];

my %ID2comb = ();
open(IN, $input_comb2ID) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
   
    my @IDs = split(",", $F[2]);
    for (my $i = 0; $i <= $#IDs; $i++) {
        $ID2comb{$IDs[$i]} = $F[0] . "\t" . $F[1];
    }
}
close(IN);

my %comb2seq = ();
my %comb2ID = ();

open(IN, $input_sam) || die "cannot open $!";
while(<IN>) {

    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    
    next if ($F[0] =~ /^@/);
    
    my @flags = split("", sprintf("%011b", $F[1]));
    my $seq = $flags[-5] == 1 ? complementSeq($F[9]) : $F[9];
    my $readNumTag = $flags[-7] == 1 ? "#0/1" : "#0/2";


    if (exists $ID2comb{$F[0]}) {

        my $comb = $ID2comb{$F[0]};

        if (not exists $comb2seq{$comb}) {
            $comb2seq{$comb} = $seq;
            $comb2ID{$comb} = $F[0] . $readNumTag;
        } else {
            $comb2seq{$comb} = $comb2seq{$comb} . "," . $seq;
            $comb2ID{$comb} = $comb2ID{$comb} . "," . $F[0] . $readNumTag;
        }
    
    }
}
close(IN);


foreach my $comb (sort keys %comb2seq) {
    print $comb . "\t" . $comb2ID{$comb} . "\t" . $comb2seq{$comb} . "\n";
}



sub complementSeq {

    my $tseq = reverse($_[0]);
 
    $tseq =~ s/A/S/g;
    $tseq =~ s/T/A/g;
    $tseq =~ s/S/T/g;

    $tseq =~ s/C/S/g;
    $tseq =~ s/G/C/g;
    $tseq =~ s/S/G/g;

    return $tseq;
}



