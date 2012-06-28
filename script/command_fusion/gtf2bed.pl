#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;

my $input = $ARGV[0];

my %newGenes  = ();
my $newGeneNum = 0;
open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;  
    my @F = split("\t", $_);

    next if ($F[2] eq "transcript");

    $F[8] =~ /transcript_id (CUFF\.\d+\.\d+)/;
    my $transcriptID = $1;

    $F[8] =~ /exon_number (\d+)/;
    my $ExonNum = ($1 - 1);

    print $F[0] . "\t" . ($F[3] - 1) . "\t" . $F[4] . "\t" . $transcriptID . "." . $ExonNum . "\n";
 
}

close(IN);

