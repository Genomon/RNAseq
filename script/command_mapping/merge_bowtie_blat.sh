#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly INPUT_BOWTIE=$1
readonly INPUT_BLAT=$2
readonly OUTPUT=$3

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 3

readonly SUFFIX=`sh ${COMMAND_MAPPING}/getSuffix.sh ${SGE_TASK_ID}`

bash ${COMMAND_MAPPING}/sleep.sh

echo "perl ${COMMAND_MAPPING}/merge_bowtie_blat.pl ${INPUT_BOWTIE}.${SUFFIX} ${INPUT_BLAT}.${SUFFIX} > ${OUTPUT}.${SUFFIX}"
perl ${COMMAND_MAPPING}/merge_bowtie_blat.pl ${INPUT_BOWTIE}.${SUFFIX} ${INPUT_BLAT}.${SUFFIX} > ${OUTPUT}.${SUFFIX}

