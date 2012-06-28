#! /usr/local/bin/perl
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

use strict;
use warnings;

my $input_fasta = $ARGV[0];
my $num = $ARGV[1];

my %rand2key = ();
open(IN, $input_fasta) || die "cannot open $!";
while(<IN>) {
    s/[\r\n\"]//g;
    my $ID = $_;

    $_ = <IN>;
    s/[\r\n\"]//g;
    my $seq = $_;

    $rand2key{rand()} = $ID . "\n" . $seq;
}
close(IN);


my $tnum = 0;
foreach my $rnum (sort {$a <=> $b} keys %rand2key) {
    print $rand2key{$rnum} . "\n";
    $tnum = $tnum + 1;
    if ($tnum == $num) {
        exit;
    }
}

