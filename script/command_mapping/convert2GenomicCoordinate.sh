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

SUFFIX=`sh ${COMMAND_MAPPING}/getSuffix.sh ${SGE_TASK_ID}`

bash ${COMMAND_MAPPING}/sleep.sh

echo "perl ${COMMAND_MAPPING}/convert2GenomicCoordinate.pl ${INPUT}.${SUFFIX} ${DBDIR}/knownGene.info > ${OUTPUT}.${SUFFIX}.tmp"
perl ${COMMAND_MAPPING}/convert2GenomicCoordinate.pl ${INPUT}.${SUFFIX} ${DBDIR}/knownGene.info > ${OUTPUT}.${SUFFIX}.tmp
check_error $?

echo "perl ${COMMAND_MAPPING}/getUniqueReads.pl ${OUTPUT}.${SUFFIX}.tmp > ${OUTPUT}.${SUFFIX}"
perl ${COMMAND_MAPPING}/getUniqueReads.pl ${OUTPUT}.${SUFFIX}.tmp > ${OUTPUT}.${SUFFIX}
check_error $?

rm ${OUTPUT}.${SUFFIX}.tmp
check_error $?

