#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

use List::Util qw(min);
my $input = $ARGV[0];

my $epsilon = 0.02;
 
my $tempKey = "";
my @tempReads = ();
my %XAtag2exists = ();


open(IN, $input) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;  
    my @F = split("\t", $_);

    # remove filter information
    $F[0] =~ s/\s[\S]+//;
    
    if ($F[0] =~ /^\@/) {
        
        print join("\t", $_) . "\n";
    
    } elsif ($F[0] ne $tempKey) {

        if ($#tempReads >= 0) { 
            &printInfo( \@tempReads );
        }

        $tempKey = $F[0];
        @tempReads = ();
        %XAtag2exists = ();

        (my $ID, my $sam_key, my $score, my $XAtag) = &getSamInfo(\@F);
        push @tempReads, [$ID, $sam_key, $score, $XAtag];
        $XAtag2exists{$XAtag} = 1;

    } else {

        (my $ID, my $sam_key, my $score, my $XAtag) = &getSamInfo(\@F);
        if (not exists $XAtag2exists{$XAtag}) {
            push @tempReads, [$ID, $sam_key, $score, $XAtag];
            $XAtag2exists{$XAtag} = 1;
        }

    }

}
close(IN);

if ($#tempReads >= 0) {
    &printInfo( \@tempReads );
}



sub getSamInfo {

    my @F = @{$_[0]};
    my $ID = $F[0];

    my $strand = "+";
    if ($F[1] == 16) {
        $strand = "-";
    } 

    my $cigar = $F[5];

    my $number_of_match_mismatch = 0;
    while($cigar =~ /(\d+)M/g) {
        $number_of_match_mismatch = $number_of_match_mismatch + $1;
    }

    my $infoBar = join("\t", @F[10..$#F]);
    $infoBar =~ /NM:i:(\d+)/;
    my $number_of_mismatch = $1 || 0;

    my $XAtag = join(",", ($F[2], $strand . $F[3], $F[5], $number_of_mismatch));

    return ($ID, \@F, $number_of_match_mismatch - $number_of_mismatch, $XAtag);
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
    # print $mapScore . "\n";
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


