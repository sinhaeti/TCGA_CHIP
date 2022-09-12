#!/bin/bash

# check if all inputs are specified
if [ -z $1 ] ; then
    echo "run_mutect_filter"
    echo ""
    echo "tissue: blood or tumor"
else
    # Constant Variables 
    SCRIPT_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/scripts/"
    INPUT_VCF_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/TCGA_BAMS/renamed_vcfs/tumor/"
    OUTPUT_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/TCGA_FILTERED_CALLS/tumor/"

    #ASSEMBLY_REFGENE="hg38"
    BWA_GREF="/athena/elementolab/scratch/es984/tcga_38_genome_files/GRCh38.d1.vd1.fa"
    FUNCOTATOR_SOURCES="/athena/elementolab/scratch/es984/tools/funcotator/funcotator_dataSources.v1.6.20190124s"
    
    VCF_PATHS="${SCRIPT_DIR}/TCGA_CHIP_blood_samples.txt" #give a path to a file to store the paths to the fastq files in $fastq_directory

    ls "${INPUT_VCF_DIR}/"* | grep ".vcf" | sort -u > ${VCF_PATHS} #generate list of full paths to fastq files and save to the file in $fastq_list

    ####### ALIGNMENT AND VARIANT CALLING  #########
    VCF_PATHS_LIST=$(cat $VCF_PATHS)
    for SAMPLE_SYM_PATH in ${VCF_PATHS_LIST}
    do
        SAMPLE_PREFIX=$(basename $SAMPLE_SYM_PATH .vcf)
        
        echo "Sending job for ${SAMPLE_PREFIX}"
        sbatch \
        -o "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect_filter_log" \
        -e "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect_filter_log" \
        "${SCRIPT_DIR}/mutect_filter.sh" \
        "${SAMPLE_SYM_PATH}"
    done

fi


echo " Script $0 is complete for sequencing run ${RUN_NAME}"
DATE=$(date '+%d/%m/%Y %H:%M:%S');
echo "$DATE"


