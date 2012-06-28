#! /bin/bash
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

write_usage() {
  echo ""
  echo "Usage: `basename $0` [options] <rna.env> <input directory> <output directory> <tag>"
  echo ""
  echo "Options: -s converts solexa quality score to sanger quality score"
  echo "         -a removes adoupter sequence"
  echo ""
}


flg_sol2sanger="FALSE"
flg_cut_adoupt="FALSE"
while getopts sa opt
do
  case ${opt} in
  s) flg_sol2sanger="TRUE";;
  a) flg_cut_adoupt="TRUE";;
  \?)
    echo "invalid option"
    write_usage
    exit 1;;
  esac
done
shift `expr $OPTIND - 1`


readonly RNA_ENV=$1
readonly INPUTDIR=$2
readonly OUTPUTDIR=$3
readonly TAG=$4

if [ $# -ne 4 ]; then
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

# input file check
check_file_exists ${INPUTDIR}/sequence1.txt
check_file_exists ${INPUTDIR}/sequence2.txt
  

# make output directory 
check_mkdir ${OUTPUTDIR}/sequence/preprocess 
check_mkdir ${OUTPUTDIR}/sequence/preprocess/sanger
check_mkdir ${OUTPUTDIR}/sequence/preprocess/adaptor
check_mkdir ${OUTPUTDIR}/sequence/preprocess/split

check_mkdir ${OUTPUTDIR}/sequence/map_bowtie/split
check_mkdir ${OUTPUTDIR}/sequence/map_bowtie/aligned
check_mkdir ${OUTPUTDIR}/sequence/map_bowtie/genome

check_mkdir ${OUTPUTDIR}/sequence/map_blat/unmapped
check_mkdir ${OUTPUTDIR}/sequence/map_blat/aligned

check_mkdir ${OUTPUTDIR}/sequence/assembly/input  
    
check_mkdir ${OUTPUTDIR}/sequence/merge/aligned 
check_mkdir ${OUTPUTDIR}/sequence/merge/paired

check_mkdir ${OUTPUTDIR}/summary


readonly OUTPUTDATADIR=${OUTPUTDIR}/sequence/preprocess

readonly CURLOGDIR=${LOGDIR}/${TAG}
check_mkdir ${CURLOGDIR}
readonly LOGSTR=-e\ ${CURLOGDIR}\ -o\ ${CURLOGDIR}

readonly JOB_MAQ1=maq_sol2sanger.${TAG}.1
readonly JOB_MAQ2=maq_sol2sanger.${TAG}.2
readonly JOB_CUT1=my_cutadapt.${TAG}.1
readonly JOB_CUT2=my_cutadapt.${TAG}.2
readonly JOB_SPLIT1=split.${TAG}.1
readonly JOB_SPLIT2=split.${TAG}.2


# preprocess step
if [ ${flg_sol2sanger} = "TRUE" ]; then
  echo "qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_MAQ1} ${LOGSTR} ${COMMAND_MAPPING}/maq_sol2sanger.sh ${INPUTDIR}/sequence1.txt ${OUTPUTDATADIR}/sanger/sequence1.txt"
  qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_MAQ1} ${LOGSTR} ${COMMAND_MAPPING}/maq_sol2sanger.sh ${INPUTDIR}/sequence1.txt ${OUTPUTDATADIR}/sanger/sequence1.txt

  echo "qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_MAQ2} ${LOGSTR} ${COMMAND_MAPPING}/maq_sol2sanger.sh ${INPUTDIR}/sequence2.txt ${OUTPUTDATADIR}/sanger/sequence2.txt"
  qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_MAQ2} ${LOGSTR} ${COMMAND_MAPPING}/maq_sol2sanger.sh ${INPUTDIR}/sequence2.txt ${OUTPUTDATADIR}/sanger/sequence2.txt
fi


if [ ${flg_cut_adoupt} = "TRUE" ]; then
  inputFastq1=${INPUTDIR}/sequence1.txt
  inputFastq2=${INPUTDIR}/sequence2.txt

  if [ ${flg_sol2sanger} = "TRUE" ]; then
    inputFastq1=${OUTPUTDATADIR}/sanger/sequence1.txt
    inputFastq2=${OUTPUTDATADIR}/sanger/sequence2.txt

  fi
  echo "qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_CUT1} -hold_jid ${JOB_MAQ1} ${LOGSTR} ${COMMAND_MAPPING}/my_cutadopt.sh 1 12 ${inputFastq1} ${OUTPUTDATADIR}/adaptor/sequence1.txt ${OUTPUTDIR}/summary/adaptorRemovalResult1.txt"
  qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_CUT1} -hold_jid ${JOB_MAQ1} ${LOGSTR} ${COMMAND_MAPPING}/my_cutadopt.sh 1 12 ${inputFastq1} ${OUTPUTDATADIR}/adaptor/sequence1.txt ${OUTPUTDIR}/summary/adaptorRemovalResult1.txt

  echo "qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_CUT2} -hold_jid ${JOB_MAQ2} ${LOGSTR} ${COMMAND_MAPPING}/my_cutadopt.sh 2 12 ${inputFastq2} ${OUTPUTDATADIR}/adaptor/sequence2.txt ${OUTPUTDIR}/summary/adaptorRemovalResult2.txt"
  qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_CUT2} -hold_jid ${JOB_MAQ2} ${LOGSTR} ${COMMAND_MAPPING}/my_cutadopt.sh 2 12 ${inputFastq2} ${OUTPUTDATADIR}/adaptor/sequence2.txt ${OUTPUTDIR}/summary/adaptorRemovalResult2.txt

fi

readonly SPLITFACTOR=4000000
inputFastq1=${INPUTDIR}/sequence1.txt
inputFastq2=${INPUTDIR}/sequence2.txt

if [ ${flg_sol2sanger} = "TRUE" ]; then
  inputFastq1=${OUTPUTDATADIR}/sanger/sequence1.txt
  inputFastq2=${OUTPUTDATADIR}/sanger/sequence2.txt
fi

if [ ${flg_cut_adoupt} = "TRUE" ]; then
  inputFastq1=${OUTPUTDATADIR}/adaptor/sequence1.txt
  inputFastq2=${OUTPUTDATADIR}/adaptor/sequence2.txt
fi

echo "qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_SPLIT1} -hold_jid ${JOB_MAQ1},${JOB_CUT1} ${LOGSTR} ${COMMAND_MAPPING}/split.sh ${SPLITFACTOR} 3 ${inputFastq1} ${OUTPUTDATADIR}/split/sequence1.txt."
qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_SPLIT1} -hold_jid ${JOB_MAQ1},${JOB_CUT1} ${LOGSTR} ${COMMAND_MAPPING}/split.sh ${SPLITFACTOR} 3 ${inputFastq1} ${OUTPUTDATADIR}/split/sequence1.txt.

echo "qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_SPLIT2} -hold_jid ${JOB_MAQ2},${JOB_CUT2} ${LOGSTR} ${COMMAND_MAPPING}/split.sh ${SPLITFACTOR} 3 ${inputFastq2} ${OUTPUTDATADIR}/split/sequence2.txt."
qsub -v RNA_ENV=${RNA_ENV} -N ${JOB_SPLIT2} -hold_jid ${JOB_MAQ2},${JOB_CUT2} ${LOGSTR} ${COMMAND_MAPPING}/split.sh ${SPLITFACTOR} 3 ${inputFastq2} ${OUTPUTDATADIR}/split/sequence2.txt.


