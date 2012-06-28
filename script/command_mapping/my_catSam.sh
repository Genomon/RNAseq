#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly INPUTPATH=$1
readonly INPUTFILE=$2
readonly OUTPUT=$3
readonly HEADER=$4

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 4

strfiles=${HEADER}

cat ${HEADER} > ${OUTPUT}

for file in `find ${INPUTPATH} -name "${INPUTFILE}"`
do
  echo "cat ${file} >> ${OUTPUT}"
  cat ${file} >> ${OUTPUT}
done


