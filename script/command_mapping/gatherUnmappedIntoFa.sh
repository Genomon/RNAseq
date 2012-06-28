#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly INPUT=$1
readonly OUTPUT=$2

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 2

readonly SUFFIX=`sh ${COMMAND_MAPPING}/getSuffix.sh ${SGE_TASK_ID}`

echo "perl ${COMMAND_MAPPING}/gatherUnmappedIntoFa.pl ${INPUT}.${SUFFIX} > ${OUTPUT}.${SUFFIX}"
perl ${COMMAND_MAPPING}/gatherUnmappedIntoFa.pl ${INPUT}.${SUFFIX} > ${OUTPUT}.${SUFFIX}

