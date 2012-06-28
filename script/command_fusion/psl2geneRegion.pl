#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use List::Util qw(min max);
use strict;

my $input = $ARGV[0];
my $input_coding = $ARGV[1];

my %gene2coding_start = ();
my %gene2coding_end = ();
my %gene2coding_strand = ();
open(IN, $input_coding) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);
    $gene2coding_start{$F[3]} = $F[1];
    $gene2coding_end{$F[3]} = $F[2];
    $gene2coding_strand{$F[3]} = $F[5];
}
close(IN);

my %key2score1 = ();
my %key2line1 = ();
my %key2score2 = ();
my %key2line2 = ();

open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my @F = split("\t", $_);

    next if (not $F[0] =~ /^\d/);
    # next if (($F[8] eq "+" and $F[10] ne $F[12]) or ($F[8] eq "-" and $F[11] != 0));

    my $line = "";
    if ($F[9] =~ /contig1$/ and $F[10] -$F[12] < 5) {

        if ($F[8] eq "+") {
            $line = $F[13] . ":" . "+" . ($F[16] + $F[10] -$F[12]);
            # $line = $F[13] . "\t" . max(1, $F[16] - 200) . "\t" . $F[16] . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "+";
        } else {
            $line = $F[13] . ":" . "-" . ($F[15] + $F[10] -$F[12] + 1);
            # $line = $F[13] . "\t" . $F[15] . "\t" . min($F[15] + 200, $F[14]) . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "-";
            # print $F[13] . "\t" . max(1, $F[16] - 200) . "\t" . $F[16] . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "-" . "\n";
        }

    } elsif ($F[9] =~ /contig2$/ and $F[11] < 5 ) {

        if ($F[8] eq "+") {
            $line = $F[13] . ":" . "-" . ($F[15] + $F[11] + 1);
            # $line = $F[13] . "\t" . $F[15] . "\t" . min($F[15] + 200, $F[14]) . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "+";
        } else {
            # $line = $F[13] . "\t" . max(1, $F[16] - 200) . "\t" . $F[16] . "\t" . $F[9] . "---" . $F[13] . "\t" . 0 . "\t" . "-";
            $line = $F[13] . ":" . "+" . ($F[16] + $F[11]);
        }

    }


    if ($line ne "") {

        if ($F[9] =~ s/_contig1$//) {

            if (not exists $key2score1{$F[9]} or $F[0] > $key2score1{$F[9]}) {
                $key2score1{$F[9]} = $F[0];
                delete $key2line1{$F[9]}; 
            }

            if (not exists $key2line1{$F[9]}) {
                $key2line1{$F[9]} = $line;
            } else {
                $key2line1{$F[9]} = $key2line1{$F[9]} . ";" . $line;
            }
        }

        if ($F[9] =~ s/_contig2$//) {
        
            if (not exists $key2score2{$F[9]} or $F[0] > $key2score2{$F[9]}) {
                $key2score2{$F[9]} = $F[0];
                delete $key2line2{$F[9]};
            }
        
            if (not exists $key2line2{$F[9]}) {
                $key2line2{$F[9]} = $line;
            } else {
                $key2line2{$F[9]} = $key2line2{$F[9]} . ";" . $line;
            }
        }

    }

}
close(IN);


my %comb2geneRegion1 = ();
foreach my $key (sort keys %key2line1) {
    foreach my $line (split(";", $key2line1{$key})) {

        $line =~ /([\w\(\)\.]+):([\+\-])(\d+)/;
        my $gene = $1;
        my $dir = $2;
        my $pos = $3;


        my $geneRegion = "";
        if ($gene2coding_start{$gene} eq $gene2coding_end{$gene}) {
            $geneRegion = "noncoding";
        } else {

            my $cdir = $dir eq $gene2coding_strand{$gene} ? "+" : "-";

            if ($cdir eq "+") {
                if ($pos <= $gene2coding_start{$gene}) {
                    $geneRegion = "5UTR";
                } elsif ($pos > $gene2coding_end{$gene}) {
                    $geneRegion = "3UTR";
                } else {
                    $geneRegion = "coding";
                }
            } else {

                if ($pos <= $gene2coding_start{$gene}) {
                    $geneRegion = "3UTR";
                } elsif ($pos > $gene2coding_end{$gene}) {
                    $geneRegion = "5UTR";
                } else {
                    $geneRegion = "coding";
                }
            }

        }

        if (exists $comb2geneRegion1{$key}) {
            $comb2geneRegion1{$key} = $comb2geneRegion1{$key} . "," . $gene . ":" . $geneRegion;
        } else {
            $comb2geneRegion1{$key} = $gene . ":" . $geneRegion;
        }

    }
}
        

my %comb2geneRegion2 = ();
foreach my $key (sort keys %key2line2) {
    foreach my $line (split(";", $key2line2{$key})) {

        $line =~ /([\w\(\)\.]+):([\+\-])(\d+)/;
        my $gene = $1;
        my $dir = $2;
        my $pos = $3;


        my $geneRegion = "";
        if ($gene2coding_start{$gene} eq $gene2coding_end{$gene}) {
            $geneRegion = "noncoding";
        } else {

            my $cdir = $dir eq $gene2coding_strand{$gene} ? "+" : "-";

            if ($cdir eq "+") {
                if ($pos <= $gene2coding_start{$gene}) {
                    $geneRegion = "5UTR";
                } elsif ($pos > $gene2coding_end{$gene}) {
                    $geneRegion = "3UTR";
                } else {
                    $geneRegion = "coding";
                }
            } else {
    
                if ($pos <= $gene2coding_start{$gene}) {
                    $geneRegion = "3UTR";
                } elsif ($pos > $gene2coding_end{$gene}) {
                    $geneRegion = "5UTR";
                } else {
                    $geneRegion = "coding";
                }
            }
        }

        if (exists $comb2geneRegion2{$key}) {
            $comb2geneRegion2{$key} = $comb2geneRegion2{$key} . "," . $gene . ";" . $geneRegion;
        } else {
            $comb2geneRegion2{$key} = $gene . ";" . $geneRegion;
        }

    }
}


my @combs = (keys %comb2geneRegion1, keys %comb2geneRegion2);
my %count = ();
@combs = grep {!$count{$_}++} @combs;

foreach my $comb (sort @combs) {
    my $geneRegion1 = exists $comb2geneRegion1{$comb} ? $comb2geneRegion1{$comb} : "---";
    my $geneRegion2 = exists $comb2geneRegion2{$comb} ? $comb2geneRegion2{$comb} : "---";
    print $comb . "\t" . $geneRegion1 . "\t" . $geneRegion2 . "\n";
}



