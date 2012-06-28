#!/bin/bash
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

echo "${MAQ_PATH} sol2sanger ${INPUT} ${OUTPUT}"
${MAQ_PATH} sol2sanger ${INPUT} ${OUTPUT}

