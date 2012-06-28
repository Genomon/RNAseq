#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_bowtie = $ARGV[0];
my $input_blat = $ARGV[1];

open(IN_bowtie, $input_bowtie) || die "cannot open $!";
open(IN_blat, $input_blat) || die "cannot open $!";

while(<IN_blat>) {

    s/[\r\n\"]//g;
    $_ =~ s/ HWI-EAS\d+:\d+:\d+:\d+:\d+ length=\d+//;
    my @F1 = split("\t", $_);


    while(<IN_bowtie>) {

        s/[\r\n\"]//g;
        $_ =~ s/ HWI-EAS\d+:\d+:\d+:\d+:\d+ length=\d+//;
        my @F2 = split("\t", $_);


        if ($F1[0] eq $F2[0]) {
            print join("\t", @F1) . "\n";
            last;
        } else {
            print join("\t", @F2) . "\n";
        }
    }
}


        
while(<IN_bowtie>) {
    print $_;
}        
 
close(IN_bowtie);
close(IN_blat); 
