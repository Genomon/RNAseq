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

    my $line = "";
    if ($F[9] =~ /contig1$/ and $F[10] -$F[12] < 5) {

        if ($F[8] eq "+") {
            $line = $F[13] . ":" . "+" . ($F[16] + $F[10] -$F[12]);
        } else {
            $line = $F[13] . ":" . "-" . ($F[15] + $F[10] -$F[12] + 1);
        }

    } elsif ($F[9] =~ /contig2$/ and $F[11] < 5 ) {

        if ($F[8] eq "+") {
            $line = $F[13] . ":" . "-" . ($F[15] + $F[11] + 1);
        } else {
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


my %comb2inframe = ();
foreach my $key (sort keys %key2line1) {
    foreach my $line1 (split(";", $key2line1{$key})) {
        foreach my $line2 (split(";", $key2line2{$key})) {

            $line1 =~ /([\w\(\)\.]+):([\+\-])(\d+)/;
            my $gene1 = $1;
            my $dir1 = $2;
            my $pos1 = $3;

            $line2 =~ /([\w\(\)\.]+):([\+\-])(\d+)/;
            my $gene2 = $1;
            my $dir2 = $2;
            my $pos2 = $3;

            next if ($gene2coding_start{$gene1} eq $gene2coding_end{$gene1});
            next if ($gene2coding_start{$gene2} eq $gene2coding_end{$gene2}); 
            
            if ($gene1 =~ /uc002izc/ or $gene2 =~ /BCAS4/) {
                $DB::single = 1;
            }

            my $cdir1 = $dir1 eq $gene2coding_strand{$gene1} ? "+" : "-";
            my $cpos1 = $gene2coding_strand{$gene1} eq "+" ? $pos1 - $gene2coding_start{$gene1} : $gene2coding_end{$gene1} - $pos1;

            my $cdir2 = $dir2 eq $gene2coding_strand{$gene2} ? "+" : "-";
            my $cpos2 = $gene2coding_strand{$gene2} eq "+" ? $pos2 - $gene2coding_start{$gene2} : $gene2coding_end{$gene2} - $pos2;
            

            $cpos1 = $cdir1 eq "+" ? $cpos1 + 1 : $cpos1;
            $cpos2 = $cdir2 eq "+" ? $cpos2 + 1 : $cpos2;

            if ($cpos1 >= 0 and $cpos2 >= 0 and $cdir1 ne $cdir2 and $cpos1 % 3 == $cpos2 % 3) {
                if (exists $comb2inframe{$key}) {
                    $comb2inframe{$key} = $comb2inframe{$key} . "," . $gene1 . "-" . $gene2;
                } else {
                    $comb2inframe{$key} = $gene1 . "-" . $gene2;
                }
            }
        }
    }
}
        

foreach my $comb (sort keys %comb2inframe) {
    print $comb . "\t" . $comb2inframe{$comb} . "\n";
}
