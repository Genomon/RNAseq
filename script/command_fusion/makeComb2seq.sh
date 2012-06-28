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

readonly FUSIONDIR=${OUTPUTDIR}/fusion

# get the sequence information for comb2ID2.txt
echo "perl ${COMMAND_FUSION}/makeComb2seq.pl ${FUSIONDIR}/comb2ID2.txt ${FUSIONDIR}/tmp/temp${NUM}.sam > ${FUSIONDIR}/tmp/comb2seq.tmp${NUM}.txt"
perl ${COMMAND_FUSION}/makeComb2seq.pl ${FUSIONDIR}/comb2ID2.txt ${FUSIONDIR}/tmp/temp${NUM}.sam > ${FUSIONDIR}/tmp/comb2seq.tmp${NUM}.txt

