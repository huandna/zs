#PBS -N wyx_17_2
#PBS -j oe      
#PBS -l walltime=5000:00:00  
#PBS -l nodes=node05:ppn=20
#PBS -q com_q
#PBS -j n
export PATH=/share/home/chuanlex/zdy/soft/cellranger-3.0.2/cellranger-cs/3.0.2/bin:$PATH

NPR0C=20
refdir=/share/home/chuanlex/yaoxinw/project/cellranger_12.26/refdata-cellranger-GRCh38-3.0.0
wkd=/share/home/chuanlex/yaoxinw/project/cellranger_12.26/Retina

file1=/share/home/chuanlex/zhengyf/10x/Retina/HRetina-20190817-1/191025_A00838_0077_BHT7JNDSXX  
file2=/share/home/chuanlex/zhengyf/10x/Retina/HRetina-20190817-1/191102_A00869_0096_BHTFVFDSXX
cd $wkd
file3=/share/home/chuanlex/zhengyf/10x/Retina/HRetina-20190827-1/191025_A00838_0077_BHT7JNDSXX
file4=/share/home/chuanlex/zhengyf/10x/Retina/HRetina-20190827-2/191025_A00838_0077_BHT7JNDSXX
file5=/share/home/chuanlex/zhengyf/10x/Retina/HRetina-20190817-2/191025_A00838_0077_BHT7JNDSXX
file6=/share/home/chuanlex/zhengyf/10x/IPS-d28-B3-scRNA/

cellranger count \
 --id=HRetina-20190817-2 \
 --localcores=$NPR0C \
 --transcriptome=$refdir \
 --fastqs=$file5 \
 --sample=HRetina-20190817-2 \
 --nosecondary \
 --force-cells=10000 \
 --localmem=500 
