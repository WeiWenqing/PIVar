#!/bin/bash
workdir=~/example
bin=~/bin
mkdir -p $workdir/RNAsnp
cd $workdir/RNAsnp
perl $bin/RNAsnp_input.pl  -i ../Transcript_RBP_SNP.filtered.strand.energy.txt  -o Transcript_RBP_SNP.filtered.strand.energy.RNAsnp.txt
perl $bin/split.pl Transcript_RBP_SNP.filtered.strand.energy.RNAsnp.txt $workdir/RNAsnp/split   -p "RNAsnp" -s ".txt" -l 200
echo "finished"
