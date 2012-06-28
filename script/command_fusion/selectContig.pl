#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_fasta = $ARGV[0];
my $input_contig = $ARGV[1];

my $tempScore = -1;
my $tempContig = "";
my $tempJuncSite = 0;
my $tempDir = "+";
my $tempLength = 0;

my %contig2length = ();
my $tempSeq = "";
open(IN, $input_contig) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;

    if (s/^>//) {
        if ($tempSeq ne "") {
            $contig2length{$tempContig} = length($tempSeq);
        }  
        $tempContig = $_;
        $tempSeq = "";
    } else {
        $tempSeq = $tempSeq . $_;
    }
}

if ($tempSeq ne "") {
    $contig2length{$tempContig} = length($tempSeq);
}


close(IN);    



open(IN, $input_fasta) || die "cannot open $!";
while(<IN>) {
    next if (/^\#/);

    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    
    if ($F[11] > $tempScore or $F[11] >= $tempScore and $contig2length{$F[1]} > $tempLength) {

        $tempScore = $F[11];
        $tempContig = $F[1];
        $tempLength = $contig2length{$F[1]};

        my $qstart = 0;
        if ($F[6] < $F[7]) {
            $tempDir = "+";
            $qstart = $F[6];
        } else {
            $tempDir = "-";
            $qstart = $F[7];
        }
   
        $tempJuncSite = $F[8] + (24 - $qstart);
    
    }
}
close(IN);

print $tempContig . "\t" . $tempDir . "\t" . $tempJuncSite . "\n";

  
