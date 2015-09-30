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
    $val = convert_to_hex($val);
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
	my $end = pop(@endstack);
	my %end = %{$end};
	if( $end{type} eq "if" ){
	    push(@output, {type=>"label", name=>$end{index},});
	}
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
	push(@namespace,[]);
	if( $cmd[1] and (not $cmd[2]) ){
	    my $vi = get_index_of_variable($cmd[1]);
	    my $tmp = get_tmp_var("0x0");
	    my $ifindex = get_var_index();
	    push(@endstack,{type=>"if", arg1=> $vi , arg2 => $tmp , index=>$ifindex,});
	    push(@output, {type=>"if", arg1=> $vi, arg2 => $tmp, index=>$ifindex,});
	}else{
	    die "compilation error: not recognised 'if' statement";
	}
	
    }
    
}

foreach my $var (@variables){
    my %var = %{$var};
    my $index = $var{index};
    my $value = $var{value};
    push(@output, {code=>"$index: db $value",});
}

foreach my $var (@output) {
    if( ! $var->{code} ){
	if( $var->{type} eq "label" ){
	    $var->{code} = "$var->{name}: idle";
	}elsif ($var->{type} eq "if" ){
	    $var->{code} = "ifjmp $var->{arg1} $var->{arg2} $var->{index}";
	}else{
	    die "compilation error: unknown line type $var->{type}";
	}	
    }	
}

my @code ;
my $code;
foreach my $var (@output) {
    push(@code,$var->{code});
    $code .= "$var->{code}\n";
}
#print $code;



#print Dumper(\@variables);
#print Dumper(\@namespace);


#print Dumper(\@output);


sub convert_to_hex()
{
    
    my ($value) = @_;
    if( ($value =~ /^0x[0-9a-fA-f]+$/) ){
	return sprintf("0x%x", hex($value));
    }else{
	die "compilation error: unknown format of number $value";
    }
}



my $filebin = $file;
$filebin =~ s{\.[^.]+$}{};
$filebin = $filebin . ".l1";
open FILE  , ">". $filebin or die("error: cannot open file [$filebin]\n");
printf(FILE "%s", $code);
close FILE;
