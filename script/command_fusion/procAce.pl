#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_ace = $ARGV[0];
my $input_contig = $ARGV[1];
my %ID2pairInfo = ();

open(IN, $input_contig) || die "cannot open $!";
$_ = <IN>;
s/[\r\n\"]//g;
my ($contig, $strand, $juncSite) = split("\t", $_);

open(IN, $input_ace) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    
    last if ($_ =~ /$contig/);
}


while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split(" ", $_);

    last if ($_ =~ /^BS/);
    next if (not $F[0]);

    if ($F[0] =~ /^AF/) {

        my $ID = $F[1];
        my $site = $F[3];
        $ID =~ s/\#0\/([12])$//;

        my $readNum = $1 == 1 ? 1 : 2;

        if (not exists $ID2pairInfo {$ID}) {
            $ID2pairInfo{$ID} = [(0) x 5];
        }

        if ($F[2] eq "U") {
            $ID2pairInfo{$ID}->[0] = $site;
        } else {
            $ID2pairInfo{$ID}->[2] = $site;
        }

        if ($F[2] eq "C" and $readNum == 1) {
            $ID2pairInfo{$ID}->[4] = 1;
        }
    }
}


my $tempID = "";
my $tempReadNum = "";

while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split(" ", $_);
    last if ($_ =~ /^CO/);
    next if (not $F[0]);
    
    if ($F[0] =~ /^RD/) {
        $tempID = $F[1];
        $tempID =~ s/\#0\/([12])$//;
        $tempReadNum = $1 == 1 ? 1 : 2;
    }
 
    if ($F[0] =~ /^QA/) {
        my $slength = $F[2] - $F[1] + 1;
        if ( ($tempReadNum == 1 and $ID2pairInfo{$tempID}->[4] == 0) or ($tempReadNum == 2 and $ID2pairInfo{$tempID}->[4] == 1) ) {
            $ID2pairInfo{$tempID}->[1] = $slength; 
        }
        if ( ($tempReadNum == 2 and $ID2pairInfo{$tempID}->[4] == 0) or ($tempReadNum == 1 and $ID2pairInfo{$tempID}->[4] == 1) ) {
            $ID2pairInfo{$tempID}->[3] = $slength;
        }   

    }
}
close(IN);    
    

my %duplCheck = ();
for my $ID (sort keys %ID2pairInfo) {
    my @tempInfo = @{$ID2pairInfo{$ID}};
    my $tempStart = $tempInfo[0];
    my $tempEnd = $tempInfo[2] + $tempInfo[3] - 1;

    my $juncType = 0;
    if ($juncSite >= $tempStart and $juncSite < $tempEnd) {
        $juncType = 1;
        if ( ($juncSite >= $tempStart and $juncSite < $tempStart + $tempInfo[1]) or ($juncSite >= $tempInfo[2] and $juncSite < $tempInfo[2] + $tempInfo[3]) ) {
            $juncType = 2;
        }
    }

    if (not exists $duplCheck{$tempStart . "\t" . $tempEnd} and $tempInfo[0] != 0 and $tempInfo[2] != 0 and $tempStart <= $tempEnd) {
        print $ID . "\t" . join("\t", @tempInfo) . "\t" . $juncType . "\n";
    }
    $duplCheck{$tempStart . "\t" . $tempEnd} = 1;
}


