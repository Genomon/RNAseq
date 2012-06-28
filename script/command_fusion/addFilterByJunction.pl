#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input_anno = $ARGV[0];
my $input_filter = $ARGV[1];

my %ID2filter = ();
open(IN, $input_filter) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if ($F[0] =~ s/_contig1$//) {

        if (not exists $ID2filter{$F[0]}) {
            $ID2filter{$F[0]} = [("not aligned") x 4];
        }

        $ID2filter{$F[0]}->[0] = ($F[1] ne "") ? $F[1] : "---";
        $ID2filter{$F[0]}->[1] = $F[2];

    }

    if ($F[0] =~ s/_contig2$//) {

        if (not exists $ID2filter{$F[0]}) {
            $ID2filter{$F[0]} = [("not aligned") x 4];
        }

        $ID2filter{$F[0]}->[2] = ($F[1] ne "") ? $F[1] : "---";
        $ID2filter{$F[0]}->[3] = $F[2];
    }

}
close(IN);


open(IN, $input_anno) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    if (not exists $ID2filter{$F[0]}) {
        $ID2filter{$F[0]} = [("not aligned") x 4];
    }
    
    print join("\t", @F) . "\t" . join("\t", @{$ID2filter{$F[0]}}) . "\n";
}
close(IN);
