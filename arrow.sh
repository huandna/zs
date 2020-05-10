#PBS -N ara_1
#PBS -l nodes=1:ppn=20
#PBS -j oe
#PBS -l walltime=5000:00:00
#PBS -q com_q

export PATH="${PATH}:/share/home/chuanlex/xiaochuanle/software/smrtlink5/smrtcmds/bin"
export PATH="${PATH}:/share/home/chuanlex/yaoxinw/software/export/Script"
Samtools="/share/home/chuanlex/xiaochuanle/software/smrtlink5/smrtcmds/bin/samtools"
scriptPath="/share/home/chuanlex/yaoxinw/software/export/Script/Arrow"
Sample=ara
tool=necat2-40X
#tool=flye
species=$Sample
Sequel_bam_path=/share/home/chuanlex/yaoxinw/project/arrow/arab/raw_data    # Sequel subreads bam path: Subreads bam path (Absolute Path)

mkdir -p /share/home/chuanlex/yaoxinw/project/11.17_necat_est/result/$tool/${species}
draft_dir=/share/home/chuanlex/yaoxinw/project/11.17_necat_est/result/$tool/${species}
outdir=$draft_dir
cd ${draft_dir} 


if [[ $tool == "necat2-40X" ]]; then
    ln -s /share/home/chuanlex/xiaochuanle/assembler/necat2-40X/$species/$species/6-bridge_contigs/polished_contigs.fasta ./draft.fa
elif [[ $tool == "flye" ]]; then
    ln -s /share/home/chuanlex/xiaochuanle/assembler/flye/$species/$species/assembly.fasta ./draft.fa
elif [[ $tool == "wtdbg2" ]];then
    ln -s /share/home/chuanlex/xiaochuanle/assembler/wtdbg2/$species/$species/${species}.cns.fa ./draft.fa
else
    echo "error tools"
fi

Reference=$draft_dir


echo "blasr  begin at $(date)" >> ${outdir}/log
blasr ${Sequel_bam_path}/*.bam ${Reference}/draft.fa --out ${outdir}/subreads.blasr.bam --bam  --bestn 5 --minMatch 18  --nproc 20 --minSubreadLength 1000 --minAlnLength 500  \
                                            --minPctSimilarity 70 --minPctAccuracy 70 --hitPolicy randombest  --randomSeed 1
echo "blasr  end at $(date)" >> ${outdir}/log
cd ${Reference}
samtools faidx ${Reference}/draft.fa
cd ${outdir}
echo "samtools sort begin at $(date)" >> ${outdir}/log
samtools sort subreads.blasr.bam -o subreads.blasr.sorted.bam
echo "samtools sort end at $(date)" >> ${outdir}/log
pbindex ${outdir}/subreads.blasr.sorted.bam
echo "pbindex end index at $(date)" >> ${outdir}/log
arrow -j 20 ${outdir}/subreads.blasr.sorted.bam --referenceFilename=${Reference}/draft.fa -o ${outdir}/${Sample}.arrow.fasta -o ${outdir}/${Sample}.arrow.gff
echo "arrow end index at $(date)" >> ${outdir}/log

