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

echo "${BOWTIE_PATH}/bowtie ${BOWTIE_INDEX} -a --best --strata -m 20 -v 3 -p 1 -S ${INPUT}.${SUFFIX} ${OUTPUT}.${SUFFIX}"
${BOWTIE_PATH}/bowtie ${BOWTIE_INDEX} -a --best --strata -m 20 -v 3 -p 1 -S ${INPUT}.${SUFFIX} ${OUTPUT}.${SUFFIX}

