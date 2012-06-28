#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input = $ARGV[0];
my $numThres = 2;
my $posThres = 10000;

my %junc2Keys = ();

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $num11 = $F[4];
    my $num12 = $F[5];
    my $num21 = $F[10];
    my $num22 = $F[11];

    next if ($num11 + $num12 < $numThres);
    next if ($num21 + $num22 < $numThres);

    # $DB::single = 1;

    $F[3] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr11 = $1;
    my $strand11 = $2 eq "+" ? 1 : -1;
    my $pos11 = $3;
    my $chr12 = $4;
    my $strand12 = $5 eq "+" ? 1 : -1;
    my $pos12 = $6;
    my $clip1 = $7;

    $F[9] =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)\((\w*)\)/;
    my $chr21 = $1;
    my $strand21 = $2 eq "+" ? 1 : -1;
    my $pos21 = $3;
    my $chr22 = $4;
    my $strand22 = $5 eq "+" ? 1 : -1;
    my $pos22 = $6;
    my $clip2 = $7;

    next if($chr11 eq $chr12 and abs($pos11 - $pos12) < $posThres);
    next if($chr21 eq $chr22 and abs($pos21 - $pos22) < $posThres);

    # my $flag = 0;
    # if (length($clip1) > 0) { # and $num11 > 10 and $num12 > 10 and $num21 > 10 and $num22 > 10) {
    # if ($pos11 == 57992065 or $pos21 == 57992065) {
    #     $DB::single = 1;
    #     $flag = 1;
    # }

    if (($chr11 eq $chr22 and $chr21 eq $chr12) and ($strand11 == $strand22 and $strand12 == $strand21)) {

        if (abs($pos11 - $pos22) <= 10 and abs($pos21 - $pos12) <= 10) {
            # if ($flag == 1) {
            #     $DB::single = 1;
            # }
            # if ($strand11 * ($pos11 - $pos22) + $strand12 * ($pos12 - $pos21) == 0 and $clip1 == "" and $clip2 == "") {
            if ($strand11 * ($pos11 - $pos22) + $strand12 * ($pos12 - $pos21) == length($clip2) - length($clip1)) {    

                my $key1 = $F[3] . "\t" . $num11 . "\t" . $num12;
                my $key2 = $F[9] . "\t" . $num21 . "\t" . $num22;

                $junc2Keys{join("\t", sort ($key1, $key2))} = 1;
            }

        }

    }


}
close(IN);

foreach my $key (sort keys %junc2Keys) {
    print $key . "\n";
}
