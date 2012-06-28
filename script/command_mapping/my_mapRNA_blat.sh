#! /bin/bash
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

write_usage() {
  echo ""
  echo "Usage: `basename $0` <rna.env> <output directory> <tag>"
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

readonly OUTPUTDATADIR_BOWTIE=${OUTPUTDIR}/sequence/map_bowtie
readonly OUTPUTDATADIR_BLAT=${OUTPUTDIR}/sequence/map_blat

readonly CURLOGDIR=${LOGDIR}/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

# input file check
file_count_check=`find ${OUTPUTDATADIR_BOWTIE}/aligned/sequence1.sam.*`
check_error $?

readonly FILECOUNT=`find ${OUTPUTDATADIR_BOWTIE}/aligned/sequence1.sam.* | wc -l`

readonly JOB_UNMAPPED1=gatherUnmappedIntoFa.${TAG}.1
readonly JOB_UNMAPPED2=gatherUnmappedIntoFa.${TAG}.2
readonly JOB_BLAT1=my_blat.${TAG}.1
readonly JOB_BLAT2=my_blat.${TAG}.2


echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 ${LOGSTR} -N ${JOB_UNMAPPED1} ${COMMAND_MAPPING}/gatherUnmappedIntoFa.sh ${OUTPUTDATADIR_BOWTIE}/aligned/sequence1.sam ${OUTPUTDATADIR_BLAT}/unmapped/sequence1.fa"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 ${LOGSTR} -N ${JOB_UNMAPPED1} ${COMMAND_MAPPING}/gatherUnmappedIntoFa.sh ${OUTPUTDATADIR_BOWTIE}/aligned/sequence1.sam ${OUTPUTDATADIR_BLAT}/unmapped/sequence1.fa

echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 ${LOGSTR} -N ${JOB_UNMAPPED2} ${COMMAND_MAPPING}/gatherUnmappedIntoFa.sh ${OUTPUTDATADIR_BOWTIE}/aligned/sequence2.sam ${OUTPUTDATADIR_BLAT}/unmapped/sequence2.fa"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=4G,mem_req=4 ${LOGSTR} -N ${JOB_UNMAPPED2} ${COMMAND_MAPPING}/gatherUnmappedIntoFa.sh ${OUTPUTDATADIR_BOWTIE}/aligned/sequence2.sam ${OUTPUTDATADIR_BLAT}/unmapped/sequence2.fa


echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=16G,mem_req=16 -N ${JOB_BLAT1} -hold_jid ${JOB_UNMAPPED1} ${LOGSTR} ${COMMAND_MAPPING}/my_blat.sh ${OUTPUTDATADIR_BLAT}/unmapped/sequence1.fa ${OUTPUTDATADIR_BLAT}/aligned/sequence1.sam"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=16G,mem_req=16 -N ${JOB_BLAT1} -hold_jid ${JOB_UNMAPPED1} ${LOGSTR} ${COMMAND_MAPPING}/my_blat.sh ${OUTPUTDATADIR_BLAT}/unmapped/sequence1.fa ${OUTPUTDATADIR_BLAT}/aligned/sequence1.sam

echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=16G,mem_req=16 -N ${JOB_BLAT2} -hold_jid ${JOB_UNMAPPED2} ${LOGSTR} ${COMMAND_MAPPING}/my_blat.sh ${OUTPUTDATADIR_BLAT}/unmapped/sequence2.fa ${OUTPUTDATADIR_BLAT}/aligned/sequence2.sam"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=16G,mem_req=16 -N ${JOB_BLAT2} -hold_jid ${JOB_UNMAPPED2} ${LOGSTR} ${COMMAND_MAPPING}/my_blat.sh ${OUTPUTDATADIR_BLAT}/unmapped/sequence2.fa ${OUTPUTDATADIR_BLAT}/aligned/sequence2.sam


