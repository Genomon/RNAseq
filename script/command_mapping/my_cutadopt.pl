#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

$adaSeq1="AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATATCGTATGCCGTCTTCTGCTTG";
$adaSeq2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT";

if ($ARGV[0] == 1) {
    $adaSeq = $adaSeq1;
} elsif ($ARGV[0] == 2) {
    $adaSeq = $adaSeq2;
} else {
    die "Put 1 or 2 for choosing the adaptor sequence!";
}


%summary = ();
open(IN, $ARGV[2]) || die "cannot open $!";
open(OUT, ">" . $ARGV[3]) || die "cannot open $!";
while(<IN>) {

    s/[\r\n]//g;
    $ID = $_;

    $_ = <IN>;
    s/[\r\n]//g;
    $seq = $_;

    $_ = <IN>;
    s/[\r\n]//g;
    $ID2 = $_;

    $_ = <IN>;
    s/[\r\n]//g;
    $qual = $_;

    $Nseq = length($seq);
    
    $flag = 0;
    $n = index($seq, substr($adaSeq, 0, $ARGV[1]));
    if ($n > -1) {
        
        if ($Nseq - $n - 1 < length($adaSeq)) {
            $adaLength = $Nseq - $n;
        } else {
            $adaLength = length($adaSeq);
        }
        if ( substr($seq, $n, $adaLength) eq substr($adaSeq, 0, $adaLength)) {
            
            $flag = 1;
       
            if ($adaLength == length($adaSeq)) {

                if ($n <= 10) {
                    substr($seq, 10, $Nseq - 10) = "";
                    substr($qual, 10, $Nseq - 10) = "";
                    $summary{$Nseq - 10} = $summary{$Nseq - 10} + 1;
                } else { 
                    substr($qual, $n, $Nseq - $n) = ""; 
                    substr($seq, $n, $Nseq - $n) = "";
                    $summary{$Nseq - $n} = $summary{$Nseq - $n} + 1;
                }

            } else {
                substr($seq, $n, $adaLength) = "";
                substr($qual, $n, $adaLength) = "";
                $summary{$adaLength} = $summary{$adaLength} + 1;
            }

        }
    }


    if ($flag == 0) {
        $summary{"0"} = $summary{"0"} + 1;
    }

    if ($ID ne "") {
        print OUT $ID . "\n" . $seq . "\n" . $ID2 . "\n" . $qual . "\n";
    } 

}
close(IN);
close(OUT);

open(OUT, ">" . $ARGV[4]) || die "cannot open $!";
foreach $num (sort {$a<=>$b} keys %summary) {
    print OUT $num . "\t" . $summary{$num} . "\n";
}

