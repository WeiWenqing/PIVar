#!/bin/bash
workdir=~/example
bin=~/bin
cd $workdir
perl $bin/energy.info.pl -i  \*/\*.result  -o  all.result.RNAfold.info
perl $bin/combine.all.pl  -i all.result.RNAfold.info  -t SNPfold.reset.input -o  Transcript_RBP_SNP.filtered.strand.energy.txt
