#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input = $ARGV[0];
my $input_primer = $ARGV[1];
# my $input_cuff = $ARGV[2];

my %ID2seq = ();
my %seq2gene = ();
open(IN, $input_primer) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    my @FF = split("---", $F[0]);

    if (not exists $ID2seq{$FF[0]}) {
        $ID2seq{$FF[0]} = $F[1];
    } else {
        $ID2seq{$FF[0]} = $ID2seq{$FF[0]} . ";" . $F[1];
    }

    if (not exists $seq2gene{$F[1]}) {
        $seq2gene{$F[1]} = $FF[1];
    } else {
        $seq2gene{$F[1]} = $seq2gene{$F[1]} . ";" . $FF[1];
    }   
   
}
close(IN);

$DB::single = 1;
   
foreach my $ID (keys %ID2seq) {
    my @seqs = split(";", $ID2seq{$ID});
    my %count = ();
    @seqs = grep {!$count{$_}++} @seqs;
    @seqs = sort {length($b) <=> length($a)} @seqs;
    $ID2seq{$ID} = join(";", @seqs);
}


$DB::single = 1;


print "primary junction" . "\t" . "extended contig1" . "\t" . "extended contig2" . "\n";
open(IN, $input) || die "cannot open$!";
# $_ = <IN>;
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    my @exContig1 = ();
    my @exContig2 = ();

    if (exists $ID2seq{$F[0] . "_contig1"}) {

        my @seqs = split(";", $ID2seq{$F[0] . "_contig1"});
        foreach my $seq (@seqs) {
            push @exContig1, $seq . "[" . $seq2gene{$seq} . "]";
        }
    }

    if (exists $ID2seq{$F[0] . "_contig2"}) {
        
        my @seqs = split(";", $ID2seq{$F[0] . "_contig2"});
        foreach my $seq (@seqs) {
            push @exContig2, $seq . "[" . $seq2gene{$seq} . "]";
        }   
    }

    my $texContig1 = $#exContig1 >= 0 ? join(";", @exContig1) : "---";
    my $texContig2 = $#exContig2 >= 0 ? join(";", @exContig2) : "---";

    print $F[0] . "\t" . $texContig1 . "\t" . $texContig2 . "\n";
}
close(IN);


            

