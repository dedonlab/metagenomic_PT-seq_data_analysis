#!/bin/bash

job=$1
depth=$2
ratio=$3

folder=${job}_top200_R2/vcf_per_OTU

for file in $(ls "${folder}"/*_R_seq.txt); do
  gname=$(basename $file| sed 's/_R_seq.txt//')
  fout="${folder}"/${gname}_dep${depth}r${ratio}min8.fasta

  > ${fout}.tmp
  awk -v r=${ratio} -v d=${depth} '$4>=d&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_R\n"$5}' $file >> ${fout}.tmp
  awk -v r=${ratio} -v d=${depth} '$4>=d&&($4/$3)>=r{print ">"$1"_"$2"_"$4"_F\n"$5}' "${folder}"/${gname}_F_seq.txt >> ${fout}.tmp
  seqkit seq -m 8 ${fout}.tmp > ${fout}

  rm ${fout}.tmp
done
