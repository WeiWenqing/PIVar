#!/bin/bash
workdir=~/example
bin=~/bin
cd $workdir
mkdir -p Score/SNP
cd Score/SNP
perl  $bin/combine.pl  -i ../../Transcript_RBP_SNP.filtered.strand.energy.txt -r $workdir/RNAsnp/Result/RNAsnp\*/\*.RNAsnp.txt -o ../../Transcript_RBP_SNP.filtered.strand.energy.p.txt
for i in  {1..22} X Y;do
perl $bin/score_OK.pl -i chr$i.SNP.bed -e chr$i.eQTL.int -c chr$i.CLIP.int -m chr$i.Motif.int -r chr$i.miRNA.int -s chr$i.energy.bed  -o chr$i.score.bed  -p ../../Transcript_RBP_SNP.filtered.strand.energy.p.txt
done
perl  $bin/SNP_score.pl -i ../../example.input   -s chr\*.score.bed -o ../../example.score.input.p.txt -p ../../Transcript_RBP_SNP.filtered.strand.energy.p.txt
