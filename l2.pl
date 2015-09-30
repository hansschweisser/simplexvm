#!/usr/bin/perl
use Data::Dumper;
use strict;

my $file = $ARGV[0];
open FILE, $file or die "cannot open file";
my $output = join("", <FILE>);
close FILE;

my @outputcode;
my @output;
my @endstack;

my @variables;
my $var_index = 0;
sub get_var_index{
    $var_index++;
    return "var-". ($var_index-1);
}

sub get_tmp_var{
    my ($val) = @_;
    my $index = get_var_index();
    push(@variables,{name=>$index,index=>$index,value=>$val,});
    return $index;
}


my @namespace = ();
sub get_index_of_variable{
    my ($name) = @_;
    for(my $i=(scalar @namespace)-1;$i>=0;$i--){
	my @ns = @{$namespace[$i]};
	foreach my $h (@ns){
	    my %h = %$h;
	    if( $h{name} eq $name ) {
		return $h{index};
	    }
	}
    }
    die "Unknown variable $name\n";
}

sub is_variable{
    my ($name) = @_;
    for(my $i=(scalar @namespace)-1;$i>=0;$i--){
	my @ns = @{$namespace[$i]};
	foreach my $h (@ns){
	    my %h = %{$h};
	    if( $h{name} eq $name ) {
		return 1;
	    }
	}
    }
    return 0;
}

my @lines = split(/\n/, $output);

push ( @namespace, []);

for(my $i=0;$i<(scalar @lines);++$i){
    my $line = $lines[$i];

    $line =~ s/^\s+|\s+$//g;

    my @cmd = split(/\s+/,$line);


    if($cmd[0] eq "var" ){
	my $vindex = get_var_index();
	my $val = "0x0";
	if( $cmd[2] ) {
	    $val = convert_to_hex($cmd[2]);
	}
	push(@variables,{name=>$cmd[1],index=> $vindex, value => $val, });
	my $last = (scalar @namespace) -1;
	push(@{$namespace[(scalar @namespace)-1]},{ name=>$cmd[1],index=>$vindex, });
    }elsif ($cmd[0] eq "begin" ){
	push(@namespace,[]);
	push(@endstack,{type=>"begin",});
    }elsif($cmd[0] eq "end" ){
	pop(@namespace);
	pop(@endstack);
    }elsif($cmd[0] eq "set" ){
	if(! ($cmd[1] && $cmd[2]) ){
	    die "compilation error: set name (value|name)";
	}
	if( ! is_variable($cmd[1]) ){
	    die "compilatin error: $cmd[1] is not a variable";
	}
	if( is_variable($cmd[2]) ){
	    my $vi1 = get_index_of_variable($cmd[1]);
	    my $vi2 = get_index_of_variable($cmd[2]);
	}else{
	    my $vi1 = get_index_of_variable($cmd[1]);
	    my $tmpvar = get_tmp_var($cmd[2]);
	    push(@output, {code=>"copy $tmpvar $vi1",});
	}
    }elsif($cmd[0] eq "if"){
	if( $cmd[1] and (not $cmd[2]) ){
	    
	}
    }
    
}

foreach my $var (@variables){
    my %var = %{$var};
    my $index = $var{index};
    my $value = $var{value};
    push(@output, {code=>"$index: db $value",});
}

#print Dumper(\@variables);
#print Dumper(\@namespace);


print Dumper(\@output);


sub convert_to_hex()
{
    my ($value) = @_;
    return sprintf("0x%x", $value);
}