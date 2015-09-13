#!/usr/bin/perl
use Data::Dumper;
use strict;

my $file = $ARGV[0];
open FILE, $file or die "cannot open file";
my $output = join("", <FILE>);
close FILE;



my @metalines;
my %labels;

my @lines = split(/\n/,$output);
my $i = 0;
my $curraddr = 0;
foreach my $line (@lines) {
print "debug.line = /$line/\n";
    my @labels = split(/:/, $line);
    my $cmd;
    my $label;
    if( (scalar @labels) == 1 ){
	$cmd = $labels[0];
	$label = undef;
    }elsif ( (scalar @labels ) == 2 ){
	$label = $labels[0];
	$cmd = $labels[1];
    }elsif ( $line =~ /^[ \t]*$/ ) {
	next;
    }else{
	print "compilatino error: unrecognise line [$line]\n";
	die();
    }
    $label =~ s/^\s+|\s+$//g;
    $cmd =~ s/^\s+|\s+$//g;

print "debug. label=$label, cmd=$cmd\n";

    my @args = split(/[ \t]+/, $cmd );
    
    if( (scalar @args) < 1 ) { 
	die("compilation error: wrong line $line\n");
    }    

    my $name = $args[0];
    if( $name eq "copy" ) {
	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code => [ 1 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 3;
		
    }elsif ( $name eq "not" ) { 
	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code => [ 2 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 3;


    }elsif ($name eq "or" ) {

	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code => [ 3 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 4;


    }elsif($name eq "and" ) {


	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code => [ 4 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 4;



    }elsif($name eq "ifjmp" ) {


	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code => [ 5 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 4;


    }elsif($name eq "db" ) {
	
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code =>[ hex($args[1]) ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 1;
	
    }elsif($name eq "idle" ) {
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code =>[ 6 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 1;
    }elsif($name eq "exit" ) {
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code =>[ 7 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate $label\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 1;


    }else{
	die("compilatin error: wrong line $line\n");
    }    

    $i++;
}

my @binary;

foreach my $metaline (@metalines) {
    my %metaline = %{$metaline};
    if( $metaline{args} ) {
	my @a = @{$metaline{args}};
	foreach my $a (@a) {
	    if( $labels{$a} ) {
		push(@$metaline{code}, $labels{$a});
	    }else{
		die("compilatino error: unknown label $a\n");
	    }
	} 
    }	
    @binary = (@binary,  @{$metaline{code}});

}

my $filebin = $file;
$filebin =~ s{\.[^.]+$}{};
$filebin = $filebin . ".bin";
open FILE  , ">". $filebin or die("error: cannot open file [$filebin]\n");
    
foreach my $b (@binary) {
    printf(FILE  "%x ", $b);
}

close FILE;

print Dumper(\@metalines);
print Dumper(\%labels);
print Dumper(\@binary);


