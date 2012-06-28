#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_contigs = $ARGV[0];
my $input_selected = $ARGV[1];

my $contigSeq = "";
my $contigSeq_1 = "";
my $contigSeq_2 = "";

open(IN, $input_selected) || die "cannot open $!";
$_ = <IN>;
s/[\r\n\"]//g;
my ($selectedContig, $strand, $juncSite) = split("\t", $_);
close(IN);


open(IN, $input_contigs) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    last if ($_ =~ /$selectedContig/);
}

while(<IN>) {
    s/[\r\n\"]//g;
    last if ($_ =~ /^>/);
    if ($contigSeq eq "") {
        $contigSeq = $_;
    } else {
        $contigSeq = $contigSeq . $_;
    }
}
close(IN);
        

$contigSeq_1 = substr($contigSeq, 0, $juncSite);
$contigSeq_2 = substr($contigSeq, $juncSite, length($contigSeq) - $juncSite);
 
if ($strand eq "+") {
    print $contigSeq . "\t" . $contigSeq_1 . "\t" . $contigSeq_2 . "\n";
} else {
    print &complementSeq($contigSeq) . "\t" . &complementSeq($contigSeq_2) . "\t" . &complementSeq($contigSeq_1) . "\n";
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

