workdir=~/example
bin=~/bin
data=~/PIVar-data
distance=2000
input=example.input
cd $workdir
perl $bin/SNPfold_dat6.pl  -i $data/genome.fa -g $data/Homo_sapiens.GRCh37.75.gtf -s $input  -o SNPfold.input
perl $bin/center_intercept.pl  -i SNPfold.input -d $distance -m defect -o SNPfold.reset.input -q yes
awk  '{{chr=$1;outfile="Transcript_RBP_SNP."chr".txt"}print $0 >  outfile}'   SNPfold.reset.input
for i in {1..22} X Y;do
mkdir -p split_chr$i
echo "
cd  $workdir
perl $bin/foramt_seq.pl -i Transcript_RBP_SNP.chr$i.txt -o split_chr$i/chr$i.input
perl $bin/split.pl  split_chr$i/chr$i.input -l 200 -p \"chr$i.\" -s \".fold\"  $workdir/split_chr$i/
" > chr$i.format.sh
sh  chr$i.format.sh
done
