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
my ($in,$out,$dis,$quiet,$model,$cpgpos,$p,$win_max,$Help);
GetOptions
(
        "in=s" => \$in,
	"dis=i" => \$dis,
        "out=s" => \$out,
	"q=s" => \$quiet,
	"m=s" => \$model,
#       "cpgpos=s" => \$cpgpos,
#       "p=f"=> \$p,
#       "win_max=i"=> \$win_max,
        "help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0
        -i <in_file>
	-d <distance of extending in each direction> [1000]
	-m <model of center intercept, 'even' or 'defect'> [defect]
	-q <suppresses warnings information, yes or no> [yes]
        -o <out_file>
        -h <display this help info>\n
USAGE
die $usage if ($Help || ! $in);
#print STDERR "---Program      $0     starts --> ".localtime()."\n";
&showLog("Start!");
if (defined $out)  { open(STDOUT,  '>', $out)  || die $!; }
##############################################
my %hash;
my @files=`ls $in`;
my $fh;
my %fhand;
$dis ||=1000;
$model ||="defect";
$quiet ||="yes";
if ($quiet !~/yes/i){print STDERR "distance is $dis\nmodel is $model\n";}
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
		my $d=$dis;
                my @tmp=split /\t/;
		my $lenwt=length($tmp[6]);
		my $lenmt=length($tmp[7]);
		my $fullpos=$tmp[-5];
		$tmp[-6]=$fullpos."\t".$fullpos;
		#set the same length (minxium);
		my $len;
		if ($lenwt>$lenmt){
			$len=$lenmt;
		}else{
			$len=$lenwt;
		}
		if ($len < 2*$d+1){
			print STDOUT join "\t",@tmp;
			print STDOUT "\n";
			if ($quiet!~/yes/i){
				print STDERR "ID is $tmp[-1] (length of original sequence is smaller than the 2*extending distance)\n";
			}
			next;
		}
		my $center=0;
		my $type;
		my $shift=0;
		my $pos=0;
		my ($seq1,$seq2);
		if($tmp[-5]=~/([A-Za-z]+)(\d+)(\w+)/){#substution #G581C
			#print STDERR "$1\t$2\t$3\n";
			$seq1=$1;$seq2=$3;
			$center=$2;
			$type="substution";
			$shift=1;
		}elsif($tmp[-5]=~/-(\d+)([A-Za-z]+)/){#insertion -295CCAGG
			$seq2=$2;
			$center=$1;
			$shift=length($seq2);
			$type="insertion";
		}elsif($tmp[-5]=~/([A-Za-z]+)(\d+)-(\d+)/){#deletion AAAG3040-3
			$seq1=$1;$seq2=$3+1;
			$center=$2;
			$shift=length($seq1);
			$type="deletion";
		}
		#print STDERR "$type\n";
		my ($start,$startwt,$startmt,$endmt,$endwt);
#for start and ends site
		if ($center-1<$d){#start is shorter than dis
			$start=1;
			$pos=$center;
			$startwt=$start;
			$startmt=$start;
			if ($len-$start<2*$d){
                        	$endwt=$len;
				$endmt=$len;
		        }else{
				$endwt=1+2*$d;
                     	  	$endmt=1+2*$d;
                	}
		}else{#start is longer than dis
			$start=$center-$d;
			if ($len-$center<$d){#ends is shorter than dis
				$endwt=$len;
                                $endmt=$len;
				if ($len < 2*$d){
					$start=1;
					$pos=$center;
				}else{
					$start=$len-2*$d;
					$pos=$center-$start+1;	
				}
			}else{#ends is longer than dis
				$endwt=$center+$d;
				$endmt=$center+$d;
				$pos=$d+1;
				#print STDERR "$pos\n";
			}
		}
#for sequence site
		my $lengthwt=$endwt-$start+1;
		my $lengthmt=$endmt-$start+1;
		my $length=$lengthwt;
		if ($quiet!~/yes/i){
			print STDERR "Line $.: ID is $tmp[-1] center is $center distance is $d start is $start; endwt is $endwt; endmt is $endmt; length is $length; lengthWT is $lenwt; lengthMT is $lenmt\n";
		}
		if ($model=~/^even/i){
			my $newwt=substr($tmp[6],$start-1,$length);
			my $newmt=substr($tmp[7],$start-1,$length);
			$tmp[6]=$newwt;
			$tmp[7]=$newmt;
			if ($type eq "substution"){
				$tmp[-5]=$seq1.$pos.$seq2;
			}elsif($type eq "insertion"){
				$tmp[-5]="-".$pos.$seq2;
			}elsif($type eq "deletion"){
				$tmp[-5]=$seq1.$pos."-".$seq2;
			}
			$tmp[-6]=$fullpos."\t".$tmp[-5];
			#print STDERR "$tmp[-5]\n";
			print STDOUT join "\t",@tmp;
			print STDOUT "\n";
		}else{
			if ($type eq "substution"){
				my $newwt=substr($tmp[6],$start-1,$length);
                	        my $newmt=substr($tmp[7],$start-1,$length);
        	                $tmp[6]=$newwt;
                        	$tmp[7]=$newmt;
                                $tmp[-5]=$seq1.$pos.$seq2;
                        }elsif($type eq "insertion"){
				my $newwt=substr($tmp[6],$start-1,$length);
				my $newmt=substr($tmp[7],$start-1,$length+$shift);
				$tmp[6]=$newwt;
                                $tmp[7]=$newmt;
                                $tmp[-5]="-".$pos.$seq2;
				print STDERR "$tmp[-5]\n";
                        }elsif($type eq "deletion"){
				my $newwt=substr($tmp[6],$start-1,$length+$shift);
                                my $newmt=substr($tmp[7],$start-1,$length);
                                $tmp[6]=$newwt;
                                $tmp[7]=$newmt;
                                $tmp[-5]=$seq1.$pos."-".$seq2;
                        }
			$tmp[-6]=$fullpos."\t".$tmp[-5];
			#print STDERR "$tmp[-5]\n";
  		 	print STDOUT join "\t",@tmp;
                        print STDOUT "\n";
		}
        }
        close $fh;
}
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
sub mean {
    my (@data) = @_;
    my $sum;
    foreach (@data) {
        $sum += $_;
    }
    return ( $sum / @data );
}
sub median {
    my (@data) = sort { $a <=> $b } @_;
    if ( scalar(@data) % 2 ) {
        return ( $data[ @data / 2 ] );
    } else {
        my ( $upper, $lower );
        $lower = $data[ @data / 2 ];
        $upper = $data[ @data / 2 - 1 ];
        return ( mean( $lower, $upper ) );
    }
}
sub std_dev {
    my (@data) = @_;
    my ( $sq_dev_sum, $avg ) = ( 0, 0 );

    $avg = mean(@data);
    foreach my $elem (@data) {
        $sq_dev_sum += ( $avg - $elem )**2;
    }
    return ( sqrt( $sq_dev_sum / ( @data - 1 ) ) );
}
sub open_files{
        my $files=shift;
        my $num=@$files;
        for(0..$num-1){
                if(@$files[$_]=~/\S+.gz$/){open $fhand{$_},"gzip -dc @$files[$_]|" or die $!;
                }else{open $fhand{$_},"@$files[$_]" or die "$!";}
        }
}
#print STDERR "<--Program      $0     ends --- ".localtime()."\n";
