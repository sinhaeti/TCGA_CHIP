#!/bin/bash

# check if all inputs are specified
if [ -z $1 ] ; then
    echo "run_mutect_filter"
    echo ""
    echo "tissue: 'blood' or 'tumor'"
else
    # Variables 
    SCRIPT_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/scripts/"
    
    # INPUT AND OUTPUT DIRECTORY 
    TISSUE=$1
    INPUT_VCF_DIR="/home/es984/oelab_es984/TCGA_CHIP/TCGA_BAMS/chip_calls_10182023/"
    #INPUT_VCF_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/TCGA_BAMS/renamed_vcfs/${TISSUE}/"
    OUTPUT_DIR="/athena/elementolab/scratch/es984/TCGA_CHIP/TCGA_FILTERED_CALLS/${TISSUE}/"
    
    #VCF_PATHS="${SCRIPT_DIR}/TCGA_CHIP_${TISSUE}_samples.txt" #give a path to a file to store the paths to the fastq files in $fastq_directory

    #ls "${INPUT_VCF_DIR}/"* | grep ".vcf" | sort -u > ${VCF_PATHS} #generate list of full paths to fastq files and save to the file in $fastq_list

    ####### ALIGNMENT AND VARIANT CALLING  #########
    #VCF_PATHS_LIST=$(cat $VCF_PATHS)
    for SAMPLE_SYM_PATH in ${INPUT_VCF_DIR}/*vcf.gz
    do
        if [ ! -f "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect2_filter_funcotator_coding.vcf" ]; then 

            SAMPLE_PREFIX=$(basename $SAMPLE_SYM_PATH .vcf.gz)
            
            echo "Sending job for ${SAMPLE_PREFIX}"
            sbatch \
            -o "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect_filter_log" \
            -e "${OUTPUT_DIR}/${SAMPLE_PREFIX}_mutect_filter_log" \
            "${SCRIPT_DIR}/mutect_filter.sh" \
            "${SAMPLE_SYM_PATH}" \
            "${OUTPUT_DIR}"
        fi
    done

fi


echo " Script $0 is complete"
DATE=$(date '+%d/%m/%Y %H:%M:%S');
echo "$DATE"


