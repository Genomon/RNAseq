#! /bin/bash
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

write_usage() {
  echo ""
  echo "Usage: `basename $0` [options] <rna.env> <output directory> <tag>"
  echo ""
}

readonly RNA_ENV=$1
readonly OUTPUTDIR=$2
readonly TAG=$3

if [ $# -ne 3 ]; then
  echo "wrong number of arguments"
  write_usage
  exit 1
fi

if [ ! -f ${RNA_ENV} ]; then
  echo "${RNA_ENV} dose not exists"
  write_usage
  exit 1
fi

source ${RNA_ENV}
source ${UTIL}

readonly INPUTDIR=${OUTPUTDIR}/sequence
readonly FUSIONDIR=${OUTPUTDIR}/fusion

# input file check
check_file_exists ${INPUTDIR}/sequence.bam
# make output directory
check_mkdir ${FUSIONDIR}/tmp

readonly CURLOGDIR=${LOGDIR}/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}


readonly FILECOUNT=`find ${INTERVAL}/*.interval_list | wc -l`

readonly JOB_JUNC_BLAT=juncBlat.${TAG}
readonly JOB_CAT_FUSION=catFusion.${TAG}
readonly JOB_MAKE_SEQ=makeSeq.${TAG}
readonly JOB_MAKE_CONTIG=makeContig.${TAG}


echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=16G,mem_req=16 -N ${JOB_JUNC_BLAT} ${LOGSTR} ${COMMAND_FUSION}/juncBlat.sh ${OUTPUTDIR}"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=16G,mem_req=16 -N ${JOB_JUNC_BLAT} ${LOGSTR} ${COMMAND_FUSION}/juncBlat.sh ${OUTPUTDIR}

echo "qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=8G,mem_req=8 -N ${JOB_CAT_FUSION} -hold_jid ${JOB_JUNC_BLAT} ${LOGSTR} ${COMMAND_FUSION}/catCandFusion.sh ${OUTPUTDIR}"
qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=8G,mem_req=8 -N ${JOB_CAT_FUSION} -hold_jid ${JOB_JUNC_BLAT} ${LOGSTR} ${COMMAND_FUSION}/catCandFusion.sh ${OUTPUTDIR}

echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 -N ${JOB_MAKE_SEQ} -hold_jid ${JOB_CAT_FUSION} ${LOGSTR} ${COMMAND_FUSION}/makeComb2seq.sh ${OUTPUTDIR}"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 -N ${JOB_MAKE_SEQ} -hold_jid ${JOB_CAT_FUSION} ${LOGSTR} ${COMMAND_FUSION}/makeComb2seq.sh ${OUTPUTDIR}

echo "qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=8G,mem_req=8 -N ${JOB_MAKE_CONTIG} -hold_jid ${JOB_MAKE_SEQ} ${LOGSTR} ${COMMAND_FUSION}/makeContig.sh ${OUTPUTDIR} ${TAG}"
qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=8G,mem_req=8 -N ${JOB_MAKE_CONTIG} -hold_jid ${JOB_MAKE_SEQ} ${LOGSTR} ${COMMAND_FUSION}/makeContig.sh ${OUTPUTDIR} ${TAG}


