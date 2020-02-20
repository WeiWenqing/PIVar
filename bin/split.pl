#!/usr/bin/perl

=head1 Function
        split a big file into small files by line.

=head1 Usage
        perl $0 <infile> [ <outdir> -l <INT lines per output file> -p <prefix> -s <suffix> ]

=head1 Options
        <outdir>      default "infile.$$.qsub"
        -l <INT>      put <INT> lines per output file
        -p <STR>      prefix of outfile; default "yr"
        -s <STR>      suffix of outfile; default ".sh"

=head1 Example
        perl $0 exam.sh -l 3 -p exa

=head1 Author
        yerui; yerui@genomics.org.cn

=head1 Version
        v1.0; 2010-11-09
        v1.1; 2010-12-12

=cut

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $Help;
my ($Line,$Prefix,$Suffix) = (1,"maofb",".gene");
GetOptions(
        "help|?" => \$Help,
        "line=i" => \$Line,
        "prefix=s" => \$Prefix,
        "suffix=s" => \$Suffix,
);

die `pod2text $0` if( @ARGV < 1 or $Help );

my $infile = $ARGV[0];
my $outdir = $ARGV[1];

$outdir ||= "$infile"."_"."split";
$outdir =~ s{/+$}{}g;

system "mkdir -p $outdir" unless(-d $outdir);

my $flag = 0;
open IN, "<$infile" or die $!;
if($Line == 1) {
        while(my $in_line=<IN>) {
#               $flag++;
                my @arr=split (/\s+/,$in_line);
                $flag=$arr[4];
                open OT, ">$outdir/$Prefix$flag$Suffix" or die $!;
                print OT "$in_line";
                close OT;
        }
}
if($Line != 1) {
        while(<IN>) {
                if($. % $Line == 1) {
                        $flag++;
                        open OT, ">$outdir/$Prefix$flag$Suffix" or die $!;
                }
                print OT "$_";
        }
        close OT;
}
close IN;

print STDERR "you have split $infile into $flag files in $outdir\n";
