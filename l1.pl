#!/usr/bin/perl

my $file = $ARGV[0];

open FILE, $file or die "cannot open file";

my $output = join("", <FILE>);
close FILE;




my @lines = split(/\n/, $output);

my $i =0;
foreach my $line (@lines) {
    print "$i : $line\n";
    $line =~ /(?<label>[^:]+):(?<command>.*)/;
    print "[ $+{label} | $+{command} ]\n";
    print "$+{label}" ;
    print $+{rest};     
    ++$i;
}

