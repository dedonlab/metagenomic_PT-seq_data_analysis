#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=200mb
#########################################################################
ratio=$1
#for ratio in $(seq 0.1 0.1 1) ; do
  for pipeline in 1 2; do
    for method in 1 2 3 4 ; do
      output=allsite_r${ratio}_pl"${pipeline}"_M"${method}"_depth.txt
      > ${output}
    done
  done
#done

#for ratio in $(seq 0.1 0.1 1) ; do
  while IFS=$'\t' read -r genome pipeline method motif; do
    output=allsite_r${ratio}_pl"${pipeline}"_M"${method}"_depth.txt
    echo -e "${genome}\c" >> ${output}
    for depth in $(seq 1 1 50) ; do
      num_motif=$(awk -F '\t' -v r=${ratio} -v d=${depth} '$4/$3>=r&&$4>=d {print $1}' pl"${pipeline}"_M"${method}"_top200_R2/site/${genome}_allsite.txt | wc -l)
      echo -e "\t${num_motif}\c" >> ${output}
    done
    echo "" >> ${output}
  done < list_genome_motif.txt
#done


#<<'####'
#for ratio in $(seq 0.1 0.1 1) ; do
  for pipeline in 1 2; do
    for method in 1 2 3 4 ; do
      output=ptsite_r${ratio}_pl"${pipeline}"_M"${method}"_depth.txt
      > ${output}
    done
  done
#done

#for ratio in $(seq 0.1 0.1 1) ; do
  while IFS=$'\t' read -r genome pipeline method motif; do
    output=ptsite_r${ratio}_pl"${pipeline}"_M"${method}"_depth.txt
    echo -e "${genome}\c" >> ${output}
    for depth in $(seq 1 1 50) ; do
      num_motif=$(awk -F '\t' -v r=${ratio} -v d=${depth} '$4/$3>=r&&$6!="other"&&$6!="TTT"&&$4>=d {print $1}' pl"${pipeline}"_M"${method}"_top200_R2/site/${genome}_allsite.txt | wc -l)
      echo -e "\t${num_motif}\c" >> ${output}
    done
    echo "" >> ${output}
  done < list_genome_motif.txt
#done

####

## END
