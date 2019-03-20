#############################################
#Program name:dbSNP_score
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
my ($in,$out,$sc,$cpgpos,$p,$win_max,$Help);
GetOptions
(
	"in=s" => \$in,
	"sc=s" => \$sc,
	"p=s" => \$p,
	"out=s" => \$out,
#	"cpgpos=s" => \$cpgpos,
#	"p=f"=> \$p,
#	"win_max=i"=> \$win_max,
	"help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0  
	-i <in_file>  
	-s <score>
	-p <p value file> ~/Transcript_RBP_SNP.filtered.strand.energy.p.txt
	-o <out_file>
	-h <display this help info>\n
USAGE
die $usage if ($Help || ! $in);
#print STDERR "---Program	$0	starts --> ".localtime()."\n";
&showLog("Start!");
if (defined $out)  { open(STDOUT,  '>', $out)  || die $!; }
##############################################
my @files=`ls $sc`;
my $fh;
my %fhand;
my %hash;
##############################################
foreach my $file (@files){
	chomp $file;
	$fh=open_file($file);
	while(<$fh>){
		chomp;
		my $info=$_;
		my @tmp=split /\t/;
		next if ($tmp[-1] eq "Null");	
		$hash{$tmp[0]."_".$tmp[1]."_".$tmp[2]}=$info;
	}
	close $fh;
}
##############################################
my @files=`ls $p`;
my $fh;
my %hash2;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
                $hash2{$tmp[12]."_".$tmp[13]."_".$tmp[14]}=$tmp[-1];
        }
        close $fh;
}
##############################################

my @files=`ls $in`;
my $fh;
my %fhand;
##############################################
#print STDOUT "bin\tchrom\tchromStart\tchromEnd\tname\tscore\tstrand\trefNCBI\trefUCSC\tobserved\tmolType\tclass\tvalid\tavHet\tavHetSE\tfunc\tlocType\tweight\texceptions\tsubmitterCount\tsubmitters\talleleFreqCount\talleles\talleleNs\talleleFreqs\tbitfields\tRBP-Var_score\tP_value\n";
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
		next if ($_=~/^Chr/);
                my @tmp=split;
		my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];	
		my $p_val="NA";
		if($hash2{$id}){
			$p_val=$hash2{$id};
		}
		if ($hash{$id}){
			print STDOUT "$_\t$hash{$id}\t$p_val\n";
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
