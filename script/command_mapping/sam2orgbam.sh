#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly SAM=$1
readonly BAMtmp=$2
readonly BAMsorted=$3
readonly BAMdedup=$4
readonly METRICS=$5

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 5

readonly RECORDS_IN_RAM=5000000

echo "java SamFormatConverter.jar"
${JAVAPATH}/java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/SamFormatConverter.jar INPUT=${SAM} OUTPUT=${BAMtmp} VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java SortSam.jar"
${JAVAPATH}/java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/SortSam.jar INPUT=${BAMtmp} OUTPUT=${BAMsorted} SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java MarkDuplicates.jar"
${JAVAPATH}/java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/MarkDuplicates.jar INPUT=${BAMsorted} OUTPUT=${BAMdedup} METRICS_FILE=${METRICS} VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

echo "java BuildBamIndex.jar"
${JAVAPATH}/java -Xms4g -Xmx7g -Djava.io.tmpdir=${TEMPDIR} -jar ${PICARD_PATH}/BuildBamIndex.jar INPUT=${BAMdedup} VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=${RECORDS_IN_RAM}
check_error $?

rm ${BAMtmp}
rm ${BAMsorted}

