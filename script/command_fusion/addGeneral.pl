#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_list = $ARGV[0];
my $input_anno = $ARGV[1];
my $annoNum = $ARGV[2];

my %key2anno = ();
# my $annoNum = 0;
open(IN, $input_anno) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $key2anno{$F[0]} = join("\t", @F[1 .. $#F]);
#     $annoNum = $#F;
}
close(IN);

open(IN, $input_list) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my $pairNum = exists $key2anno{$F[0]} ? $key2anno{$F[0]} : join("\t", ("---")x$annoNum);
    print join("\t", @F) . "\t" . $pairNum . "\n";
}
close(IN);
