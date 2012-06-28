#! /bin/bash
#$ -S /bin/bash
#$ -cwd
#
# Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
# @since 2012
#


readonly OUTPUTDIR=$1

source ${RNA_ENV}
source ${UTIL}

check_num_args $# 1

readonly TARGETDIR=${OUTPUTDIR}/fusion
readonly FILECOUNT=`find ${INTERVAL}/*.interval_list | wc -l`

strfiles=""
for file in `find ${TARGETDIR}/tmp -name "countJunc*.txt"`
do
    strfiles="${strfiles}"" ""${file}"
done

cat ${strfiles} > ${TARGETDIR}/countJunc.txt


echo "perl ${COMMAND_FUSION}/makeBeds.pl ${TARGETDIR}/countJunc.txt ${TARGETDIR}/cj_tmp1.bed ${TARGETDIR}/cj_tmp2.bed"
perl ${COMMAND_FUSION}/makeBeds.pl ${TARGETDIR}/countJunc.txt ${TARGETDIR}/cj_tmp1.bed ${TARGETDIR}/cj_tmp2.bed
check_error $?

echo "${BEDTOOLS_PATH}/intersectBed -a ${TARGETDIR}/cj_tmp1.bed -b ${TARGETDIR}/cj_tmp2.bed -wb > ${TARGETDIR}/countJunc.inter.txt"
${BEDTOOLS_PATH}/intersectBed -a ${TARGETDIR}/cj_tmp1.bed -b ${TARGETDIR}/cj_tmp2.bed -wb > ${TARGETDIR}/countJunc.inter.txt
check_error $?

echo "perl ${COMMAND_FUSION}/mergeJunc2.pl ${TARGETDIR}/countJunc.inter.txt > ${TARGETDIR}/juncList.txt"
perl ${COMMAND_FUSION}/mergeJunc2.pl ${TARGETDIR}/countJunc.inter.txt > ${TARGETDIR}/juncList.txt
check_error $?


echo "${BEDTOOLS_PATH}/intersectBed -a ${TARGETDIR}/cj_tmp1.bed -b ${DBDIR}/fusion/gene.bed -wao > ${TARGETDIR}/cj_gene1.txt"
${BEDTOOLS_PATH}/intersectBed -a ${TARGETDIR}/cj_tmp1.bed -b ${DBDIR}/fusion/gene.bed -wao > ${TARGETDIR}/cj_gene1.txt
check_error $?

echo "${BEDTOOLS_PATH}/intersectBed -a ${TARGETDIR}/cj_tmp2.bed -b ${DBDIR}/fusion/gene.bed -wao > ${TARGETDIR}/cj_gene2.txt"
${BEDTOOLS_PATH}/intersectBed -a ${TARGETDIR}/cj_tmp2.bed -b ${DBDIR}/fusion/gene.bed -wao > ${TARGETDIR}/cj_gene2.txt
check_error $?


echo "perl ${COMMAND_FUSION}/makeJuncToGene.pl ${TARGETDIR}/cj_gene1.txt > ${TARGETDIR}/junc2gene1.txt"
perl ${COMMAND_FUSION}/makeJuncToGene.pl ${TARGETDIR}/cj_gene1.txt > ${TARGETDIR}/junc2gene1.txt
check_error $?

echo "perl ${COMMAND_FUSION}/makeJuncToGene.pl ${TARGETDIR}/cj_gene2.txt > ${TARGETDIR}/junc2gene2.txt"
perl ${COMMAND_FUSION}/makeJuncToGene.pl ${TARGETDIR}/cj_gene2.txt > ${TARGETDIR}/junc2gene2.txt
check_error $?


echo "perl ${COMMAND_FUSION}/addAnno.pl ${TARGETDIR}/juncList.txt ${TARGETDIR}/junc2gene1.txt ${TARGETDIR}/junc2gene2.txt > ${TARGETDIR}/juncList_anno0.txt"
perl ${COMMAND_FUSION}/addAnno.pl ${TARGETDIR}/juncList.txt ${TARGETDIR}/junc2gene1.txt ${TARGETDIR}/junc2gene2.txt > ${TARGETDIR}/juncList_anno0.txt
check_error $?

echo "perl ${COMMAND_FUSION}/procEdge.pl ${TARGETDIR}/juncList_anno0.txt ${DBDIR}/fusion/edge.bed > ${TARGETDIR}/juncList_anno1.txt"
perl ${COMMAND_FUSION}/procEdge.pl ${TARGETDIR}/juncList_anno0.txt ${DBDIR}/fusion/edge.bed > ${TARGETDIR}/juncList_anno1.txt
check_error $?

echo "perl ${COMMAND_FUSION}/filterByGene.pl ${TARGETDIR}/juncList_anno1.txt > ${TARGETDIR}/juncList_anno2.txt"
perl ${COMMAND_FUSION}/filterByGene.pl ${TARGETDIR}/juncList_anno1.txt > ${TARGETDIR}/juncList_anno2.txt
check_error $?


echo "perl ${COMMAND_FUSION}/makeJuncBed.pl ${TARGETDIR}/juncList_anno2.txt > ${TARGETDIR}/filtSeq.bed"
perl ${COMMAND_FUSION}/makeJuncBed.pl ${TARGETDIR}/juncList_anno2.txt > ${TARGETDIR}/filtSeq.bed
check_error $?

echo "${BEDTOOLS_PATH}/fastaFromBed -fi ${REF_FA} -bed ${TARGETDIR}/filtSeq.bed -fo ${TARGETDIR}/filtSeq.fasta -name -tab"
${BEDTOOLS_PATH}/fastaFromBed -fi ${REF_FA} -bed ${TARGETDIR}/filtSeq.bed -fo ${TARGETDIR}/filtSeq.fasta -name -tab
check_error $?

echo "perl ${COMMAND_FUSION}/addSeq.pl ${TARGETDIR}/juncList_anno2.txt ${TARGETDIR}/filtSeq.fasta > ${TARGETDIR}/juncList_anno3.txt"
perl ${COMMAND_FUSION}/addSeq.pl ${TARGETDIR}/juncList_anno2.txt ${TARGETDIR}/filtSeq.fasta > ${TARGETDIR}/juncList_anno3.txt
check_error $?


echo "perl ${COMMAND_FUSION}/makePairBed.pl ${TARGETDIR}/juncList_anno3.txt > ${TARGETDIR}/juncList_pair3.txt"
perl ${COMMAND_FUSION}/makePairBed.pl ${TARGETDIR}/juncList_anno3.txt > ${TARGETDIR}/juncList_pair3.txt
check_error $?

echo "${BEDTOOLS_PATH}/pairToPair -a ${TARGETDIR}/juncList_pair3.txt -b ${DBDIR}/fusion/chainSelf.bedpe -is > ${TARGETDIR}/juncList_chainSelf.bedpe"
${BEDTOOLS_PATH}/pairToPair -a ${TARGETDIR}/juncList_pair3.txt -b ${DBDIR}/fusion/chainSelf.bedpe -is > ${TARGETDIR}/juncList_chainSelf.bedpe
check_error $?

echo "perl ${COMMAND_FUSION}/addSelfChain.pl ${TARGETDIR}/juncList_anno3.txt ${TARGETDIR}/juncList_chainSelf.bedpe > ${TARGETDIR}/juncList_anno4.txt"
perl ${COMMAND_FUSION}/addSelfChain.pl ${TARGETDIR}/juncList_anno3.txt ${TARGETDIR}/juncList_chainSelf.bedpe > ${TARGETDIR}/juncList_anno4.txt
check_error $?


# prepare for asssembly  
# make the table for relationships between junctions and IDs

echo -n > ${TARGETDIR}/junc2ID.txt
for i in `seq 1 1 ${FILECOUNT}`
do
  cat ${TARGETDIR}/tmp/junc2ID${i}.txt >> ${TARGETDIR}/junc2ID.txt
done

# make the table for relationships between combinations of junctions and IDs
echo "perl ${COMMAND_FUSION}/makeComb2ID.pl ${TARGETDIR}/juncList_anno4.txt ${TARGETDIR}/junc2ID.txt > ${TARGETDIR}/comb2ID.txt"
perl ${COMMAND_FUSION}/makeComb2ID.pl ${TARGETDIR}/juncList_anno4.txt ${TARGETDIR}/junc2ID.txt > ${TARGETDIR}/comb2ID.txt
check_error $?

# add the data of reads aligned flanking the junctions
echo "perl ${COMMAND_FUSION}/addComb2ID.pl ${OUTPUTDIR}/sequence/sequence.bam ${TARGETDIR}/comb2ID.txt 20 > ${TARGETDIR}/comb2ID2.txt"
perl ${COMMAND_FUSION}/addComb2ID.pl ${OUTPUTDIR}/sequence/sequence.bam ${TARGETDIR}/comb2ID.txt 20 > ${TARGETDIR}/comb2ID2.txt
check_error $?

