workdir=~/example
bin=~/bin
for i in  {1..22} X Y;
do find $workdir/split_chr$i/ -name "*.fold" > $workdir/split_chr$i/fold.list
for s in `cat $workdir/split_chr$i/fold.list`;do 
echo $s
perl $bin/filter_large_transcript.pl -i $s  -o $s.txt
echo "#!/bin/bash
cd $workdir
~/soft/ViennaRNA-2.4.10/bin/RNAfold < $s.txt --noPS  > $s.result" > $s.work.tmp.sh 
qsub $s.work.tmp.sh
done
done
