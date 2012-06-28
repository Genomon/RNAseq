#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


use File::Basename qw/basename dirname/;

use strict;
use warnings;

my $seq = $ARGV[0];
my $comb2ID_list = $ARGV[1];
my $mq_thres = $ARGV[2];

my $tempDir = dirname $comb2ID_list;

my %comb2ID = ();
my %comb2segSeq = ();
open(IN, $comb2ID_list) || die "cannot open $!";
while(<IN>) {

    s/[\r\n\"]//g;
    my @cF = split("\t", $_);

    my $input_junc = $cF[0];
    my $segSeq = $cF[1];
    my $comb = $input_junc;
    print STDERR $comb . "\n";

    $comb2ID{$comb} = $cF[2];
    $comb2segSeq{$comb} = $segSeq;

    $input_junc =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)/;
    my $junc11_chr = $1;
    my $junc11_pos = $3;
    my $junc11_strand = $2;
    my $junc12_chr = $4;
    my $junc12_pos = $6;
    my $junc12_strand = $5;


    if ($junc11_strand eq "+") {
        my $start = $junc11_pos - 100;
        my $end = $junc11_pos;
    
        print STDERR "samtools view " . $seq . " " . $junc11_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam" . "\n";
        system("samtools view " . $seq . " " . $junc11_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam");
    } else {
        my $start = $junc11_pos;
        my $end = $junc11_pos + 100;

        print STDERR "samtools view " . $seq . " " . $junc11_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam" . "\n";
        system("samtools view " . $seq . " " . $junc11_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam");
    }


    open(IN1, $tempDir . "/temp_junc.sam") || die "cannot open $!";
    while(<IN1>) {
        s/[\r\n\"]//g;
        my @F = split("\t", $_);
        my @flags = split("", sprintf("%011b", $F[1]));

        if ($F[4] >= $mq_thres) {
            next;
        }

        my $pair1_chr = $F[2];
        my $pair1_pos = $F[3];
        my $pair2_chr = $F[6] eq "=" ? $pair1_chr : $F[6];
        my $pair2_pos = $F[7];
        my $pair1_strand = $flags[-5] == 1 ? "-" : "+";
        my $pair2_strand = $flags[-6] == 1 ? "-" : "+";

        if ($pair2_chr eq $junc12_chr and $pair1_strand eq $junc11_strand and $pair2_strand eq $junc12_strand) {
            if ($junc12_strand eq "+") {
                my $tempStart = $junc12_pos - 500000;
                my $tempEnd = $junc12_pos;
                if ($pair2_pos >= $tempStart and $pair2_pos <= $tempEnd) {
                    if (exists $comb2ID{$comb}) {
                        $comb2ID{$comb} = $comb2ID{$comb} . "," . $F[0];
                    } else {
                        $comb2ID{$comb} = $F[0];
                    }
                }
            } else {
                my $tempStart = $junc12_pos;
                my $tempEnd = $junc12_pos + 500000;
                if ($pair2_pos >= $tempStart and $pair2_pos <= $tempEnd) {
                    if (exists $comb2ID{$comb}) {
                        $comb2ID{$comb} = $comb2ID{$comb} . "," . $F[0];
                    } else {
                        $comb2ID{$comb} = $F[0];
                    }
                }
            }
        }
    }
    close(IN1);


    $input_junc =~ /(\w+):([\+\-])(\d+)\-(\w+):([\+\-])(\d+)/;
    my $junc22_chr = $1;
    my $junc22_pos = $3;
    my $junc22_strand = $2;
    my $junc21_chr = $4;
    my $junc21_pos = $6;
    my $junc21_strand = $5;

    if ($junc21_strand eq "+") {
        my $start = $junc21_pos - 100;
        my $end = $junc21_pos;

        print STDERR "samtools view " . $seq . " " . $junc21_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam" . "\n";
        system("samtools view " . $seq . " " . $junc21_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam");
    } else {
        my $start = $junc21_pos;
        my $end = $junc21_pos + 100;

        print STDERR "samtools view " . $seq . " " . $junc21_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam" . "\n";
        system("samtools view " . $seq . " " . $junc21_chr . ":" . $start . "-" . $end . " > " . $tempDir . "/temp_junc.sam");
    }

    open(IN2, $tempDir . "/temp_junc.sam") || die "cannot open $!";
    while(<IN2>) {
        s/[\r\n\"]//g;
        my @F = split("\t", $_);
        my @flags = split("", sprintf("%011b", $F[1]));

        if ($F[4] >= $mq_thres) {
            next;
        }

        my $pair1_chr = $F[2];
        my $pair1_pos = $F[3];
        my $pair2_chr = $F[6] eq "=" ? $pair1_chr : $F[6];
        my $pair2_pos = $F[7];
        my $pair1_strand = $flags[-5] == 1 ? "-" : "+";
        my $pair2_strand = $flags[-6] == 1 ? "-" : "+";

        if ($pair2_chr eq $junc22_chr and $pair1_strand eq $junc21_strand and $pair2_strand eq $junc22_strand) {
            if ($junc22_strand eq "+") {
                my $tempStart = $junc22_pos - 500000;
                my $tempEnd = $junc22_pos;
                if ($pair2_pos >= $tempStart and $pair2_pos <= $tempEnd) {
                    if (exists $comb2ID{$comb}) {
                        $comb2ID{$comb} = $comb2ID{$comb} . "," . $F[0];
                    } else {
                        $comb2ID{$comb} = $F[0];
                    }
                 }
            } else {
                my $tempStart = $junc22_pos;
                my $tempEnd = $junc22_pos + 500000;
                if ($pair2_pos >= $tempStart and $pair2_pos <= $tempEnd) {
                    if (exists $comb2ID{$comb}) {
                        $comb2ID{$comb} = $comb2ID{$comb} . "," . $F[0];
                    } else {
                        $comb2ID{$comb} = $F[0];
                    }
                }
            }
        }
    }
    close(IN2);

}

foreach my $comb (sort keys %comb2ID) {

    my @tIDs = split(",", $comb2ID{$comb});
    my %count = ();
    @tIDs = grep {!$count{$_}++} @tIDs;

    print $comb . "\t" . $comb2segSeq{$comb} . "\t" . $comb2ID{$comb} . "\n";
}



system("rm " . $tempDir . "/temp_junc.sam");

