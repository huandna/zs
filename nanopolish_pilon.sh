#PBS -N yeast_1
#PBS -l nodes=1:ppn=20
#PBS -j oe
#PBS -l walltime=5000:00:00
#PBS -q com_q
#export PATH=/share/home/chuanlex/yaoxinw/software/nanopolish.11/nanopolish/:/share/home/chuanlex/yaoxinw/software/nanopolish.11/nanopolish/bin:/share/home/chuanlex/yaoxinw/software/nanopolish.11/nanopolish/scripts:$PATH
export PATH=/share/home/chuanlex/yaoxinw/software/nanopolish:/share/home/chuanlex/yaoxinw/software/nanopolish/bin:/share/home/chuanlex/yaoxinw/software/nanopolish/scripts:$PATH
export PATH=~/xinnian/software/miniconda2/bin:$PATH
export LD_LIBRARY_PATH=~/xinnian/software/miniconda2/lib:$LD_LIBRARY_PATH
export PERL5LIB=~/xinnian/software/miniconda2/lib/perl5:$PERL5LIB
export PATH=$PATH:/share/home/chuanlex/yaoxinw/software/racon/build/bin
species=yeast
tool=necat
#tool=flye
fast5_dir=/share/home/chuanlex/yaoxinw/data/11.17.fast5/yeast/nas/hanyue/Data/20171214yeast303/GA10000/reads/
readpath=/share/home/chuanlex/yaoxinw/data/11.17.fast5/yeast/
summry=/share/home/chuanlex/yaoxinw/data/11.17.fast5/yeast/all_summary.txt
mkdir -p /share/home/chuanlex/yaoxinw/project/11.17_necat_est/result/$tool/${species}
draft_dir=/share/home/chuanlex/yaoxinw/project/11.17_necat_est/result/$tool/${species}
result_dir=$draft_dir
pilon_result=$draft_dir
ngs_file=/share/home/chuanlex/xiaochuanle/data/testdata/testdata_NGS/yeast/SRR5244182.fastq
cd ${draft_dir} 


if [[ $tool == "necat" ]]; then
    ln -s /share/home/chuanlex/niefan/test_necat/40X/$species/$tool/$species/6-bridge_contigs/polished_contigs.fasta ./draft.fa
elif [[ $tool == "flye" ]]; then
    ln -s /share/home/chuanlex/xiaochuanle/assembler/flye/$species/$species/assembly.fasta ./draft.fa
elif [[ $tool == "wtdbg2" ]];then
    ln -s /share/home/chuanlex/xiaochuanle/assembler/wtdbg2/$species/$species/${species}.cns.fa ./draft.fa
else
    echo "error tools"
fi

#nanopolish index -d $fast5_dir -s $summry $readpath/reads.fasta

bwa index draft.fa 1>> bwaindex.log 2>>bwaindex_error.log
#               Align the basecalled reads to the draft sequence
bwa mem -x ont2d -t 10 ${draft_dir}/draft.fa ${readpath}/reads.fasta | samtools view -bS - | samtools sort - reads.sorted
samtools index reads.sorted.bam

#                             polish  genome based on region
python /share/home/chuanlex/yaoxinw/software/nanopolish/scripts/nanopolish_makerange.py ${draft_dir}/draft.fa | parallel --results nanopolish.results -P 5 \
    nanopolish variants --consensus -o ${result_dir}/polished.{1}.vcf -w {1} -r ${readpath}/reads.fasta -b ${result_dir}/reads.sorted.bam -g ${draft_dir}/draft.fa -t 4 \
    --min-candidate-frequency 0.1
#                             merge
nanopolish vcf2fasta -g ${draft_dir}/draft.fa polished.*.vcf > polished.fasta

ngs_file=/share/home/chuanlex/xiaochuanle/data/testdata/testdata_NGS/yeast/SRR5244182.fastq

MEMORY=16

#############################round 1###################################################################################

#                        Index the draft genome
bwa index polished.fasta 1>> bwaindex.log 2>>bwaindex_error.log
#               Align the basecalled reads to the draft sequence
bwa mem -t 20 polished.fasta ${ngs_file} | samtools view -bS - | samtools sort - reads1.sorted
#                            samtools for bam
samtools index reads1.sorted.bam
#pilon
java -Xmx${MEMORY}G -jar /share/home/chuanlex/yaoxinw/software/pilon-1.22.jar --genome polished.fasta --bam reads1.sorted.bam \
    --fix snps,indels,gaps \
    --output pilon_polished1 --vcf >> pilon.log

############################# round 2##################################################################################
#                        Index the draft genome
bwa index pilon_polished1.fasta 1>> bwaindex.log 2>>bwaindex_error.log
#               Align the basecalled reads to the draft sequence
bwa mem -t 20 pilon_polished1.fasta ${ngs_file} | samtools view -bS - | samtools sort - reads2.sorted
#                            samtools for bam
samtools index reads2.sorted.bam
#pilon
java -Xmx${MEMORY}G -jar /share/home/chuanlex/yaoxinw/software/pilon-1.22.jar --genome pilon_polished1.fasta --bam reads2.sorted.bam \
    --fix snps,indels,gaps \
    --output pilon_polished2 --vcf >> pilon.log
##########################round3##########################################################################################
bwa index pilon_polished2.fasta 1>> bwaindex.log 2>>bwaindex_error.log
#               Align the basecalled reads to the draft sequence
bwa mem -t 20 pilon_polished2.fasta ${ngs_file} | samtools view -bS - | samtools sort - reads3.sorted
#                            samtools for bam
samtools index reads3.sorted.bam
#pilon
java -Xmx${MEMORY}G -jar /share/home/chuanlex/yaoxinw/software/pilon-1.22.jar --genome pilon_polished2.fasta --bam reads3.sorted.bam \
    --fix snps,indels,gaps \
    --output run3_pilon_polished --vcf >> pilon.log














