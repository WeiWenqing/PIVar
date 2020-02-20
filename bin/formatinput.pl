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
my ($in,$out,$cpgpos,$p,$win_max,$Help);
GetOptions
(
        "in=s" => \$in,
        "out=s" => \$out,
#       "cpgpos=s" => \$cpgpos,
#       "p=f"=> \$p,
#       "win_max=i"=> \$win_max,
        "help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0
        -i <in_file>
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
foreach my $file (@files){
        chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
                my @tmp=split;
		#chr1    752917  752917  C       A       ncRNA_exonic    FAM87B  unknown SNV     1p36.33 C/A     +       SNV     NOID1
		#chr1 14542 14542 site1 . +
		#chr1 14574 14574 site2 . +
		#chr1 14604 14604 site3 . +
		#chr1 17373 17373 site4 . +
		#chr1 20166 20166 site5 . +
		#chr1 20184 20184 site6 . +
		#chr1 20212 20212 site7 . +
		#chr1 24832 24832 site8 . +
		if ($tmp[-1]  eq "+"){
			print STDOUT "$tmp[0]\t$tmp[1]\t$tmp[2]\tA\tG\texonic\tgenexxx\tunknown\tSNV\txpxx.xx\tA/G\t$tmp[-1]\tSNV\t$tmp[-3]\n";
		}else{
			print STDOUT "$tmp[0]\t$tmp[1]\t$tmp[2]\tT\tC\texonic\tgenexxx\tunknown\tSNV\txpxx.xx\tT/C\t+\tSNV\t$tmp[-3]\n";
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
