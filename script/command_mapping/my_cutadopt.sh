#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly ADAPTER_NUM=$1
readonly SUBSTR_LENGTH=$2
readonly INPUT_FASTQ=$3
readonly OUTPUT_FASTQ=$4
readonly OUTPUT_RESULT=$5

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 5

echo "perl ${COMMAND_MAPPING}/my_cutadopt.pl ${ADAPTER_NUM} ${SUBSTR_LENGTH} ${INPUT_FASTQ} ${OUTPUT_FASTQ} ${OUTPUT_RESULT}"
perl ${COMMAND_MAPPING}/my_cutadopt.pl ${ADAPTER_NUM} ${SUBSTR_LENGTH} ${INPUT_FASTQ} ${OUTPUT_FASTQ} ${OUTPUT_RESULT}

