#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;

my $input = $ARGV[0];

my %seqIDs = ();
open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    if ($_ =~ s/^>//) {
        my $seqID = $_;
        $seqID =~ s/\#0\/[12]$//;
        $seqIDs{$seqID} = $seqIDs{$seqID} + 1;
    }
}
close(IN);

foreach my $seqID (sort keys %seqIDs) {
    
    if ($seqIDs{$seqID} == 2) {
        print $seqID . "#0/1" . "\t" . $seqID . "#0/2" . "\t" . 0 . "\t" . 1000 . "\n";
    }
}


