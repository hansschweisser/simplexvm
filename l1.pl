#!/usr/bin/perl
use Data::Dumper;
use strict;

#
# TODO:
#
# - change all 'if's checking existence of variable, from if($variabel) to if(defined $variable)
#


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
    $i++;
    my @labels = split(/:/, $line);
    my $cmd;
    my $label;
    if ( $line =~ /^[ \t]*$/ ) {
	next;
    }elsif( (scalar @labels) == 1 ){
	$cmd = $labels[0];
	$label = undef;
    }elsif ( (scalar @labels ) == 2 ){
	$label = $labels[0];
	$cmd = $labels[1];
    }else{
	die  "compilation error: unrecognise line '$line', line $i\n";
    }
    if($label){
        $label =~ s/^\s+|\s+$//g;
    }
    $cmd =~ s/^\s+|\s+$//g;


    my @args = split(/[ \t]+/, $cmd );
    
    if( (scalar @args) < 1 ) { 
	die("compilation error: wrong line '$line', empty line, line $i\n");
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
		die("compilation error: label duplicate '$label', line $i\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 3;
    }elsif ( $name eq "offset" ) {
	if( not defined $args[1] ) { die("compilation error: no argument to offset\n"); }
	$curraddr = hex($args[1]);
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
		die("compilation error: label duplicate '$label', line $i\n");
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
		die("compilation error: label duplicate '$label', line $i\n");
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
		die("compilation error: label duplicate '$label', line $i\n");
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
		die("compilation error: label duplicate '$label', line $i\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 4;

    }elsif($name eq "ifjmp2" ) {

	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code => [ 8 ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate '$label', line $i\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 4;


    }elsif($name eq "db" ) {
	
	my @a;
	for(my $i=1;$i<scalar(@args);++$i){	
	    push(@a, $args[$i]);
	}
	
	push(@metalines, {
	    nr => $i,
	    name => $name,
	    code =>[ ],
	    label => ($label? $label : undef ),
	    address => $curraddr,
	    args => \@a,
	} );
	if( $label ) {
	    if( $labels{$label} ) { 
		die("compilation error: label duplicate '$label', line $i\n");
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
		die("compilation error: label duplicate '$label', line $i\n");
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
		die("compilation error: label duplicate '$label', line $i\n");
	    }
	    $labels{$label} = $curraddr;
	}
	$curraddr+= 1;


    }else{
	die("compilatin error: wrong line '$line', line $i\n");
    }    


}

print "debug.\@metalines = " . Dumper(\@metalines);
my @binary;

foreach my $metaline (@metalines) {
    my %metaline = %{$metaline};

    if( $metaline{args} ) {
	my @a = @{$metaline{args}};
	foreach my $a (@a) {
	    if( defined $labels{$a} ) {
		push(@$metaline{code}, $labels{$a});
	    }elsif( $a =~ /0x[0-9a-fA-F]+/ ) {
		push(@$metaline{code}, hex($a));
	    }else{
		die("compilation error: unknown label '$a' (line $metaline{nr})\n");
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

#print Dumper(\@metalines);
#print Dumper(\%labels);
#print Dumper(\@binary);


