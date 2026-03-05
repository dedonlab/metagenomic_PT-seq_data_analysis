#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=2gb
##########################

f_list=$1

while IFS=$'\t' read -r genome pipeline method motif; do
  python3 merge_pileup.py pl"${pipeline}"_M"${method}"_top200_R2/vcf_per_OTU/${genome}_F_seq_motif_newsite.txt pl"${pipeline}"_M"${method}"_top200_R2/site/${genome}_F_seq_motif_merge.txt
  python3 merge_pileup.py pl"${pipeline}"_M"${method}"_top200_R2/vcf_per_OTU/${genome}_R_seq_motif_newsite.txt pl"${pipeline}"_M"${method}"_top200_R2/site/${genome}_R_seq_motif_merge.txt
done < ${f_list}   #list_genome_motif.txt
