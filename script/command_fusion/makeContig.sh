#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#

readonly OUTPUTDIR=$1
readonly TAG=$2

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 2

readonly INPUTPATH=${OUTPUTDIR}/sequence
readonly TARGETDIR=${OUTPUTDIR}/fusion

readonly FILECOUNT=`find ${INTERVAL}/*.interval_list | wc -l`


# get the sequence information for comb2ID2.txt

echo -n > ${TARGETDIR}/comb2seq.tmp.txt
for i in `seq 1 1 ${FILECOUNT}`
do
  cat ${TARGETDIR}/tmp/comb2seq.tmp${i}.txt >> ${TARGETDIR}/comb2seq.tmp.txt
done


# process the above data and complete the table for relationships between combinations of junctions and their sequences
echo "perl ${COMMAND_FUSION}/procComb2seq.pl ${TARGETDIR}/comb2seq.tmp.txt > ${TARGETDIR}/comb2seq.txt"
perl ${COMMAND_FUSION}/procComb2seq.pl ${TARGETDIR}/comb2seq.tmp.txt > ${TARGETDIR}/comb2seq.txt
check_error $?


check_mkdir ${TARGETDIR}/tmp_contig

echo -n > ${TARGETDIR}/candFusionContig.fa
echo -n > ${TARGETDIR}/candFusionPairNum.txt

num=0
while read LINE; do 

  comb=`echo ${LINE} | cut -d ' ' -f 1`
  segseq=`echo ${LINE} | cut -d ' ' -f 2`
  ids=( `echo ${LINE} | cut -d ' ' -f 3 | tr -s ',' ' '` )
  seqs=( `echo ${LINE} | cut -d ' ' -f 4 | tr -s ',' ' '` )

  # make the fasta file for each junction pair 
  echo ${comb}
  echo -n > ${TARGETDIR}/tmp_contig/candSeq_${num}.tmp.fa
  for (( i = 0; i < ${#seqs[@]}; i++ ))
  {
    echo '>'${ids[$i]}  >> ${TARGETDIR}/tmp_contig/candSeq_${num}.tmp.fa 
    echo "${seqs[$i]}" >> ${TARGETDIR}/tmp_contig/candSeq_${num}.tmp.fa
  }

  # if the number of reads exceeds 1000, then discard randomly to reach 1000 reads
  echo "perl ${COMMAND_FUSION}/randFasta.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.tmp.fa 1000 > ${TARGETDIR}/tmp_contig/candSeq_${num}.fa"
  perl ${COMMAND_FUSION}/randFasta.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.tmp.fa 1000 > ${TARGETDIR}/tmp_contig/candSeq_${num}.fa
  check_error $?

  # make the constraint file for the paired end sequences (maybe the constraint information is not reflected in CAP3 assembly?)
  echo "perl ${COMMAND_FUSION}/my_formcon.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.fa > ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.con"
  perl ${COMMAND_FUSION}/my_formcon.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.fa > ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.con
  check_error $?

  # assemble the sequences via CAP3
  echo "${CAP3_PATH}/cap3 ${TARGETDIR}/tmp_contig/candSeq_${num}.fa > ${TARGETDIR}/tmp_contig/candSeq_${num}.contig"
  ${CAP3_PATH}/cap3 ${TARGETDIR}/tmp_contig/candSeq_${num}.fa > ${TARGETDIR}/tmp_contig/candSeq_${num}.contig
  check_error $?

  # alignment the junction sequence to the set of contigs generated via CAP3 and select the best contig
  echo '>'query > ${TARGETDIR}/tmp_contig/query_${num}.fa
  echo ${segseq} >> ${TARGETDIR}/tmp_contig/query_${num}.fa
  echo "${FASTA_PATH}/fasta36 -d 1 -m 8 ${TARGETDIR}/tmp_contig/query_${num}.fa ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.contigs > ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.fastaTabular"
  ${FASTA_PATH}/fasta36 -d 1 -m 8 ${TARGETDIR}/tmp_contig/query_${num}.fa ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.contigs > ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.fastaTabular
  check_error $?

  echo "perl ${COMMAND_FUSION}/selectContig.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.fastaTabular ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.contigs > ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.selected"
  perl ${COMMAND_FUSION}/selectContig.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.fastaTabular ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.contigs > ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.selected
  check_error $?

  # count the number of read pairs aligned properly to the selected contig
  echo "perl ${COMMAND_FUSION}/procAce.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.ace ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.selected | sort -k 2 -n  > ${TARGETDIR}/tmp_contig/candSeq_${num}.consensusPair"
  perl ${COMMAND_FUSION}/procAce.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.ace ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.selected | sort -k 2 -n  > ${TARGETDIR}/tmp_contig/candSeq_${num}.consensusPair
  check_error $?

  # get the contig sequence and add it to the candFusionContig.fa file
  echo ">"${comb} >> ${TARGETDIR}/candFusionContig.fa
  echo "perl ${COMMAND_FUSION}/extractContigSeq.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.contigs ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.selected >> ${TARGETDIR}/candFusionContig.fa"
  perl ${COMMAND_FUSION}/extractContigSeq.pl ${TARGETDIR}/tmp_contig/candSeq_${num}.fa.cap.contigs ${TARGETDIR}/tmp_contig/candSeq_${num}.contigs.selected >> ${TARGETDIR}/candFusionContig.fa
  check_error $?

  # write the number of properly alinged read pairs to the candFusionPairNum.txt file
  right_pair_num=`wc -l ${TARGETDIR}/tmp_contig/candSeq_${num}.consensusPair | cut -d " " -f 1`
  echo "echo -e "${comb}\t${right_pair_num}" >> ${TARGETDIR}/candFusionPairNum.txt"
  echo -e "${comb}\t${right_pair_num}" >> ${TARGETDIR}/candFusionPairNum.txt

  num=`expr ${num} + 1`

done < ${TARGETDIR}/comb2seq.txt


echo "perl ${COMMAND_FUSION}/addContig.pl ${TARGETDIR}/juncList_anno4.txt ${TARGETDIR}/candFusionContig.fa > ${TARGETDIR}/juncList_anno5.txt"
perl ${COMMAND_FUSION}/addContig.pl ${TARGETDIR}/juncList_anno4.txt ${TARGETDIR}/candFusionContig.fa > ${TARGETDIR}/juncList_anno5.txt
check_error $?

# aling the contigs split by the junction points to the genome including alternative assembly and filter if they are alinged to multiple locations
echo "perl ${COMMAND_FUSION}/makeJuncSeqPairFa.pl ${TARGETDIR}/juncList_anno5.txt > ${TARGETDIR}/juncContig.fa"
perl ${COMMAND_FUSION}/makeJuncSeqPairFa.pl ${TARGETDIR}/juncList_anno5.txt > ${TARGETDIR}/juncContig.fa
check_error $?

echo "${BLAT_PATH}/blat -stepSize=5 -repMatch=2253 -ooc=${BLAT_OOC} ${BLAT_ALL_REF} ${TARGETDIR}/juncContig.fa ${TARGETDIR}/juncContig.psl"
${BLAT_PATH}/blat -stepSize=5 -repMatch=2253 -ooc=${BLAT_OOC} ${BLAT_ALL_REF} ${TARGETDIR}/juncContig.fa ${TARGETDIR}/juncContig.psl
check_error $?


echo "perl ${COMMAND_FUSION}/filterByJunction.pl ${TARGETDIR}/juncContig.psl > ${TARGETDIR}/juncContig.filter.txt"
perl ${COMMAND_FUSION}/filterByJunction.pl ${TARGETDIR}/juncContig.psl > ${TARGETDIR}/juncContig.filter.txt
check_error $?

echo "perl ${COMMAND_FUSION}/addFilterByJunction.pl ${TARGETDIR}/juncList_anno5.txt ${TARGETDIR}/juncContig.filter.txt > ${TARGETDIR}/juncList_anno6.txt"
perl ${COMMAND_FUSION}/addFilterByJunction.pl ${TARGETDIR}/juncList_anno5.txt ${TARGETDIR}/juncContig.filter.txt > ${TARGETDIR}/juncList_anno6.txt
check_error $?

# echo "join -1 1 -2 1 -t'	'  ${TARGETDIR}/juncList_anno6.txt ${TARGETDIR}/candFusionPairNum.txt > ${TARGETDIR}/juncList_anno7.txt"
# join -1 1 -2 1 -t'	'  ${TARGETDIR}/juncList_anno6.txt ${TARGETDIR}/candFusionPairNum.txt > ${TARGETDIR}/juncList_anno7.txt

echo "perl ${COMMAND_FUSION}/joinFile.pl ${TARGETDIR}/juncList_anno6.txt ${TARGETDIR}/candFusionPairNum.txt > ${TARGETDIR}/juncList_anno7.txt"
perl ${COMMAND_FUSION}/joinFile.pl ${TARGETDIR}/juncList_anno6.txt ${TARGETDIR}/candFusionPairNum.txt > ${TARGETDIR}/juncList_anno7.txt
check_error $?

echo "perl ${COMMAND_FUSION}/addHeader.pl ${TARGETDIR}/juncList_anno7.txt > ${TARGETDIR}/${TAG}.fusion.txt"
perl ${COMMAND_FUSION}/addHeader.pl ${TARGETDIR}/juncList_anno7.txt > ${TARGETDIR}/${TAG}.fusion.txt
check_error $?


