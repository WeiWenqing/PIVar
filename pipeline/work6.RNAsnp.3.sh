workdir=~/example
bin=~/bin
n=`ls $workdir/RNAsnp/split/RNAsnp*.txt |wc -l`
for i in $(seq 1 $n);do
	mkdir -p $workdir/RNAsnp/Result/RNAsnp$i
	cd $workdir/RNAsnp/split/RNAsnp$i/
	ls *.seq.txt |awk -F "." '{print $1}' > $workdir/RNAsnp/Result/RNAsnp$i/trans.list
	rm -rf  $workdir/RNAsnp/Result/RNAsnp$i.sh
	for t in `cat $workdir/RNAsnp/Result/RNAsnp$i/trans.list`;do
	echo "cd $workdir/RNAsnp/Result/RNAsnp$i && export RNASNPPATH=~/soft/RNAsnp-1.2 && ~/soft/RNAsnp-1.2/Progs/RNAsnp -f $workdir/RNAsnp/split/RNAsnp$i/$t.seq.txt -s $workdir/RNAsnp/split/RNAsnp$i/$t.snp.txt  -m 1 > $workdir/RNAsnp/Result/RNAsnp$i/$t.RNAsnp.txt " >> $workdir/RNAsnp/Result/RNAsnp$i.sh;
	done
echo "#!/bin/bash
cd $workdir/RNAsnp/Result/RNAsnp$i
sh $workdir/RNAsnp/Result/RNAsnp$i.sh " > $workdir/RNAsnp/Result/qsub.$i.sh
qsub $workdir/RNAsnp/Result/qsub.$i.sh
done

