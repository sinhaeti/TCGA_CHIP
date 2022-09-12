#!/bin/bash

#SBATCH --job-name=TCGA_CHIP_Script
#SBATCH --partition=panda_physbio
#SBATCH --begin=now
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=28G
#SBATCH --time=1-00:00:00
#SBATCH --exclude=node002.panda.pbtech,node007.panda.pbtech,node010.panda.pbtech
source ~/.bashrc

###### LOAD IN VARIABLES ######
#INPUT_DIR=$2
#OUTPUT_DIR=$3
#SAMPLE_PREFIX=$5

SCRIPT_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/scripts/"
INPUT_VCF_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/TCGA_BAMS/renamed_vcfs"
OUTPUT_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/TCGA_FILTERED_CALLS/tumor"

#ASSEMBLY_REFGENE="hg38"
BWA_GREF="/athena/elementolab/scratch/es984/tcga_38_genome_files/GRCh38.d1.vd1.fa"
FUNCOTATOR_SOURCES="/athena/elementolab/scratch/es984/tools/funcotator/funcotator_dataSources.v1.6.20190124s"

# From Sym-links, get file prefix and full path for 
MUTECT2_VCF=$1
PREFIX=$(basename $MUTECT2_VCF .vcf)
MUTECT2_VCF_FILE_PATH=$(readlink -f $MUTECT2_VCF)


######### TRACK JOB #########
#Module Loading and Sourcing
DATE=$(date '+%d/%m/%Y %H:%M:%S');
echo "$DATE"

## CHANGE TO DIFFERENT FOLDER (TMP)
cd $TMPDIR
TEMP=$(basename ${OUTPUT_DIR})
mkdir ${TEMP}; cd ${TEMP}

####### START JOB #########
echo "Sample name is ${SAMPLE_PREFIX}"
echo  "=============================="

# takes 25 minutes with 16GB for somatic variant calling in blood
# takes 1 minute with 8GB for somatic variant calling in tumor
if [ ! -f "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf" ]; then
    echo "Filtering somatic variants with FilterMutectCalls..."
    conda activate gatk
    gatk FilterMutectCalls \
        --variant "${MUTECT2_VCF_FILE_PATH}" \
        --output "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf" \
        --reference "${BWA_GREF}"
    conda deactivate
    echo "...somatic variants filtered."
else
    echo "Mutect2 somatic variants already filtered"
fi

# takes 51 minutes with 16GB for somatic variant calling in tumor
if [ ! -f "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf" ]; then
    echo "Annotating Mutect2 VCF with Funcotator..."
    conda activate gatk
    gatk Funcotator \
         --variant "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf" \
         --reference "${BWA_GREF}" \
         --ref-version hg38 \
         --data-sources-path "${FUNCOTATOR_SOURCES}" \
         --output "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf" \
         --output-file-format VCF 
    conda deactivate
    echo "...VCF annotated."
else
    echo "Mutect2 VCF already annotated"
fi