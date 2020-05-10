#PBS -N medaka
#PBS -l nodes=1:ppn=20
#PBS -j oe
#PBS -l walltime=5000:00:00
#PBS -q com_q

export PATH="${PATH}:/share/home/chuanlex/xiaochuanle/software/smrtlink5/smrtcmds/bin"
export PATH="${PATH}:/share/home/chuanlex/yaoxinw/software/export/Script"
export PATH=$PATH:/share/home/chuanlex/yaoxinw/software/racon/build/bin
export PATH=$PATH:~/xinnian/software/miniconda2/bin
export LD_LIBRARY_PATH=~/xinnian/software/miniconda2/lib:$LD_LIBRARY_PATH
export PERL5LIB=~/xinnian/software/miniconda2/lib/perl5:$PERL5LIB
  
outdir=/share/home/chuanlex/yaoxinw/project/medaka/dro
readpath=${outdir}
Reference=${outdir}
cd ${outdir}
#echo "racon begin at $(date)" > ${outdir}/log
# Iteration 1
minimap2 ${Reference}/draft.fa ${readpath}/reads.fq > ONTmin_IT0.paf
time racon -m 8 -x -6 -g -8 -w 500 -t 20 ${readpath}/reads.fq ONTmin_IT0.paf ${Reference}/draft.fa > ONTmin_IT1.fasta
# Iteration 2
minimap2 ONTmin_IT1.fasta ${readpath}/reads.fq > ONTmin_IT1.paf
time racon -m 8 -x -6 -g -8 -w 500 -t 20 ${readpath}/reads.fq ONTmin_IT1.paf ONTmin_IT1.fasta > ONTmin_IT2.fasta
# Iteration 3
minimap2 ONTmin_IT2.fasta ${readpath}/reads.fq > ONTmin_IT2.paf
time racon -m 8 -x -6 -g -8 -w 500 -t 20 ${readpath}/reads.fq ONTmin_IT2.paf ONTmin_IT2.fasta > ONTmin_IT3.fasta
# Iteration 4
minimap2 ONTmin_IT3.fasta ${readpath}/reads.fq > ONTmin_IT3.paf
time racon -m 8 -x -6 -g -8 -w 500 -t 20 ${readpath}/reads.fq ONTmin_IT3.paf ONTmin_IT3.fasta > ONTmin_IT4.fasta

source activate /share/home/chuanlex/ysq/software/smrtsv/pacbio_variant_caller/dist/miniconda/envs/python3
export PATH=/share/home/chuanlex/yaoxinw/software/samtools-1.9:$PATH
export PATH=/share/home/chuanlex/yaoxinw/software/minimap2-2.17_x64-linux/:$PATH
export PATH=/share/home/chuanlex/yaoxinw/software/htslib-1.9:$PATH


#source ${MEDAKA}  # i.e. medaka/venv/bin/activate
NPROC=20
BASECALLS=${readpath}/reads.fq
DRAFT=${Reference}/ONTmin_IT4.fasta
OUTDIR=${outdir}
cd $OUTDIR
medaka_consensus -i ${BASECALLS} -d ${DRAFT} -o ${OUTDIR} -t ${NPROC} -m r941_min_high


