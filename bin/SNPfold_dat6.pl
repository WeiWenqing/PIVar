#!/usr/bin/perl -w
use strict;
use warnings;
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
my ($in,$out,$cpgpos,$snp,$win_max,$Help,$gtf);
GetOptions
(
	"i:s" => \$in,
	"g:s" => \$gtf,
	"s:s" => \$snp,
	"o:s" => \$out,
	"help" => \$Help,
);
##############################################
my $usage=<<USAGE;
\n Usage : \n perl $0  
	-i <Ref_fa>  #/panfs/home/VIP/maofb/database/human/hg19/tophat/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa
	-g <gtf ref> #/panfs/home/VIP/maofb/database/human/ensembl/hg19/Homo_sapiens.GRCh37.75.gtf
	-s <dbSNP> #/panfs/home/VIP/maofb/MyPro/RBPSNP/ASD/ASD.denovo-hg19.input.final 
	-o <out_file>
	-h <display this help info>\n
USAGE
die $usage if ($Help || ! $in);
#print STDERR "---Program	$0	starts --> ".localtime()."\n";
&showLog("Start!");
if (defined $out)  { open(STDOUT,  '>', $out)  || die $!; }
##############################################
my @files=`ls $snp`;#dbSNP
my $fh;
my %fhand;
my %hash;
my %snp_pos=();
#bin    chrom   chromStart      chromEnd        name    score   strand  refNCBI refUCSC observed
##############################################
foreach my $file (@files){
	chomp $file;
	$fh=open_file($file);
	while(<$fh>){
		#print STDERR "reading SNP\n";
		chomp;
#chr1    11420458        11420458        C       T       74-0352 ASD     WGS     Michaelson JJ et al. Cell 2012  23260136	C/T	+	SNV	NOID22	#14col
		my @tmp=(split /\t/,$_);
		next if ($tmp[0]=~/^#/);
		my $chr=$tmp[0];
		my @mut;
		my @bases=(split /\//,$tmp[10]);
			foreach my $key (@bases){
				if ($key ne $tmp[3]){
					$key=uc($key);
					push @mut,$key;
				}
			}
			my $start=$tmp[1];	
			my $end=$tmp[2];
			#my $pos=$chr."-".$start."-".$tmp[11]."-".$tmp[12];#chr-->start-->strand-->type
			my $pos=$chr."-".$start."-".$tmp[12];#chr-->start-->type
                	$snp_pos{$pos}=$chr."\t".$tmp[1]."\t".$tmp[2]."\t".$tmp[-1];#location information
        	        my $mut_num=@mut;
	                if ($mut_num>1){
                        	foreach my $num (0..$mut_num-1){
                	                $hash{$pos}{$num}=$tmp[11]."/".$tmp[3]."/".$mut[$num];#strand-->refbase-->mutbase
        	                }
	                }else{
                        	$hash{$pos}{0}=$tmp[11]."/".$tmp[3]."/".$mut[0];
                	}
	}
	close $fh;
}

print STDERR "SNP reading accomplished!\n";

##############################################
@files=`ls $in`;#ref
my %ref;
my $chr;
my $chrbk;
my $flag=0;
my $seq;
foreach my $file (@files){
	chomp $file;
	$fh=open_file($file);
	while(<$fh>){               
#		print STDERR "reading REF\n";
		chomp;
		my $line=$_;
		#print STDERR "$_\n";
        	my @tmp=(split(//,$line));
		if ($tmp[0]=~/^>/){
			my $idline=$line;
			$idline=~s/>//g;
#			$idline=~s/^chr//;
			$chr=$idline;
			if ($flag==1){
				$flag=0;
				$ref{$chrbk}=uc($seq);
				$seq="";
			}	
                	$chrbk=$chr;
		}else{
			$seq.=uc($line);	
			$flag=1;
		}
	}
	if ($flag==1){ 
 		$flag=0;
      		$ref{$chrbk}=uc($seq);
	}
	close $fh;
}
print STDERR "Ref reading accomplished!\n";
my %trans_len;
@files=`ls $gtf`;
my %transcript_exon;
foreach my $file (@files){
	chomp $file;
        $fh=open_file($file);
        while(<$fh>){
                chomp;
		next if $_=~/^s*$/;
                my @tmp=(split /\t/,$_);#1       protein_coding  transcript      860530  871173  .       +       .	geneid
		$tmp[0]="chr".$tmp[0];
                next if ($tmp[0]=~/^#/);
		next if (($tmp[2] ne "exon") || (! defined $tmp[2]));
		$tmp[8]=~s/\"//g;
		$tmp[8]=~s/\;//g;
                my @tmp2= (split /\s+/,$tmp[8]);#gene_id "ENSG00000223972"; transcript_id "ENST00000515242"; exon_number "1";
                my $id=$tmp2[3];
                push @{$transcript_exon{$id}},[$tmp[0],$tmp[1],$tmp[3],$tmp[4],$tmp[6],$tmp[8]];#chr,trait,start,end,strand,info
		$trans_len{$id}+=$tmp[4]-$tmp[3]+1;
	#	print STDERR "chr:$tmp[0],trait:$tmp[1],start:$tmp[3],end:$tmp[4],strand:$tmp[6],info:$tmp[8]]\n";
        }
        close $fh;
}
print STDERR "GTF reading accomplished!\n";
open OUT,">$out" or die $!;
my $count=0;

foreach my $transcript (keys %transcript_exon){
        $transcript_exon{$transcript} = [sort { $a->[2] <=> $b->[2] } (@{$transcript_exon{$transcript}})];#sort by start position
	my $seq="";
        my $exon_num=@{$transcript_exon{$transcript}};
	my @exons=@{$transcript_exon{$transcript}};
        my $chr=$exons[0][0];
        my $str=$exons[0][4];
	my $gene_start=${$transcript_exon{$transcript}}[0][2];
	my $gene_end=${$transcript_exon{$transcript}}[-1][3];
	my $genelen=abs($gene_end-$gene_start)+1;
	my $length=0;
	#print STDERR "->$chr\t->$str\t->$gene_start\t->$gene_end\n";
	foreach my $exon (@exons){
		my $exontmplen=0;
		for (${$exon}[2]..${$exon}[3]){
			$length++;
			$exontmplen++;
			my $site=$_;
			#print "$site\n";
			foreach my $type ("SNV","mnp","deletion","insertion"){
				#my $snpid=$chr."-".$site."-".$str."-".$type;
				my $snpid=$chr."-".$site."-".$type;
				if (exists $hash{$snpid}){
					if ($type eq "SNV"){
						#print STDERR "found SNP!\n";
						my $ref=substr($ref{$chr},$site-1,1);		
						$ref=uc($ref);
						my $transeq;
						foreach my $exon (@exons){#Transeq
							my $exonseq=substr($ref{$chr},${$exon}[2]-1,${$exon}[3]-${$exon}[2]+1);
							$exonseq=uc($exonseq);
							$transeq.=$exonseq;
						}
						my $mut;
						my $mut2;
						my $alteration;
						my $com=(split(/\//,$hash{$snpid}{0}))[-2];
						if ($com ne $ref){
							$count++;
							next;
						}
						foreach my $key(keys %{$hash{$snpid}}){
							my @snpinfo=split /\//,$hash{$snpid}{$key};
							$mut=$ref.$length.$snpinfo[-1];
							$mut2=$ref.$length.$snpinfo[-1];	
							$alteration=$transeq;
							substr($alteration,$length-1,1)=$snpinfo[-1];
							if ($str eq "-"){#deal "-" strand
        	                                		$ref=~tr/NAGCT/NTCGA/;
								my $mutbase=$snpinfo[-1];
								$mutbase=~tr/NAGCT/NTCGA/;
								$transeq=reverse($transeq);
        	        	                        	$transeq=~tr/NAGCT/NTCGA/;
								$alteration=reverse($alteration);
								$alteration=~tr/NAGCT/NTCGA/;
								my $posi=($genelen-$length+1);	
								my $posi2=($trans_len{$transcript}-$length+1);
							#	substr($alteration,$posi-1,1)=$snpinfo[-1];
								$mut=$ref.$posi.$snpinfo[-1];
								$mut2=$ref.$posi2.$mutbase;
							}
							print OUT  "${$exon}[0]\t${$exon}[1]\t${$exon}[2]\t${$exon}[3]\t${$exon}[4]\t${$exon}[5]\t$transeq\t$alteration\t$mut\t$mut2\t$snp_pos{$snpid}\n";
						}
                                	}elsif($type eq "deletion"){
                                                my $transeq;
                                                foreach my $exon (@exons){#Transeq
                                                        my $exonseq=substr($ref{$chr},${$exon}[2]-1,${$exon}[3]-${$exon}[2]+1);
                                                        $exonseq=uc($exonseq);
                                                        $transeq.=$exonseq;
                                                }		
						my $mut;
						my $mut2;
                                                my $alteration;
						my @section=split /\t/,$snp_pos{$snpid};
                                                my $seclen=$section[2]-$section[1];
						my $ref=(split(/\//,$hash{$snpid}{0}))[-2];
					
						my $exonlen=${$exon}[3]-${$exon}[2]+1;
						my $lastexonlen=$exonlen-$exontmplen+1;
						if ($seclen>$lastexonlen){$seclen=$lastexonlen;}
						foreach my $key(keys %{$hash{$snpid}}){
							my @snpinfo=split /\//,$hash{$snpid}{$key};
                                                        $mut=$ref.$length."-".$seclen;
							$mut2=$ref.$length."-".$seclen;
                                                        $alteration=$transeq;
                                                        substr($alteration,$length-1,$seclen)="";
                                                        if ($str eq "-"){#deal "-" strand
                                                                $ref=~tr/NAGCT/NTCGA/;
                                                                $transeq=reverse($transeq);
                                                                $transeq=~tr/NAGCT/NTCGA/;
                                                                $alteration=reverse($alteration);
                                                                $alteration=~tr/NAGCT/NTCGA/;
                                                                my $posi=($genelen-$length+1);
                                                                my $posi2=($trans_len{$transcript}-$length+1);
                                                        #       substr($alteration,$posi-1,1)=$snpinfo[-1];
                                                                $mut=$ref.$posi."-".$seclen;
								$mut2=$ref.$posi2."-".$seclen;
                                                        }
                                                        print OUT  "${$exon}[0]\t${$exon}[1]\t${$exon}[2]\t${$exon}[3]\t${$exon}[4]\t${$exon}[5]\t$transeq\t$alteration\t$mut\t$mut2\t$snp_pos{$snpid}\n";
						}
					}elsif($type eq "insertion"){
						my $transeq;
                                                foreach my $exon (@exons){#Transeq
                                                        my $exonseq=substr($ref{$chr},${$exon}[2]-1,${$exon}[3]-${$exon}[2]+1);
                                                        $exonseq=uc($exonseq);
                                                        $transeq.=$exonseq;
                                                }
                                                my $mut;
						my $mut2;
                                                my $alteration;
                                                my $ref=(split(/\//,$hash{$snpid}{0}))[-2];

                                                foreach my $key(keys %{$hash{$snpid}}){
                                                        my @snpinfo=split /\//,$hash{$snpid}{$key};
                                                        $mut=$ref.$length.$snpinfo[-1];	
							$mut2=$ref.$length.$snpinfo[-1];
                                                        $alteration=$transeq;
                                                        substr($alteration,$length-1,0)="";
                                                        if ($str eq "-"){#deal "-" strand
                                                                $ref=~tr/NAGCT/NTCGA/;
								my $mutbase=$snpinfo[-1];
                                                                $mutbase=~tr/NAGCT/NTCGA/;
                                                                $transeq=reverse($transeq);
                                                                $transeq=~tr/NAGCT/NTCGA/;
                                                                $alteration=reverse($alteration);
                                                                $alteration=~tr/NAGCT/NTCGA/;
                                                                my $posi=($genelen-$length+1);
								my $posi2=($trans_len{$transcript}-$length+1);
								$mut=$ref.$posi.$snpinfo[-1];
								$mut2=$ref.$posi2.$mutbase;
                                                        }
                                                        print OUT  "${$exon}[0]\t${$exon}[1]\t${$exon}[2]\t${$exon}[3]\t${$exon}[4]\t${$exon}[5]\t$transeq\t$alteration\t$mut\t$mut2\t$snp_pos{$snpid}\n";
                                                }
					}else{#mnp
						my $transeq;
                                                foreach my $exon (@exons){#Transeq
                                                        my $exonseq=substr($ref{$chr},${$exon}[2]-1,${$exon}[3]-${$exon}[2]+1);
                                                        $exonseq=uc($exonseq);
                                                        $transeq.=$exonseq;
                                                }
                                                my $mut;
						my $mut2;
                                                my $alteration;
                                                my @section=split /\t/,$snp_pos{$snpid};
                                                my $seclen=$section[2]-$section[1];
                                                my $ref=(split(/\//,$hash{$snpid}{0}))[-2];

                                                my $exonlen=${$exon}[3]-${$exon}[2]+1;
                                                my $lastexonlen=$exonlen-$exontmplen+1;
                                                if ($seclen>$lastexonlen){$seclen=$lastexonlen;}
                                                foreach my $key(keys %{$hash{$snpid}}){
                                                        my @snpinfo=split /\//,$hash{$snpid}{$key};
							my $substr=substr($snpinfo[-1],0,$seclen);
                                                        $mut=$ref.$length.$substr.$seclen;
							$mut2=$ref.$length.$substr.$seclen;
                                                        $alteration=$transeq;
                                                        substr($alteration,$length-1,$seclen)=$substr;
                                                        if ($str eq "-"){#deal "-" strand
                                                                $ref=~tr/NAGCT/NTCGA/;
                                                                $transeq=reverse($transeq);
                                                                $transeq=~tr/NAGCT/NTCGA/;
                                                                $alteration=reverse($alteration);
                                                                $alteration=~tr/NAGCT/NTCGA/;
                                                                my $posi=($genelen-$length+1);
								my $posi2=($trans_len{$transcript}-$length+1);
                                                                $mut=$ref.$posi.$substr.$seclen;
								$mut2=$ref.$posi2.$substr.$seclen;
                                                        }
                                                        print OUT  "${$exon}[0]\t${$exon}[1]\t${$exon}[2]\t${$exon}[3]\t${$exon}[4]\t${$exon}[5]\t$transeq\t$alteration\t$mut\t$mut2\t$snp_pos{$snpid}\n";
						}
					}
				}
			}
		}
	}
}
close OUT;
print STDERR "There are $count differences!\n";
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
