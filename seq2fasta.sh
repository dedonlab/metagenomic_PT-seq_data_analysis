#!/bin/bash

job=$1
ratio=$2

folder=${job}_top200_R2/vcf_per_OTU

for file in $(ls "${folder}"/*_R_seq.txt); do
  gname=$(basename $file| sed 's/_R_seq.txt//')
  fout="${folder}"/${gname}_dep0.5r${ratio}.fasta
  fout8="${folder}"/${gname}_dep0.5r${ratio}min8.fasta
  fout1="${folder}"/${gname}_dep1r${ratio}min8.fasta
  fout5="${folder}"/${gname}_dep5r${ratio}min8.fasta

  > ${fout}.tmp
  awk -v r=${ratio} '$4>=0.5&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_R\n"$5}' $file >> ${fout}.tmp
  awk -v r=${ratio} '$4>=0.5&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_F\n"$5}' "${folder}"/${gname}_F_seq.txt >> ${fout}.tmp
  seqkit seq -m 8 ${fout}.tmp > ${fout8}

  > ${fout}.tmp
  awk -v r=${ratio} '$4>=1&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_R\n"$5}' $file >> ${fout}.tmp
  awk -v r=${ratio} '$4>=1&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_F\n"$5}' "${folder}"/${gname}_F_seq.txt >> ${fout}.tmp
  seqkit seq -m 8 ${fout}.tmp > ${fout1}

  > ${fout}.tmp
  awk -v r=${ratio} '$4>=5&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_R\n"$5}' $file >> ${fout}.tmp
  awk -v r=${ratio} '$4>=5&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_F\n"$5}' "${folder}"/${gname}_F_seq.txt >> ${fout}.tmp
  seqkit seq -m 8 ${fout}.tmp > ${fout5}

  rm ${fout}.tmp
done
