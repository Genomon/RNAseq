#! /usr/loca/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

# making the list of the sequence IDs for each candidate junction combination 

use strict;
use warnings;

my $input_comb = $ARGV[0];
my $input_junc2ID = $ARGV[1];

my %junc2ID = ();
open(IN, $input_junc2ID) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $junc2ID{$F[0]} = $F[1];
}
close(IN);

$DB::single = 1;

my %comb2ID = ();
my %comb2segSeq = ();

open(IN, $input_comb) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $comb = $F[0];
    my $junc1 = $F[1];
    my $junc2 = $F[4];

    my @IDs = (split(",", $junc2ID{$junc1}) , split(",", $junc2ID{$junc2}) );
    if (exists $junc2ID{$junc1}) {
        $DB::single = 1;
    }

    if ($junc1 ne $junc2) {
        my %count;
        @IDs = grep {!$count{$_}++} @IDs;
        $comb2ID{$comb} = join(",", @IDs);
        $comb2segSeq{$comb} = $F[11];
   }
}
close(IN);

foreach my $comb (sort keys %comb2ID) {

    print $comb . "\t" . $comb2segSeq{$comb} . "\t" . $comb2ID{$comb} . "\n";
}

