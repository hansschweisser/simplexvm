#!/usr/bin/perl
use Data::Dumper;
use strict;


my $file = $ARGV[0];
open FILE, $file or die "cannot open file";
my $output = join("", <FILE>);
close FILE;

my @outputcode;
my @endstack;


my @procnamespace;
sub proc_push {
    my ($entry) = @_;
    my $last = $procnamespace[(scalar @procnamespace)-1];
    push($last , $entry);
}
sub proc_newnamespace {
    push(@procnamespace,[]);
}
sub proc_prevnamespace {
    return pop(@procnamespace);
}
proc_newnamespace();


my @codenamespace;
sub code_push {
    my ($entry) = @_;
    my $last = $codenamespace[(scalar @codenamespace)-1];
    push($last,$entry);
}

sub code_newnamespace {
    push(@codenamespace,[]);
}

sub code_prevnamespace {
    return pop(@codenamespace);
}

code_newnamespace();

my @variables;
my $var_index = 0;
sub get_var_index{
    $var_index++;
    return sprintf("label%04i" , ($var_index-1));
}
push(@variables,{name=>"zero",value=>"0x0",index=>"zero",});


my @procedures;

sub get_tmp_var{
    my ($val) = @_;
    my $index = get_var_index();
    $val = convert_to_hex($val);
    push(@variables,{name=>$index,index=>$index,value=>$val,});
    return $index;
}


my @namespace = ();
sub var_push {
    my ($entry) = @_;
    my $last = $namespace[(scalar @namespace)-1];
    push($last,$entry);
}
sub var_newnamespace{
    push(@namespace,[]);
}
sub var_prevnamespace{
    return pop(@namespace);
}

var_newnamespace();




sub get_index_of{
    my ($db,$name) = @_;
    my @dbl = @{$db};
    for(my $i=(scalar @dbl)-1;$i>=0;$i--){
	my @ns = @{$dbl[$i]};
	foreach my $h (@ns){
	    my %h = %$h;
	    if( $h{name} eq $name ) {
		return $h{index};
	    }
	}
    }
    die "Unknown  get_index_of $name\n";
}







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
	    code_push({type=>"label", name=>$end{index},});
	}
	if( $end{type} eq "proc" ){
	    code_push({type=>"procend", index=>$end{index},name=>$end{index},});
	    my $body = code_prevnamespace();
	    proc_prevnamespace();
	    push(@procedures, { code=> $body, head=>$end,});
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
	    code_push({type=>"copy", arg1=>$vi2, arg2=>$vi1,});
	}else{
	    my $vi1 = get_index_of_variable($cmd[1]);
	    my $tmpvar = get_tmp_var($cmd[2]);
	    code_push({type=>"copy", arg1=>$tmpvar, arg2=> $vi1,});
	}
    }elsif($cmd[0] eq "if"){
	push(@namespace,[]);
	my $ifindex = get_var_index();
	if( $cmd[1] and (not $cmd[2]) ){
	    my $vi = get_index_of_variable($cmd[1]);
	    my $tmp = get_tmp_var("0x0");    
	    push(@endstack,{type=>"if", arg1=> $vi , arg2 => $tmp , index=>$ifindex,});
	    code_push( {type=>"if", arg1=> $vi, arg2 => $tmp, index=>$ifindex,});
	}elsif( $cmd[1] && $cmd[2] ) {
	    if( is_variable($cmd[2]) ){
		my $vi1 = get_index_of_variable($cmd[1]);
		my $vi2 = get_index_of_variable($cmd[2]);
		code_push( {type=>"if", arg1=>$vi1 , arg2 =>$vi2, index=>$ifindex,});
		push(@endstack, {type=>"if", arg1=>$vi1 , arg2 =>$vi2, index=>$ifindex,});		
	    }else{
		my $vi1 = get_index_of_variable($cmd[1]);
		my $tmp = get_tmp_var($cmd[2]);
		push(@endstack,{type=>"if", arg1=> $vi1 , arg2 => $tmp , index=>$ifindex,});
	        code_push( {type=>"if", arg1=> $vi1, arg2 => $tmp, index=>$ifindex,});	
	    }
	}else{
	    die "compilation error: not recognised 'if' statement";
	}
	
    }elsif($cmd[0] eq "else"){
	pop(@namespace);
	push(@namespace,[]);
	
	my $end = pop(@endstack);
	my %end = %{$end};
	if( $end{type} eq "if" ){
	    code_push({type=>"else", label=>$end{index},});
	}else{
	    die "compilation error: expected 'if' before 'else'";
	}
	push(@endstack,$end);
    }elsif($cmd[0] eq "proc"){
	if(not $cmd[1]) {
	    die "compilation error: no name of proc";
	}
	code_newnamespace();
	var_newnamespace();
	my @argin;
	my @argout;
	my $argtype  = 0;	
	my @argindexin;
	my @argindexout;

	my $procindex = get_var_index();

	foreach my $a (2..((scalar @cmd)-1)){
	    my $vi = "proc-var-$cmd[$a]-$procindex";	    
	    if( $cmd[$a] eq "->" ) { $argtype = 1; next; }
	    if( $argtype == 0 ) { push(@argin,$cmd[$a]); push(@argindexin, $vi); }
	    if( $argtype == 1 ) { push(@argout,$cmd[$a]);push(@argindexout, $vi); }
	    
	    push(@variables,{name=>$cmd[$a],index=>$vi,value=>"0x0",}); 
	    var_push({name => $cmd[$a], index=>$vi, });
	}
	    proc_push({name=>$cmd[1], index=>$procindex,});
	    proc_newnamespace();
	    push(@endstack, {type=>"proc", argsin=>\@argin, argsout=>\@argout, index=>$procindex,name=>$cmd[1], argindexin=>\@argindexin, argindexout => \@argindexout,});
	    code_push(  {type=>"prochead", argsin=>\@argin, argsout=>\@argout, index=>$procindex,name=>$cmd[1], argindexin=>\@argindexin, argindexout => \@argindexout,});
	
    }elsif($cmd[0] eq "call"){
	if( not $cmd[1] ) {
	    die "compilation error: call no procedure";
	}
	my @argin;
	my @argout;
	my $inx = get_index_of(\@procnamespace,$cmd[1]);
	my $argtype = 0;
	foreach my $i (2..((scalar @cmd)-1)){
	    if( $cmd[$i] eq "->" ) { $argtype = 1; next; }
	    my $vi = get_index_of_variable($cmd[$i]);
	    if( $argtype == 0 ) { push(@argin, $vi); }
	    if( $argtype == 1 ) { push(@argout, $vi); }
	}
	my @procargin;
	my @procargout;	

	my $found = 0;
	foreach my $p (@procedures){
	    if( $p->{head}->{index} eq $inx ){
		@procargin = @{$p->{head}->{argindexin}};
		@procargout = @{$p->{head}->{argindexout}};
		$found = 1;
		last;
	    }
	}
	if( $found == 0 ) { die "compilation error: unknown function $cmd[1]";}

	code_push({type=>"call", name=>$cmd[1], index=>$inx, argin=>\@argin, argout=>\@argout, argprocin => \@procargin, argprocout => \@procargout,});
    }elsif($cmd[0] eq "idle"){
	code_push({type=>"idle",});
    }else{
	print "unknown line '$line'\n";
    }
    
}

foreach my $var (@variables){
    my %var = %{$var};
    my $index = $var{index};
    my $value = $var{value};
    code_push( {code=> [ "$index: db $value"] ,});
}



sub generate_code {
my ($list) = @_;
my @list = @{$list};
foreach my $var (@list) {
    if( ! $var->{code} ){
	if( $var->{type} eq "label" ){
	    $var->{code} =  ["$var->{name}: idle"];
	}elsif ($var->{type} eq "if" ){
	    $var->{code} = ["ifjmp $var->{arg1} $var->{arg2} $var->{index}"];
	}elsif ($var->{type} eq "idle" ){
	    $var->{code} = [ "idle" ];
	}elsif ($var->{type} eq "copy" ){
	    $var->{code} = [ "copy $var->{arg1} $var->{arg2}" ];
	}elsif ($var->{type} eq "else" ){
	    $var->{code} = ["ifjmp zero zero $var->{label}"];
	}elsif ($var->{type} eq "call" ){
	    print "debug.call = ".Dumper($var);

	    my @code;

	    my @ain = @{$var->{argin}};
	    my @aout = @{$var->{argout}};
	    my @aprocin = @{$var->{argprocin}};
	    my @aprocout = @{$var->{argprocout}};
	    for my $i (0..((scalar @ain)-1)){
		my $codevar = $ain[$i];
		my $procvar = $aprocin[$i];
		
		push(@code, "copy $codevar $procvar");
	    }
	    my $indx = $var->{index};
	    push(@code ,  ("copy return-var-$indx proc-return-$indx " ,
			    "ifjmp zero zero $indx",	
			    "return-var-$indx: db call-return-$indx", 
			    "call-return-$indx: idle"  ));
	    for my $i (0..((scalar @aout)-1)){
		my $codevar = $aout[$i];
		my $procvar = $aprocout[$i];
	    
		push(@code, "copy $procvar $codevar");
	    }
	    $var->{code} = \@code;
	}elsif($var->{type} eq "procend" ){
	    $var->{code} = [ "ifjmp2 zero zero proc-return-$var->{index}" ];
	}elsif($var->{type} eq "prochead" ) {
	    $var->{code} = [	"proc-return-$var->{index}: db 0x0",
				"$var->{index}: idle"];
	}else{
	    die "compilation error: unknown line type '$var->{type}'";
	}	
    }	
}
return @list;
}

my $maincode = code_prevnamespace();
my @code = generate_code($maincode);


my @maincode;
my $code;
foreach my $var (@code) {
    push(@maincode,$var->{code});
}

my @proccode;

foreach my $f (@procedures) {

    generate_code($f->{code});
    foreach my $l ( @{$f->{code}}){
	push(@proccode,$l->{code});
    }
}

my @fullcode;
foreach my $l (@maincode){
    push(@fullcode,@{$l});
}
foreach my $l (@proccode){
    push(@fullcode,@{$l});
}

foreach my $l (@fullcode){
    $code .= $l . "\n";
}

#print "\@fullcode = " . Dumper(\@fullcode);

#print "\@maincode = " . Dumper(\@maincode);
#print "\@proccode = " . Dumper(\@proccode);


#print "\@variables = " . Dumper(\@variables);
print "\@procecures = " .  Dumper(\@procedures);
#print "\@maincode = " . Dumper(\@maincode);
print "\@code = " . Dumper(\@code);
print "\$maincode = ".Dumper($maincode);

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
