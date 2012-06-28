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

readonly OUTPUTDATADIR_PREPRO=${OUTPUTDIR}/sequence/preprocess
readonly OUTPUTDATADIR_BOWTIE=${OUTPUTDIR}/sequence/map_bowtie
readonly OUTPUTDATADIR_BLAT=${OUTPUTDIR}/sequence/map_blat
readonly OUTPUTDATADIR_MERGE=${OUTPUTDIR}/sequence/merge

readonly CURLOGDIR=${LOGDIR}/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

# input file check
file_count_check=`find ${OUTPUTDATADIR_BLAT}/aligned/sequence1.sam.???`
check_error $?

readonly FILECOUNT=`find ${OUTPUTDATADIR_BLAT}/aligned/sequence1.sam.??? | wc -l`


readonly JOB_MERGE_BOWTIE_BLAT1=merge_bowtie_blat.${TAG}.1
readonly JOB_MERGE_BOWTIE_BLAT2=merge_bowtie_blat.${TAG}.2
readonly JOB_MATE_MERGE=MateMerge.${TAG}
readonly JOB_CAT_SAM=my_catSam.${TAG}
readonly JOB_SAM2ORG_BAM=sam2orgbam.${TAG}


echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -N ${JOB_MERGE_BOWTIE_BLAT1} ${LOGSTR} -l s_vmem=4G,mem_req=4 ${COMMAND_MAPPING}/merge_bowtie_blat.sh ${OUTPUTDATADIR_BOWTIE}/genome/sequence1.sam ${OUTPUTDATADIR_BLAT}/aligned/sequence1.sam ${OUTPUTDATADIR_MERGE}/aligned/sequence1.sam"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -N ${JOB_MERGE_BOWTIE_BLAT1} ${LOGSTR} -l s_vmem=4G,mem_req=4 ${COMMAND_MAPPING}/merge_bowtie_blat.sh ${OUTPUTDATADIR_BOWTIE}/genome/sequence1.sam ${OUTPUTDATADIR_BLAT}/aligned/sequence1.sam ${OUTPUTDATADIR_MERGE}/aligned/sequence1.sam

echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -N ${JOB_MERGE_BOWTIE_BLAT2} ${LOGSTR} -l s_vmem=4G,mem_req=4 ${COMMAND_MAPPING}/merge_bowtie_blat.sh ${OUTPUTDATADIR_BOWTIE}/genome/sequence2.sam ${OUTPUTDATADIR_BLAT}/aligned/sequence2.sam ${OUTPUTDATADIR_MERGE}/aligned/sequence2.sam"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -N ${JOB_MERGE_BOWTIE_BLAT2} ${LOGSTR} -l s_vmem=4G,mem_req=4 ${COMMAND_MAPPING}/merge_bowtie_blat.sh ${OUTPUTDATADIR_BOWTIE}/genome/sequence2.sam ${OUTPUTDATADIR_BLAT}/aligned/sequence2.sam ${OUTPUTDATADIR_MERGE}/aligned/sequence2.sam


echo "qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_MATE_MERGE} -hold_jid ${JOB_MERGE_BOWTIE_BLAT1},${JOB_MERGE_BOWTIE_BLAT2} ${LOGSTR} ${COMMAND_MAPPING}/mateMerge.sh ${OUTPUTDATADIR_MERGE}/aligned/sequence1.sam ${OUTPUTDATADIR_MERGE}/aligned/sequence2.sam ${OUTPUTDATADIR_MERGE}/paired/sequence.sam"
qsub -v RNA_ENV=${RNA_ENV} -t 1-${FILECOUNT}:1 -l s_vmem=2G,mem_req=2 -N ${JOB_MATE_MERGE} -hold_jid ${JOB_MERGE_BOWTIE_BLAT1},${JOB_MERGE_BOWTIE_BLAT2} ${LOGSTR} ${COMMAND_MAPPING}/mateMerge.sh ${OUTPUTDATADIR_MERGE}/aligned/sequence1.sam ${OUTPUTDATADIR_MERGE}/aligned/sequence2.sam ${OUTPUTDATADIR_MERGE}/paired/sequence.sam


echo "qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=2G,mem_req=2 -N ${JOB_CAT_SAM} -hold_jid ${JOB_MATE_MERGE} ${LOGSTR} ${COMMAND_MAPPING}/my_catSam.sh ${OUTPUTDATADIR_MERGE}/paired sequence.sam.??? ${OUTPUTDIR}/sequence/sequence.sam ${BLAT_HEADER}"
qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=2G,mem_req=2 -N ${JOB_CAT_SAM} -hold_jid ${JOB_MATE_MERGE} ${LOGSTR} ${COMMAND_MAPPING}/my_catSam.sh ${OUTPUTDATADIR_MERGE}/paired sequence.sam.??? ${OUTPUTDIR}/sequence/sequence.sam ${BLAT_HEADER}


echo "qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=16G,mem_req=16 -N ${JOB_SAM2ORG_BAM} -hold_jid ${JOB_CAT_SAM} ${LOGSTR} ${COMMAND_MAPPING}/sam2orgbam.sh ${OUTPUTDIR}/sequence/sequence.sam ${OUTPUTDIR}/sequence/sequence.tmp.bam ${OUTPUTDIR}/sequence/sequence.sorted.bam ${OUTPUTDIR}/sequence/sequence.bam ${OUTPUTDIR}/sequence/sequence.metrics"
qsub -v RNA_ENV=${RNA_ENV} -l s_vmem=16G,mem_req=16 -N ${JOB_SAM2ORG_BAM} -hold_jid ${JOB_CAT_SAM} ${LOGSTR} ${COMMAND_MAPPING}/sam2orgbam.sh ${OUTPUTDIR}/sequence/sequence.sam ${OUTPUTDIR}/sequence/sequence.tmp.bam ${OUTPUTDIR}/sequence/sequence.sorted.bam ${OUTPUTDIR}/sequence/sequence.bam ${OUTPUTDIR}/sequence/sequence.metrics

