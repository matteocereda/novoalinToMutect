#!/bin/sh

## Set the working Directorty to be the current one, i.e. where you are submitting the script
#$ -cwd

#$ -j y

## Job Name, can be anything##
#$ -N Mutect

## Set the SHELL type to be sh##
#$ -S /bin/sh

# you need to load these software
module load samtools
module load picard-tools/1.74
module load jdk/1.7.0_07 

PICARD="java -Xmx8g -jar /apps/picardtools/1.74/AddOrReplaceReadGroups.jar"
REORDER="java -Xmx8g -jar /apps/picardtools/1.74/ReorderSam.jar"
INDEX="samtools index"

infolder='/home/FC/ClonalExpansion/WholeExome/140807_KCL'
outfolder="/home/FC/ClonalExpansion/BAM_for_Mutect"
genome_ref='/home/FC/DB/Genomes/Hs_v37/hg19.fa'

# Prepare the NORMAL AND TUMOUR BAM files to be used in Mutect
id="UH1N"
bam="UH1N_srt_OT"
$PICARD I=${infolder}/${id}/aligned/${bam} O=${outfolder}/${bam}.bam RGID=${id} RGLB="lib-${id}" RGPL="ILLUMINA" RGPU="unkn-0.0" RGSM="Illumina-Hiseq-Novoaling" VALIDATION_STRINGENCY=LENIENT 
$REORDER I=${outfolder}/${bam}.bam O=${outfolder}/${bam}.ordered.bam R=${genome_ref}
$INDEX ${outfolder}/${bam}.ordered.bam

id="UH1T1"
bam="UH1T1"
$PICARD I=${infolder}/${id}/aligned/${bam} O=${outfolder}/${bam}.bam O=${infolder}/${bam}.bam RGID=${id} RGLB="lib-${id}" RGPL="ILLUMINA" RGPU="unkn-0.0" RGSM="Illumina-Hiseq-Novoaling" VALIDATION_STRINGENCY=LENIENT 2>${infolder}/AddOrReplaceReadGroups_${id}.err
$REORDER I=${infolder}/${bam}.bam O=${infolder}/${bam}.ordered.bam R=${genome_ref}
$INDEX ${infolder}/${bam}.ordered.bam

# Run MUTECT

MUTECT="java -Xmx16g -jar /home/ceredam/Software/mutect-1.1.7.jar --analysis_type MuTect --enable_extended_output --useOriginalQualities "
COSMIC="/home/FC/DB/COSMIC/74/Cosmic.hg19.vcf"
DBSNP138="dbsnp_138.hg19.vcf"
infolder="/home/FC/ClonalExpansion/BAM_for_Mutect"
outfolder="Results"

Nbam="UH1N_srt_OT.ordered.bam"
bam="UH1N_srt_OT.ordered.bam"
id="UH1T1"
$MUTECT --reference_sequence ${genome_ref} --cosmic ${COSMIC} --dbsnp ${DBSNP138} --input_file:normal ${infolder}/${Nbam} --input_file:tumor ${infolder}/${bam} --out ${outfolder}/${id}.call_stats.out #--coverage_file ${outfolder}/${id}.wig.txt




