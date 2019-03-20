#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Long;
use Cwd qw(abs_path);
use Data::Dumper;
use lib ("~/perl_packages/Math-CDF-0.1/lib64/perl5");
use Math::CDF qw(:all);
#############################################
my ($in,$out,$r,$p,$win_max,$Help);
GetOptions
(
	"in=s" => \$in,
	"r=s" => \$r,
	"out=s" => \$out,
	"help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0  
	-i <in_file>  
	-r <RNAsnp>
	-o <out_file>
	-h <display this help info>\n
USAGE
die $usage if ($Help || ! $in);
#print STDERR "---Program	$0	starts --> ".localtime()."\n";
&showLog("Start!");
if (defined $out)  { open(STDOUT,  '>', $out)  || die $!; }
##############################################
my @files=`ls $r`;
my $fh;
my %fhand;
my %hash;
##############################################
foreach my $file (@files){
	chomp $file;
	my $fn=basename($file);#ENST00000229794.RNAsnp.txt 
	my $f=(split /\./,$fn)[0];
	$fh=open_file($file);
	while(<$fh>){
		chomp;
		my @tmp=split;
		next if ($_=~/^SNP/ || $_=~/^The/);
		$hash{$f}{$tmp[0]}=$tmp[-1];	
		#print STDERR "$f\t$tmp[0]\n";
	}
	close $fh;
}
##############################################
my @files=`ls $in`;
my $fh;
my %fhand;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
		my @info=split /\s+/,$tmp[5];
		my $trans=$info[3];
		my $mut=$tmp[11];
		#print STDERR "$trans\t$tmp[11]\n";
		if ($hash{$trans}{$mut}){
			print STDOUT "$_\t$hash{$trans}{$mut}\n";
		}else{
			my $k=abs($tmp[8]);
                        my $r=abs($tmp[9]);
                        if (abs($tmp[8])>abs($tmp[9])){
                                $k=abs($tmp[9]);
                                $r=abs($tmp[8]);
                        }
                        my $p_value=ppois(abs($k), abs($r));
			print STDOUT "$_\t$p_value\n";
		}
        }
        close $fh;
}

&showLog("Done!");
sub showLog {
        my ($info) = @_;
        my @times = localtime; # sec, min, hour, day, month, year
	print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s
", $times[5] + 1900,$times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
sub Max{
        my (@aa) = @_;
        if (not @aa) {
                die("Empty array\n");
        }
        my $max=shift @aa;
        foreach  (@aa) {$max=$_ if($_>$max);}
        return $max;
}
sub min {
        my (@aa) = @_;
        if (not @aa) {
                die("Empty array\n");
        }
        my $min=shift @aa;
        foreach  (@aa) {$min=$_ if($_<$min);}
        return $min;
}
sub open_file {
        my $file=shift;
	my $fh;
        if($file=~/\S+.gz$/){
                open $fh,"gzip -dc $file |" or die $!;
        }else{
        	open $fh,"$file" or die $!;
        }
        return $fh;
}
sub average{
        my($data) = @_;
        if (not @$data) {
                die("Empty array\n");
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}
sub open_files{
        my $files=shift;
        my $num=@$files;
        for(0..$num-1){
                if(@$files[$_]=~/\S+.gz$/){open $fhand{$_},"gzip -dc @$files[$_]|" or die $!;
                }else{open $fhand{$_},"@$files[$_]" or die "$!";}
        }
}
#print STDERR "<--Program	$0	ends --- ".localtime()."\n";
