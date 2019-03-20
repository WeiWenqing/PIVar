#############################################
#Program name:check
#Author: Fengbiao Mao
#Email:maofengbiao08@163.com || 524573104@qq.com || maofengbiao@gmail.com
#Tel:18810276383
##############################################
#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Long;
use Cwd qw(abs_path);
use Data::Dumper;
#use List::Util qw;
#use PerlIO::gzip;
#use Math::CDF qw(:all);
#use Statistics::Basic qw(:all);
#use Math::Trig;
#############################################
my ($in,$out,$cpgpos,$st,$tr,$win_max,$Help);
GetOptions
(
	"in=s" => \$in,
	"tr=s" => \$tr,
	"out=s" => \$out,
	"help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0  
	-i <all.result.RNAfold.info_file>  
	-o <out_file>
	-t <SNPfold.input>
	-h <display this help info>\n
USAGE
die $usage if ($Help || ! $in);
#print STDERR "---Program	$0	starts --> ".localtime()."\n";
&showLog("Start!");
if (defined $out)  { open(STDOUT,  '>', $out)  || die $!; }
##############################################
my @files=`ls $in`;
my $fh;
my %fhand;
my %info;
##############################################
foreach my $file (@files){
	chomp $file;
	$fh=open_file($file);
	while(<$fh>){
		chomp;
		my @tmp=split /\t/;
		#ENST00000369829_rs147235683_G257A_mutant        -301.10
		$info{$tmp[0]}=$tmp[1];
	}
	close $fh;
}
##############################################
my @files=`ls $tr`;
my $fh;
my %fhand;
my (%muta,%wild);
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
		my @detail=split /\s+/,$tmp[5];			
		my $muta0=$detail[3]."_".$tmp[-1]."_".$tmp[-5]."_mutant";
		#print STDERR "$muta0\n";
		#my $wildid=$tmp[0]."_".$tmp[1]."_".$tmp[2]."_".$tmp[3]."_".$tmp[4]."_".$tmp[5]."_".$tmp[6];
		#my $mutaid=$tmp[0]."_".$tmp[1]."_".$tmp[2]."_".$tmp[3]."_".$tmp[4]."_".$tmp[5]."_".$tmp[7];
		my $wild0=$detail[3]."_wildtype";
		#$muta{$mutaid}=$info{$muta0};
		#$wild{$wildid}=$info{$wild0};
		if ($info{$wild0} && $info{$muta0}){
                        my $substract=$info{$muta0}-$info{$wild0};
                        $tmp[-6]=$info{$wild0}."\t".$info{$muta0}."\t".$substract;
                        print STDOUT join "\t",@tmp;
                        print STDOUT "\n";
                }else{
#                       print STDERR "$_\n";
                }
        }	
        close $fh;
}
=cut
##############################################
my @files=`ls $st`;
my $fh;
my %fhand;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
                #A432G   A432G   chr11   66523867        66523867        +
                my $wildid=$tmp[0]."_".$tmp[1]."_".$tmp[2]."_".$tmp[3]."_".$tmp[4]."_".$tmp[5]."_".$tmp[6];
                my $mutaid=$tmp[0]."_".$tmp[1]."_".$tmp[2]."_".$tmp[3]."_".$tmp[4]."_".$tmp[5]."_".$tmp[7];
		if ($wild{$wildid} && $muta{$mutaid}){
			my $substract=$muta{$mutaid}-$wild{$wildid};
			$tmp[-6]=$wild{$wildid}."\t".$muta{$mutaid}."\t".$substract;
			print STDOUT join "\t",@tmp;
			print STDOUT "\n";
		}else{
#			print STDERR "$_\n";
		}
        }
        close $fh;
}
=cut
##############################################
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
