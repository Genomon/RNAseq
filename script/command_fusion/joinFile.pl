#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $aFile = $ARGV[0];
my $bFile = $ARGV[1];
my $aNum = 0;
my $bNum = 0;


my %bhash = ();

open(BINPUT,$bFile) || die "can't open $bFile";
while(<BINPUT>){
    chomp;
    my $bline = $_;
    my @blineArr = split(/\t/,$bline);
    my $targetB  = $blineArr[$bNum];
    $bhash{$targetB} = $blineArr[$bNum + 1];
}
close(BINPUT);

open(AINPUT,$aFile) || die "can't open $aFile";
while(<AINPUT>){
    chomp;
    my $aline = $_;
    my @alineArr = split(/\t/,$aline);
    my $targetA  = $alineArr[$aNum];
    if (exists($bhash{$targetA})){
        print $aline ."\t". $bhash{$targetA} . "\n";
    }
}
close(AINPUT);

