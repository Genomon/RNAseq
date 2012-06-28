#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input = $ARGV[0];
my $mq_thres = $ARGV[1];
my $sc_thres = $ARGV[2];

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    next if ($F[0] =~ /^@/);
    
    next if ($F[2] =~ /\*/ or $F[6] =~ /\*/);

    if ($F[5] =~ /^(\d+)S/ and $F[4] >= $mq_thres) {
        if ($1 > $sc_thres) {
            my $tseq = substr($F[9], 0, $1);
            my $tqual = substr($F[10], 0, $1);
            print ">" . join("~", @F[0 .. 8]) . "|" . $tseq . "|" . "+" . "|" . $tqual . "\n" . $tseq . "\n";
        }    
    }

    if ($F[5] =~ /(\d+)S$/ and $F[4] >= $mq_thres) {
        if ($1 > $sc_thres) {
            my $tseq = substr($F[9], -$1);
            my $tqual = substr($F[10], -$1);
            print ">" . join("~", @F[0 .. 8]) . "|" . $tseq . "|" . "+" . "|" . $tqual . "\n" . $tseq . "\n";
        }
    }
}
close(IN);
        
         

