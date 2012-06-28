#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly INPUT_FA=$1
readonly OUTPUT_SAM=$2
readonly OUTPUT_PSL=${OUTPUT_SAM}.psl

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 2

readonly SUFFIX=`sh ${COMMAND_MAPPING}/getSuffix.sh ${SGE_TASK_ID}`

sleep `expr ${RANDOM} % 240`

echo "${BLAT_PATH}/blat -stepSize=5 -repMatch=2253 -ooc=${BLAT_OOC} ${BLAT_REF} ${INPUT_FA}.${SUFFIX} ${OUTPUT_PSL}.${SUFFIX}"
${BLAT_PATH}/blat -stepSize=5 -repMatch=2253 -ooc=${BLAT_OOC} ${BLAT_REF} ${INPUT_FA}.${SUFFIX} ${OUTPUT_PSL}.${SUFFIX}
check_error $?

echo "perl ${COMMAND_MAPPING}/my_psl2sam.pl ${OUTPUT_PSL}.${SUFFIX} ${INPUT_FA}.${SUFFIX} blat 20 > ${OUTPUT_SAM}.${SUFFIX}"
perl ${COMMAND_MAPPING}/my_psl2sam.pl ${OUTPUT_PSL}.${SUFFIX} ${INPUT_FA}.${SUFFIX} blat 20 > ${OUTPUT_SAM}.${SUFFIX}
check_error $?

