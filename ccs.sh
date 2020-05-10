#PBS -N wyx_ccs
#PBS -j oe      
#PBS -l walltime=5000:00:00  
#PBS -l nodes=1:ppn=20
#PBS -q com_q
#PBS -j n
# 以P2586-4为例
export PATH=/share/home/chuanlex/yaoxinw/software/smrtlink_8/smrtcmds/bin:$PATH
wkd=/share/home/chuanlex/yaoxinw/project/zhengyf
cd $wkd
inbam=$wkd/4_D01/m64064_191203_025635.subreads.bam
ccs ${inbam} OUT.ccs.bam --min-passes 1 --min-length 50 --max-length 21000 --min-rq 0.8 -j 20
