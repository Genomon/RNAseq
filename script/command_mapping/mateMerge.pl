#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
# use warnings;
use List::Util qw(sum);

my $input1 = $ARGV[0];
my $input2 = $ARGV[1];

open(IN1, $input1) || die "cannot open $!";
open(IN2, $input2) || die "cannot open $!";


while(<IN1>) {
    s/[\r\n\"]//g;
    my @F1 = split("\t", $_);

    $_ = <IN2>;
    s/[\r\n\"]//g;
    my @F2 = split("\t", $_);

    # remove the read number in the ID
    $F1[0] =~ s/\/1$//;
    $F2[0] =~ s/\/2$//;

    # for casava 1.8
    $F1[0] =~ s/_1:N:\d+:[ACGT]+$//;
    $F2[0] =~ s/_2:N:\d+:[ACGT]+$//;


    if ($F1[0] ne $F2[0]) {
        print $F1[0] . "\t" . $F2[0] . "\n";
        die "The order of the reads is wrong!";
    }

    # add mate read site informatin
    if ($F1[2] ne "*") {

        if ($F1[2] ne $F2[2]) {
            $F2[6] = $F1[2];
        } else {
            $F2[6] = "=";
        }
        $F2[7] = $F1[3];

    }
    if ($F2[2] ne "*") {

        if ($F2[2] ne $F1[2]) {
            $F1[6] = $F2[2];
        } else {
            $F1[6] = "=";
        }
        $F1[7] = $F2[3];
    }

    # calculate the insert size
    my $isize = 0;
    if ($F1[2] eq $F2[2]) {
        if ($F1[1] == 0 and $F2[1] == 16) {
            $isize = $F2[3] + sum($F2[5] =~ /(\d+)[MDN]/g) - $F1[3];
            $F1[8] = $isize;
            $F2[8] = - ($isize);
        }
        if ($F2[1] == 0 and $F1[1] == 16) {
            $isize = $F1[3] + sum($F1[5] =~ /(\d+)[MDN]/g) - $F2[3];
            $F2[8] = $isize;
            $F1[8] = - ($isize);
        }   
    }            

    # change flags
    my $flag1 = $F1[1] + 1 + 64;    # first in pair
    my $flag2 = $F2[1] + 1 + 128;   # second in pair

    # check if the reads are mapped in proper pair
    if ($isize > 0 and $isize < 100000) {
            $flag1 += 2;
            $flag2 += 2;
    }

    # check if the mate is unmapped or not 
    $flag1 += 8 if $F2[1] == 4;
    $flag2 += 8 if $F1[1] == 4;

    # check if the mate read is in reverse strand or not
    $flag1 += 32 if $F2[1] == 16;
    $flag2 += 32 if $F1[1] == 16;

    $F1[1] = $flag1;
    $F2[1] = $flag2;

    
    print join("\t", @F1) . "\n";
    print join("\t", @F2) . "\n";

}
close(IN1);
close(IN2);
# close(OUT);


