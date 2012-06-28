#! /usr/loca/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use strict;
use warnings;

my $input = $ARGV[0];
my $seqFile = $ARGV[1];

my %key2seq = ();
open(IN, $seqFile) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $key2seq{$F[0]} = $F[1];
}
close(IN);


open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    $F[0] =~ /(\w+:[\+\-]\d+)\-(\w+:[\+\-]\d+)/;
    my $key1 = $1;
    my $key2 = $2;

    $key1 =~ /\w+:([\+\-])\d+/;
    my $dir1 = $1;

    $key2 =~ /\w+:([\+\-])\d+/;
    my $dir2 = $1;


    my $seq = "";
    if ($dir1 eq "+" and $dir2 eq "+") {
        $seq = $key2seq{$key1} . &complementSeq($key2seq{$key2});
    }

    if ($dir1 eq "+" and $dir2 eq "-") {
        $seq = $key2seq{$key1} . $key2seq{$key2};
    }

    if ($dir1 eq "-" and $dir2 eq "+") {
        $seq = &complementSeq($key2seq{$key1}) . &complementSeq($key2seq{$key2});
    }

    if ($dir1 eq "-" and $dir2 eq "-") {
        $seq = &complementSeq($key2seq{$key1}) . $key2seq{$key2};
    }

    print join("\t", @F) . "\t" . $seq . "\n";
}


sub complementSeq {

    my $tseq = reverse($_[0]);

    $tseq =~ s/A/S/g;
    $tseq =~ s/T/A/g;
    $tseq =~ s/S/T/g;

    $tseq =~ s/C/S/g;
    $tseq =~ s/G/C/g;
    $tseq =~ s/S/G/g;

    return $tseq;
}

