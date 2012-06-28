#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly LINES=$1
readonly SUFFIX=$2
readonly INPUT=$3
readonly OUTPUT=$4

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 4

echo "split -l ${LINES} -a ${SUFFIX} ${INPUT} ${OUTPUT}"
split -l ${LINES} -a ${SUFFIX} ${INPUT} ${OUTPUT}

