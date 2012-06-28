#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use List::Util qw(min max);
use strict;
use warnings;

my $input = $ARGV[0];

my %key2score = ();
my %key2line = ();

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    next if (not $F[0]);
    next if (not $F[0] =~ /^\d/);

    my $line = "";
    if ($F[9] =~ /contig1$/ and $F[10] -$F[12] < 5) {

        if ($F[8] eq "+") {
            $line = $F[13] . "\t" . max(1, $F[16] - 200) . "\t" . $F[16] . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "+";
        } else {
            $line = $F[13] . "\t" . $F[15] . "\t" . min($F[15] + 200, $F[14]) . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "-";
        }

    } elsif ($F[9] =~ /contig2$/ and $F[11] < 5 ) {

        if ($F[8] eq "+") {
            $line = $F[13] . "\t" . $F[15] . "\t" . min($F[15] + 200, $F[14]) . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "+";
        } else {
            $line = $F[13] . "\t" . max(1, $F[16] - 200) . "\t" . $F[16] . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "-";
        }

    }

    if ($line ne "") {

        if (not exists $key2score{$F[9]} or $F[0] > $key2score{$F[9]}) {
            $key2score{$F[9]} = $F[0];
            delete $key2line{$F[9]}; 
        }

        if (not exists $key2line{$F[9]}) {
            $key2line{$F[9]} = $line;
        } else {
            $key2line{$F[9]} = $key2line{$F[9]} . ";" . $line;
        }

    }

}
close(IN);

foreach my $key (sort keys %key2line) {
    foreach my $line (split(";", $key2line{$key})) {
        print $line . "\n";
    }
}
        




