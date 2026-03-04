#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=1gb
#######################3

method=$1
ratio=$2

for pl in 1 2; do
  folder=pl"${pl}"_M"${method}"_top200_R2/vcf_per_OTU

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
done


