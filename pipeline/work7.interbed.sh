#!/bin/bash
workdir=~/example
bin=~/bin
data=~/PIVar-data

mkdir -p $workdir/Score/SNP
cd $workdir/Score

for i in CLIP Motif miRNA eQTL;do ln -sf $data/$i; done

cd $workdir/Score/SNP
awk -F "\t" '{print $14"\t"$15"\t"$16"\t"$12}' ../../Transcript_RBP_SNP.filtered.strand.energy.txt  > energy.bed
awk  '{{chr=$1;outfile=chr".energy.bed"}print $0 >  outfile}'  energy.bed
awk  '{{chr=$1;outfile=chr".SNP.bed"}print $1"\t"$2"\t"$3 >  outfile}'  ../../example.input
for t in Motif eQTL miRNA CLIP;do
        for i in  {1..22} X Y;do
echo "
cd $workdir/Score/SNP
~/soft/bedtools2/bin/bedtools intersect -wa  -wb  -a chr$i.SNP.bed -b $workdir/Score/$t/chr$i.bed  > chr$i.$t.int
" > chr$i.$t.int.sh
sh chr$i.$t.int.sh
done
done

