workdir=~/example
bin=~/bin
n=`ls $workdir/RNAsnp/split/RNAsnp*.txt |wc -l`
for i in $(seq 1 $n);do
mkdir -p $workdir/RNAsnp/split/RNAsnp$i
echo "#!/bin/bash
cd $workdir/RNAsnp/split/RNAsnp$i
perl  $bin/splittrans.pl  -i $workdir/RNAsnp/split/RNAsnp$i.txt -o $workdir/RNAsnp/split/RNAsnp$i
" > $workdir/RNAsnp/split/chr$i.RNAsnp.sh;
qsub $workdir/RNAsnp/split/chr$i.RNAsnp.sh
done
