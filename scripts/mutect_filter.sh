#!/bin/bash

#SBATCH --job-name=TCGA_CHIP_Filter_Script
#SBATCH --partition=panda_physbio
#SBATCH --begin=now
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --time=1-00:00:00
#SBATCH --exclude=node002.panda.pbtech,node007.panda.pbtech,node010.panda.pbtech
source ~/.bashrc

###### LOAD IN VARIABLES ######
#ASSEMBLY_REFGENE="hg38"
BWA_GREF="/athena/elementolab/scratch/es984/tcga_38_genome_files/GRCh38.d1.vd1.fa"
FUNCOTATOR_SOURCES="/athena/elementolab/scratch/es984/tools/funcotator/funcotator_dataSources.v1.6.20190124s"

# From Sym-links, get file prefix and full path for 
SAMPLE_SYM_PATH=$1
SAMPLE_PREFIX=$(basename $SAMPLE_SYM_PATH .vcf.gz)
SAMPLE_TRUE_PATH=$(readlink -f $SAMPLE_SYM_PATH)

OUTPUT_DIR=$2

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

if [ ! -f "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator_coding.vcf" ]; then 
    if [ ! -f "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf" ]; then
        echo "Filtering somatic variants with FilterMutectCalls..."
        conda activate gatk
        gatk FilterMutectCalls \
            --variant "${SAMPLE_TRUE_PATH}" \
            --output "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf" \
            --reference "${BWA_GREF}"
        conda deactivate
        echo "...somatic variants filtered."
    else
        echo "Mutect2 somatic variants already filtered"
    fi

    # takes 51 minutes with 16GB for somatic variant calling in tumor
    # takes 2 minutes with 8GB for somatic variant calling in tumor
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

    ## Filter for header and coding variants 
    grep -E "^#|FRAME_SHIFT_DEL|FRAME_SHIFT_INS|MISSENSE|NONSENSE|SPLICE_SITE" <  "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf" > "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator_coding.vcf"

    # rm intermediary files to save space
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf.idx
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf.filteringStats.tsv
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf.idx
else
    # rm intermediary files to save space
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf.idx
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf.filteringStats.tsv
    rm -rf ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter.vcf.idx
    
    echo "Filtered Coding-only Mutect2 VCF already generated"
    echo "File path is ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator_coding.vcf"
fi


#for file in *_mutect2_filter.vcf; do
#    grep -E "^#|FRAME_SHIFT_DEL|FRAME_SHIFT_INS|MISSENSE|NONSENSE|SPLICE_SITE" <  "${file}" > "${file%.vcf}_funcotator_coding.vcf"
#done

#zcat ${VARDICT_TMP2_VCF} | \

#        bcftools filter -e "SBF[0] < ${SB_PVAL} | ODDRATIO[0] > ${SB_ODDRATIO} | SBF[1] < ${SB_PVAL} | ODDRATIO[1] > ${SB_ODDRATIO}" -s "strictSB" -m + | \
#        bcftools filter -e "INFO/DP < ${MIN_DEPTH}" -s "d${MIN_DEPTH}" -m + | \
#        bcftools filter -e "INFO/VD < ${MIN_VAR_READS}" -s "hi.v.${MIN_VAR_READS}" -m + | \
#        bcftools filter -e '((EntropyLeft < 1 | EntropyRight < 1 | EntropyCenter < 1)) & TYPE!="SNP" & HIAF < 0.05' -s "IndelEntropy" -m + > ${VARDICT_TMP3_VCF}


#Filter for somatic variants
#if [ ! -f "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator_vf.vcf" ]; then
#    echo "Annotating Mutect2 VCF with Funcotator..."
#    conda activate gatk
#    gatk VariantFiltration \
#         --variant "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf" \
#         --reference "${BWA_GREF}" \
#         --output "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator_vf.vcf" \
#         --filter-name "CHIP_Filter" \
#         --filter-expression "AF > 0.01 && AF < 0.4 && DP > 100" 
#    conda deactivate
#    echo "...VCF annotated."
#else
#    echo "Mutect2 VCF already annotated"
#fi



# Filter for calls in OG list of TCGA-CHIP variants


#Remove unnecessary intermediate files
echo "Final file can be found at ${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator.vcf"

echo " Script $0 is complete for sample ${SAMPLE_PREFIX}"
DATE=$(date '+%d/%m/%Y %H:%M:%S');
echo "$DATE"