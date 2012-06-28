#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

readonly NUM=${SGE_TASK_ID}

readonly OUTPUTDIR=$1

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 1

readonly SEQDIR=${OUTPUTDIR}/sequence
readonly TARGETDIR=${OUTPUTDIR}/fusion

REGION_A=`head -n1 ${INTERVAL}/${NUM}.interval_list | awk '{split($0, ARRAY, "-"); print ARRAY[1]}'`
REGION_B=`tail -n1 ${INTERVAL}/${NUM}.interval_list | awk '{split($0, ARRAY, "-"); print ARRAY[2]}'`
REGION="${REGION_A}-${REGION_B}"
echo ${REGION} 


echo "${SAMTOOLS_PATH}/samtools view -h -F 1024 ${SEQDIR}/sequence.bam ${REGION} > ${TARGETDIR}/tmp/temp${NUM}.sam"
${SAMTOOLS_PATH}/samtools view -h -F 1024 ${SEQDIR}/sequence.bam ${REGION} > ${TARGETDIR}/tmp/temp${NUM}.sam
check_error $?


echo "perl ${COMMAND_FUSION}/getCandJunc.pl ${TARGETDIR}/tmp/temp${NUM}.sam 20 16 > ${TARGETDIR}/tmp/candJunc${NUM}.fa"
perl ${COMMAND_FUSION}/getCandJunc.pl ${TARGETDIR}/tmp/temp${NUM}.sam 20 16 > ${TARGETDIR}/tmp/candJunc${NUM}.fa
check_error $?


echo "${BLAT_PATH}/blat -stepSize=5 -repMatch=2253 -ooc=${BLAT_OOC} ${BLAT_REF} ${TARGETDIR}/tmp/candJunc${NUM}.fa ${TARGETDIR}/tmp/candJunc${NUM}.psl"
${BLAT_PATH}/blat -stepSize=5 -repMatch=2253 -ooc=${BLAT_OOC} ${BLAT_REF} ${TARGETDIR}/tmp/candJunc${NUM}.fa ${TARGETDIR}/tmp/candJunc${NUM}.psl
check_error $?


echo "perl ${COMMAND_FUSION}/psl2junction.pl ${TARGETDIR}/tmp/candJunc${NUM}.psl ${TARGETDIR}/tmp/countJunc${NUM}.txt ${TARGETDIR}/tmp/junc2ID${NUM}.txt"
perl ${COMMAND_FUSION}/psl2junction.pl ${TARGETDIR}/tmp/candJunc${NUM}.psl ${TARGETDIR}/tmp/countJunc${NUM}.txt ${TARGETDIR}/tmp/junc2ID${NUM}.txt
check_error $?



