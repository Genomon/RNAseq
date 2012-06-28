#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input_txt = $ARGV[0];
my $input_selfChain = $ARGV[1];

my %delRaws = ();
open(IN, $input_selfChain) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $key = $F[6];
    $delRaws{$key} = 1;
}
close(IN);

open(IN, $input_txt) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $key =$F[0];
    if (exists $delRaws{$key}) {
        print join("\t", @F) . "\t" . "chain self" . "\n";
    } else {
        print join("\t", @F) . "\t" . "---" . "\n";
    }

}
close(IN);

