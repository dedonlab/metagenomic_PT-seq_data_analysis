#!/bin/bash

for ratio in $(seq 0.1 0.1 1) ; do
  for pipeline in 1 2; do
    for method in 1 2 3 4 ; do
      output=allsite_${job}_r${ratio}_depth.txt
      > ${output}
    done
  done
done

for ratio in $(seq 0.1 0.1 1) ; do
  while IFS=$'\t' read -r genome job motif; do
    output=allsite_${job}_r${ratio}_depth.txt
    echo -e "${genome}\c" >> ${output}
    for depth in $(seq 1 1 50) ; do
      num_motif=$(awk -F '\t' -v r=${ratio} -v d=${depth} '$4/$3>=r&&$4>=d {print $1}' ${job}_top200_R2/site/${genome}_allsite.txt | wc -l)
      echo -e "\t${num_motif}\c" >> ${output}
    done
    echo "" >> ${output}
  done < list_genome_motif.txt
done

for ratio in $(seq 0.1 0.1 1) ; do
  for pipeline in 1 2; do
    for method in 1 2 3 4 ; do
      output=ptsite_${job}_r${ratio}_depth.txt
      > ${output}
    done
  done
done

for ratio in $(seq 0.1 0.1 1) ; do
  while IFS=$'\t' read -r genome job motif; do
    output=ptsite_${job}_r${ratio}_depth.txt
    echo -e "${genome}\c" >> ${output}
    for depth in $(seq 1 1 50) ; do
      num_motif=$(awk -F '\t' -v r=${ratio} -v d=${depth} '$4/$3>=r&&$6!="other"&&$6!="TTT"&&$4>=d {print $1}' ${job}_top200_R2/site/${genome}_allsite.txt | wc -l)
      echo -e "\t${num_motif}\c" >> ${output}
    done
    echo "" >> ${output}
  done < list_genome_motif.txt
done

####

## END
