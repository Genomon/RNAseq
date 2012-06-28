#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input = $ARGV[0];
open(IN, $input) || die "cannot open $!";

while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my $flag = 0;

    if ($F[0] =~ /chrM/ or $F[3] =~ /chrM/) {
        $flag = 1;
    }

    my @genes1 = split(",", $F[7]);
    my @genes2 = split(",", $F[8]);

    for (my $i = 0; $i <= $#genes1; $i++) {
        for (my $j = 0; $j <= $#genes2; $j++) {

            if ($genes1[$i] eq $genes2[$j] and $genes1[$i] ne "---") {
                $flag = 1;
            }

        }
    }    

    if ($flag == 0) {
        print join("\t", @F) . "\n";
    }

}
    
