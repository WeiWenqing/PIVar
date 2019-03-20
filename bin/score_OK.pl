#############################################
#Program name:score
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
my ($in,$out,$c,$e,$m,$r,$s,$win_max,$Help);
GetOptions
(
	"i=s" => \$in,
	"e=s" => \$e,
	"c=s" => \$c,
	"m=s" => \$m,
	"r=s" => \$r,
	"s=s" => \$s,
	"out=s" => \$out,
	"help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0  
	-i <RNAedit_file>  
	-e <eQTL>
	-c <CLIP-RBP>
	-m <Motif>
	-r <miRNA>
	-s <structure>
	-o <out_file>
	-h <display this help info>\n
USAGE
die $usage if ($Help || ! $in);
#print STDERR "---Program	$0	starts --> ".localtime()."\n";
&showLog("Start!");
if (defined $out)  { open(STDOUT,  '>', $out)  || die $!; }
##############################################
my @files=`ls $e`;#eQTLs
my $fh;
my %fhand;
my %eqtl;
##############################################
foreach my $file (@files){
	chomp $file;
	$fh=open_file($file);
	while(<$fh>){
		chomp;
		my @tmp=split /\t/;
		#chr10   35727252        35727252        chr10   35727252        35727252
		my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];
		$eqtl{$id}=1;			
	}
	close $fh;
}
##############################################
my @files=`ls $c`;#CLIP-RBP
my $fh;
my %fhand;
my %clip;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
		#chr2    65465112        65465112        chr2    65465110        65465145        PTBP1	
		my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];
		my $tag=(split /\_/,$tmp[-1])[0];
		$clip{$id}.=$tag.";";
        }
        close $fh;
}
##############################################
my @files=`ls $m`;#motif
my $fh;
my %fhand;
my %motif;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
		my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];
		my $tag=(split /\_/,$tmp[-1])[0];
		$motif{$id}.=$tag.";";		
        }
        close $fh;
}
##############################################
my @files=`ls $r`;#miRNA
my $fh;
my %fhand;
my %rna;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;
		my $info=join ";",@tmp;
		my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];
                $rna{$id}.=$info.";";
        }
        close $fh;
}
##############################################
my @files=`ls $s`;#structure change
my $fh;
my %fhand;
my %struc;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split;
		#chr3    10143343        10143343        -1.1
		if ($tmp[-1] !=0){
			my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];
			$struc{$id}.=$tmp[-1].";";	
		}
        }
        close $fh;
}
##############################################
my @files=`ls $in`;
my $fh;
my %fhand;
my $match=0;
##############################################
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split /\t/;	
		my $id=$tmp[0]."_".$tmp[1]."_".$tmp[2];
		my ($flag_eqtl,$flag_clip,$flag_rna,$flag_struc,$flag_motif,$match)=(0)x6;
		if ($eqtl{$id}){
			$flag_eqtl=1;
		}
		my @clips;
		if($clip{$id}){
			$flag_clip=1;
                	@clips=split /\_/,$clip{$id};
		}
		if ($motif{$id}){
			$flag_motif=1;
			my @motifs=split /\_/,$motif{$id};
			if ($clip{$id}){
				foreach my $m (@motifs){
					foreach my $c (@clips){
						if (($c eq $m) && ($c ne "") && ($m ne "")){
							$match=1;
						}else{
							$match=0;
						}
					}
				}
			}	
		}
		if ($rna{$id}){
			$flag_rna=1;
		}
		if ($struc{$id}){
			$flag_struc=1;
		}
		if (($flag_eqtl==1) && ($flag_clip==1) && ($flag_rna==1) && ($flag_motif)==1 && ($flag_struc==1) && ($match==1)){
			print STDOUT "$_\t1a\tCLIP:\t$clip{$id}\tmiRNA:\t$rna{$id}\tMotif:\t$motif{$id}\tEnergy:\t$struc{$id}\n";
		}elsif(($flag_eqtl==1) && ($flag_clip==1) && ($flag_rna==1) && ($flag_motif)==1 && ($flag_struc==1) && ($match==0)){
			print STDOUT "$_\t1b\tCLIP:\t$clip{$id}\tmiRNA:\t$rna{$id}\tMotif:\t$motif{$id}\tEnergy:\t$struc{$id}\n";
		}elsif(($flag_eqtl==1) && ($flag_clip==1) && ($flag_rna==0) && ($flag_motif)==1 && ($flag_struc==1) && ($match==0)){
			print STDOUT "$_\t1c\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t$struc{$id}\n";
		}elsif(($flag_eqtl==1) && ($flag_clip==1) && ($flag_rna==0) && ($flag_motif)==1 && ($flag_struc==0) && ($match==0)){
			print STDOUT "$_\t1d\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t.\n";
		}elsif(($flag_eqtl==1) && ($flag_clip==1) && ($flag_rna==0) && ($flag_motif)==0 && ($flag_struc==0) && ($match==0)){
			print STDOUT "$_\t1e\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t.\n";
		}#2....
		elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==1) && ($flag_motif)==1 && ($flag_struc==1) && ($match==1)){
			print STDOUT "$_\t2a\tCLIP:\t$clip{$id}\tmiRNA:\t$rna{$id}\tMotif:\t$motif{$id}\tEnergy:\t$struc{$id}\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==1) && ($flag_motif)==1 && ($flag_struc==1) && ($match==0)){
			print STDOUT "$_\t2b\tCLIP:\t$clip{$id}\tmiRNA:\t$rna{$id}\tMotif:\t$motif{$id}\tEnergy:\t$struc{$id}\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==0) && ($flag_motif)==1 && ($flag_struc==1) && ($match==0)){
			print STDOUT "$_\t2c\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t$struc{$id}\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_struc==1)){
			print STDOUT "$_\t2d\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t.\tEnergy:\t$struc{$id}\n";
		}#3....
		elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==1) && ($flag_motif)==1 && ($flag_struc==0) && ($match==0)){
			print STDOUT "$_\t3a\tCLIP:\t$clip{$id}\tmiRNA:\t$rna{$id}\tMotif:\t$motif{$id}\tEnergy:\t.\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==0) && ($flag_motif)==1 && ($flag_struc==0) && ($match==1)){
			print STDOUT "$_\t3b\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t.\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==0) && ($flag_motif)==1 && ($flag_struc==0) && ($match==0)){
			print STDOUT "$_\t04\tCLIP:\t$clip{$id}\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t.\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==1) && ($flag_rna==1) && ($flag_motif)==0 && ($flag_struc==0) && ($match==0)){
			print STDOUT "$_\t05\tCLIP:\t$clip{$id}\tmiRNA:\t$rna{$id}\tMotif:\t.\tEnergy:\t.\n";
		}elsif(($flag_eqtl==0) && ($flag_clip==0) && ($flag_rna==0) && ($flag_motif)==1 && ($flag_struc==0) && ($match==0)){
			print STDOUT "$_\t06\tCLIP:\t.\tmiRNA:\t.\tMotif:\t$motif{$id}\tEnergy:\t.\n";
		}else{
		#	print STDOUT "$_\tNull\n";
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
