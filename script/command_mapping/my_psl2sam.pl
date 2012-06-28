#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#
# Author: lh3
#
# This script calculates a score using the BLAST scoring
# system. However, I am not sure how to count gap opens and gap
# extensions. It seems to me that column 5-8 are not what I am
# after. This script counts gaps from the last three columns. It does
# not generate reference skip (N) in the CIGAR as it is not easy to
# directly tell which gaps correspond to introns.

use strict;
use warnings;
use List::Util qw(min);
our $epsilon = 0.02;

my $inputPsl = $ARGV[0];
my $inputFa =  $ARGV[1];
my $readGroup = $ARGV[2];
my $spliceThres = $ARGV[3];


my @Infos = ();
my $tempID = "";
open(IN1, $inputPsl) || die "cannot open $!";
open(IN2, $inputFa) || die "cannot open $!";
while (<IN1>) {

    next unless (/^\d/);

    my ($ID, $sam_key, $score, $XAtag) = &getSamInfo($_);

    if ($ID ne $tempID) {

        if ($#Infos >= 0) {    
            while(<IN2>) {
                s/[\r\n\"]//g;
                last if (/$tempID/);
                if (/^>/) {
                    s/^>//;
                    my @F = split("\\|", $_);
                    $F[0] =~ s/^\@//;
                    my @tempInfos = ($F[0], 4, "*", 0, 0, "*", "*", 0, 0, $F[1], $F[3]);
                    if ($readGroup ne "") {
                        push @tempInfos, "RG:Z:" . $readGroup; 
                    }
                    print join("\t", @tempInfos) . "\n";
                }    
            }
            
            &printInfo( \@Infos );
        }
    
        $tempID = $ID;
        @Infos = ();

    }     

    push @Infos, [$ID, $sam_key, $score, $XAtag];


}

while(<IN2>) {
    s/[\r\n\"]//g;
    last if (/$tempID/);
    if (/^>/) {
        s/^>//;
        my @F = split("\\|", $_);
        $F[0] =~ s/^\@//;
        my @tempInfos = ($F[0], 4, "*", 0, 0, "*", "*", 0, 0, $F[1], $F[3]);
        if ($readGroup ne "") {
            push @tempInfos, "RG:Z:" . $readGroup;
        }
        print join("\t", @tempInfos) . "\n";
    }    
}  
&printInfo( \@Infos );


while(<IN2>) {
    s/[\r\n\"]//g;
    if (/^>/) {
        s/^>//;
        my @F = split("\\|", $_);
        $F[0] =~ s/^\@//;
        my @tempInfos = ($F[0], 4, "*", 0, 0, "*", "*", 0, 0, $F[1], $F[3]);
        if ($readGroup ne "") { 
            push @tempInfos, "RG:Z:" . $readGroup;
        }   
        print join("\t", @tempInfos) . "\n";
    }    
}   






sub printInfo {

    my @tInfos = @{$_[0]};

    my @sorted_ind = sort { $tInfos[$b]->[2] <=> $tInfos[$a]->[2] } 0..$#tInfos;
    my @Infos_sort = @tInfos[@sorted_ind];

    my @XAtags = ();
    my @scores = ($Infos_sort[0]->[2]);
    for (my $i = 1; $i <= $#Infos_sort; $i++) {
        push @XAtags, $Infos_sort[$i]->[3];
        push @scores, $Infos_sort[$i]->[2];
    }

    my $mapScore = int( min(100, &getMapScore($epsilon, \@scores) ) );
    $Infos_sort[0]->[1]->[4] = $mapScore;

    if ($#XAtags >= 0) {
        print join("\t", @{$Infos_sort[0]->[1]}) . "\t" . "XA:Z:" . join(";", @XAtags[0..min($#XAtags, 9)]) . ";" . "\n";
    } else {
        print join("\t", @{$Infos_sort[0]->[1]}) . "\n";
    }


}


sub getMapScore {

    my $eps = $_[0];
    my @tscores = @{$_[1]};
    
    # print join("\t", @tscores) . "\n";
    # print "check!\n";    
    my $tnum = 0;

    for (my $i = 1; $i <= $#tscores; $i++) {
        $tnum += $eps ** ($tscores[0] - $tscores[$i]);
    }
    
    # print $tnum . "\n";
    
    if ($tnum == 0) {
        return 100;
    } else {         
        return - 10 * log($tnum / (1 + $tnum)) / log(10);
    }
}





sub getSamInfo {

    my @t = split("\t", $_[0]);
    my @s;
    my $cigar = '';

    my ($ID, $seq, $ID2, $qual) = split("\\|", $t[9]);
    $ID =~ s/^\@//;
    if ($t[8] eq "-") {
        $seq = &complementSeq($seq);
        $qual = reverse($qual);
    }

    if ($t[8] eq '-') {
        my $tmp = $t[11];
        $t[11] = $t[10] - $t[12];   # start for - strand
        $t[12] = $t[10] - $tmp; # end for - strand
    }

    @s[0..4] = ($ID, (($t[8] eq '+')? 0 : 16), $t[13], $t[15]+1, 0);    # QNAME, FLAG, reference sequence, position, mapping quality
    @s[6..10] = ('*', 0, 0, $seq, $qual);    # pair reference, pair position, template length, sequence bases, sequence quality


    $cigar .= $t[11].'S' if ($t[11]); # 5'-end clipping

    my @x = split(',', $t[18]);
    my @y = split(',', $t[19]);
    my @z = split(',', $t[20]);
    my ($y0, $z0) = ($y[0], $z[0]);
    my ($gap_open, $gap_ext) = (0, 0, 0);
    my $number_of_mismatch = $t[1] + $t[3];

    for (1 .. $t[17]-1) {
     
        my $ly = $y[$_] - $y[$_-1] - $x[$_-1];
        my $lz = $z[$_] - $z[$_-1] - $x[$_-1];
        
        
        # modified by Y.S
        $cigar .= $x[$_-1] . 'M';
        if ($ly > 0) { # ins: query gap is longer than the block size
            ++$gap_open;
            $gap_ext += $ly;
            $cigar .= $ly . 'I';
            $number_of_mismatch += $ly;
        }
        if ($lz > 0) { # ins: query gap is longer than the block size
            ++$gap_open;
            $gap_ext += $lz;
            if ($lz <= $spliceThres) {
                $cigar .= $lz . 'D';
                $number_of_mismatch += $lz;
            } else {
                $cigar .= $lz . 'N';
            }
        }

    }

    $cigar .= $x[$#x] . 'M';
    $cigar .= ($t[10] - $t[12]).'S' if ($t[10] != $t[12]); # 3'-end clipping
    $s[5] = $cigar;

    
    if ($readGroup ne "") {
        $s[11] = "RG:Z:" . $readGroup . "\t" . "NM:i:$number_of_mismatch";        
    } else {
        $s[11] = "NM:i:$number_of_mismatch";
    }
 
    my $my_score = $t[0] - $number_of_mismatch;
    my $XAtag = join(",", ($s[2], $t[8] . $s[3], $cigar, $number_of_mismatch)) ;
    return ($ID, \@s, $my_score, $XAtag);

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


