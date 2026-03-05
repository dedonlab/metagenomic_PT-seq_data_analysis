#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=2gb
##########################
list=$1

while IFS=$'\t' read -r genome pipeline method motif; do
  # Skip empty lines or comments
  [[ -z "$genome" || "$genome" =~ ^[[:space:]]*# ]] && continue

  # Split col4 (space-separated) into an array
  read -ra motif_array <<< "$motif"

  # Optional: Print what was received
  echo "pipeline: $pipeline"
  echo "method: $method"
  echo "genome: $genome"
  echo "Motifs: ${motif_array[*]}"

  # Call your actual processing script with:
  folder=pl"${pipeline}"_M"${method}"_top200_R2/vcf_per_OTU
  python3 assign_motif2seq.py --input ${folder}/${genome}_F_seq.txt \
  --output ${folder}/${genome}_F_seq_motif.txt --motifs ${motif_array[*]}

  python3 assign_motif2seq.py --input ${folder}/${genome}_R_seq.txt \
  --output ${folder}/${genome}_R_seq_motif.txt --motifs ${motif_array[*]}
done < ${list}

