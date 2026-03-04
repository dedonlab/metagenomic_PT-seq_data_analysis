#!/bin/bas

job=$1
dep=$2
ratio=$3
t=$4

folder=${job}_top200_R2

dir_o=${folder}/meme_dep${dep}r${ratio}

for file in $(ls "${folder}"/vcf_per_OTU/*_R_seq.txt); do
  gname=$(basename $file| sed 's/_R_seq.txt//')
  fas="${folder}"/vcf_per_OTU/${gname}_dep"${dep}"r${ratio}min8.fasta

  meme -p $t -dna -objfun classic -nmotifs 6 -mod zoops -evt 0.05 -time 3000 -minw 3 -maxw 4 -markov_order 0 -nostatus -oc ${dir_o} $fas

  mv ${dir_o}/meme.html ${dir_o}/${gname}_meme.html
  mv ${dir_o}/meme.txt ${dir_o}/${gname}_meme.txt

done


