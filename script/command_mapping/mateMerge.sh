#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly SEQ1_SAM=$1
readonly SEQ2_SAM=$2
readonly OUTPUT_SAM=$3

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 3

readonly SUFFIX=`sh ${COMMAND_MAPPING}/getSuffix.sh ${SGE_TASK_ID}`

echo "perl ${COMMAND_MAPPING}/mateMerge.pl ${SEQ1_SAM}.${SUFFIX} ${SEQ2_SAM}.${SUFFIX} > ${OUTPUT_SAM}.${SUFFIX}"
perl ${COMMAND_MAPPING}/mateMerge.pl ${SEQ1_SAM}.${SUFFIX} ${SEQ2_SAM}.${SUFFIX} > ${OUTPUT_SAM}.${SUFFIX}


