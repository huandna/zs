#PBS -N wyx_plot3
#PBS -j oe  
#PBS -l walltime=5000:00:00  
#PBS -l nodes=1:ppn=10
#PBS -q com_q
#PBS -j n
export PATH=/share/home/chuanlex/xieshangqian/software/MUM4.0/bin:$PATH
wkd=/share/home/chuanlex/yaoxinw/project/11.17_necat_est/result
cd $wkd
mkdir -p $wkd/plot ;
#tool=necat2-40X
#tool=flye
tool=wtdbg2
echo $tool >> $wkd/all_stat ;
for species in ara dro ecoli yeast yizao;
do 
 if [[ $species == "ara" ]];then
    refseq=/share/home/chuanlex/yaoxinw/project/nanopolish/ref/ara/GCA_000001735.2_TAIR10.1_genomic.fna ;
 elif [[ $species == "dro" ]];then
    refseq=/share/home/chuanlex/yaoxinw/project/nanopolish/ref/dro/dm6.fa ;
 elif [[ $species == "ecoli" ]];then
    refseq=/share/home/chuanlex/xieshangqian/xsq/project/ONT_correct/distribution/data/ecoli/ecoli_k12_genomic.fna ;
 elif [[ $species == "yeast" ]];then
    refseq=/share/home/chuanlex/yaoxinw/project/nanopolish/ref/yeast/S288C_reference_sequence_R64-2-1_20150113.fsa ;
 elif [[ $species == "yizao" ]];then
    refseq=/share/home/chuanlex/yaoxinw/data/methylation/chlamydomonas_reinhardtii_v5.5/GCA_000002595.3_Chlamydomonas_reinhardtii_v5.5_genomic.fna ;
 else
    echo 'error species' ;
 fi
echo $species >> $wkd/all_stat ;
echo $refseq >> $wkd/all_stat ;

draft_dir=/share/home/chuanlex/yaoxinw/project/11.17_necat_est/result/$tool/${species}
cd $draft_dir ;
nucmer --mum -l 100 -c 1000 -d 10 --banded -D 5 ${refseq} ${draft_dir}/run3_pilon_polished.fasta ;
delta-filter -i 95 -o 95 out.delta > out.best.delta ;
dnadiff -d out.best.delta ;
mummerplot out.best.delta --fat -f --png ;
cp out.png $wkd/plot/${tool}_${species}.png ;
awk '{if($2=="GAP" &&sqrt($7*$7)>=100) {print $0 }}' out.qdiff | tee indelM5.tx | wc -l >> $wkd/${tool}.all_stat ;
awk '{if($2=="GAP" &&sqrt($7*$7)<100) {print $0 }}' out.qdiff | tee indelL5.txt | wc -l >> $wkd/${tool}.all_stat ;
done
