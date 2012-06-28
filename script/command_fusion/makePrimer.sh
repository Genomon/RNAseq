#! /bin/sh
#$ -S /bin/sh
#$ -cwd

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


INPUTPATH=${OUTPUTDIR}/sequence
OUTPUTPATH=${OUTPUTDIR}/fusion
CUFFPATH=${OUTPUTDIR}/cufflink


if [ -f ${CUFFPATH}/transcripts.gtf ]; then
  # convert .gtf fiile to .bed file
  echo "perl ${COMMAND_FUSION}/gtf2bed.pl ${CUFFPATH}/transcripts.gtf > ${OUTPUTPATH}/transcripts.cuff.bed"
  perl ${COMMAND_FUSION}/gtf2bed.pl ${CUFFPATH}/transcripts.gtf > ${OUTPUTPATH}/transcripts.cuff.bed
  check_error $?

  # extract sequence data from the above .bed file
  echo "${BEDTOOLS_PATH}/fastaFromBed -fi ${REF_FA} -bed ${OUTPUTPATH}/transcripts.cuff.bed -fo ${OUTPUTPATH}/transcripts.cuff.tmp.fasta -tab -name -s"
  ${BEDTOOLS_PATH}/fastaFromBed -fi ${REF_FA} -bed ${OUTPUTPATH}/transcripts.cuff.bed -fo ${OUTPUTPATH}/transcripts.cuff.tmp.fasta -tab -name -s
  check_error $?

  # concatinate the .fasta records whose sequences are the same
  echo "perl ${COMMAND_FUSION}/catSeq.pl ${OUTPUTPATH}/transcripts.cuff.tmp.fasta > ${OUTPUTPATH}/transcripts.cuff.fasta"
  perl ${COMMAND_FUSION}/catSeq.pl ${OUTPUTPATH}/transcripts.cuff.tmp.fasta > ${OUTPUTPATH}/transcripts.cuff.fasta
  check_error $?

  # gather the .fasta file for annotated genes and .fasta file for newly assembled transcriptome
  echo "cat ${ALLGENEREF} ${OUTPUTPATH}/transcripts.cuff.fasta > ${OUTPUTPATH}/transcripts.allGene_cuff.fasta"
  cat ${ALLGENEREF} ${OUTPUTPATH}/transcripts.cuff.fasta > ${OUTPUTPATH}/transcripts.allGene_cuff.fasta
  check_error $?

else
  echo "cp ${ALLGENEREF} ${OUTPUTPATH}/transcripts.allGene_cuff.fasta"
  cp ${ALLGENEREF} ${OUTPUTPATH}/transcripts.allGene_cuff.fasta
  check_error $?

fi

# mapping the contigs to the .fasta file
echo "${BLAT_PATH}/blat -maxIntron=5 ${OUTPUTPATH}/transcripts.allGene_cuff.fasta ${OUTPUTPATH}/juncContig.fa ${OUTPUTPATH}/juncContig_allGene_cuff.psl"
${BLAT_PATH}/blat -maxIntron=5 ${OUTPUTPATH}/transcripts.allGene_cuff.fasta ${OUTPUTPATH}/juncContig.fa ${OUTPUTPATH}/juncContig_allGene_cuff.psl
check_error $?


echo "perl ${COMMAND_FUSION}/psl2bed_junc.pl ${OUTPUTPATH}/juncContig_allGene_cuff.psl > ${OUTPUTPATH}/juncContig_allGene_cuff.bed"
perl ${COMMAND_FUSION}/psl2bed_junc.pl ${OUTPUTPATH}/juncContig_allGene_cuff.psl > ${OUTPUTPATH}/juncContig_allGene_cuff.bed
check_error $?

if [ -f ${OUTPUTPATH}/transcripts.allGene_cuff.fasta.fai ]; then
  echo "rm -rf ${OUTPUTPATH}/transcripts.allGene_cuff.fasta.fai"
  rm -rf ${OUTPUTPATH}/transcripts.allGene_cuff.fasta.fai
fi


echo "${BEDTOOLS_PATH}/fastaFromBed -fi ${OUTPUTPATH}/transcripts.allGene_cuff.fasta -bed ${OUTPUTPATH}/juncContig_allGene_cuff.bed -fo ${OUTPUTPATH}/juncContig_allGene_cuff.txt -tab -name -s"
${BEDTOOLS_PATH}/fastaFromBed -fi ${OUTPUTPATH}/transcripts.allGene_cuff.fasta -bed ${OUTPUTPATH}/juncContig_allGene_cuff.bed -fo ${OUTPUTPATH}/juncContig_allGene_cuff.txt -tab -name -s
check_error $?


echo "perl ${COMMAND_FUSION}/summarizeExtendedContig.pl ${OUTPUTPATH}/juncList_anno7.txt ${OUTPUTPATH}/juncContig_allGene_cuff.txt | uniq > ${OUTPUTPATH}/comb2eContig.txt"
perl ${COMMAND_FUSION}/summarizeExtendedContig.pl ${OUTPUTPATH}/juncList_anno7.txt ${OUTPUTPATH}/juncContig_allGene_cuff.txt | uniq > ${OUTPUTPATH}/comb2eContig.txt
check_error $?

echo "perl ${COMMAND_FUSION}/psl2inframePair.pl ${OUTPUTPATH}/juncContig_allGene_cuff.psl ${DBDIR}/fusion/codingInfo.txt > ${OUTPUTPATH}/comb2inframe.txt"
perl ${COMMAND_FUSION}/psl2inframePair.pl ${OUTPUTPATH}/juncContig_allGene_cuff.psl ${DBDIR}/fusion/codingInfo.txt > ${OUTPUTPATH}/comb2inframe.txt
check_error $?

echo "perl ${COMMAND_FUSION}/psl2geneRegion.pl ${OUTPUTPATH}/juncContig_allGene_cuff.psl ${DBDIR}/fusion/codingInfo.txt > ${OUTPUTPATH}/comb2geneRegion.txt"
perl ${COMMAND_FUSION}/psl2geneRegion.pl ${OUTPUTPATH}/juncContig_allGene_cuff.psl ${DBDIR}/fusion/codingInfo.txt > ${OUTPUTPATH}/comb2geneRegion.txt
check_error $?

echo "perl ${COMMAND_FUSION}/addGeneral.pl ${OUTPUTPATH}/juncList_anno7.txt ${OUTPUTPATH}/comb2eContig.txt 2 > ${OUTPUTPATH}/juncList_anno8.txt"
perl ${COMMAND_FUSION}/addGeneral.pl ${OUTPUTPATH}/juncList_anno7.txt ${OUTPUTPATH}/comb2eContig.txt 2 > ${OUTPUTPATH}/juncList_anno8.txt
check_error $?

echo "perl ${COMMAND_FUSION}/addGeneral.pl ${OUTPUTPATH}/juncList_anno8.txt ${OUTPUTPATH}/comb2inframe.txt 1 > ${OUTPUTPATH}/juncList_anno9.txt"
perl ${COMMAND_FUSION}/addGeneral.pl ${OUTPUTPATH}/juncList_anno8.txt ${OUTPUTPATH}/comb2inframe.txt 1 > ${OUTPUTPATH}/juncList_anno9.txt
check_error $?

echo "perl ${COMMAND_FUSION}/addGeneral.pl ${OUTPUTPATH}/juncList_anno9.txt ${OUTPUTPATH}/comb2geneRegion.txt 2 > ${OUTPUTPATH}/juncList_anno10.txt"
perl ${COMMAND_FUSION}/addGeneral.pl ${OUTPUTPATH}/juncList_anno9.txt ${OUTPUTPATH}/comb2geneRegion.txt 2 > ${OUTPUTPATH}/juncList_anno10.txt
check_error $?

echo "perl ${COMMAND_FUSION}/addHeader.pl ${OUTPUTPATH}/juncList_anno10.txt > ${OUTPUTPATH}/${TAG}.fusion.txt"
perl ${COMMAND_FUSION}/addHeader.pl ${OUTPUTPATH}/juncList_anno10.txt > ${OUTPUTPATH}/${TAG}.fusion.txt
check_error $?


