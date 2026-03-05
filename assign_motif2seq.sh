#!/bin/bash

list=$1
job=$2

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
  folder="${job}"_top200_R2/vcf_per_OTU
  python3 assign_motif2seq.py --input ${folder}/${genome}_F_seq.txt \
  --output ${folder}/${genome}_F_seq_motif.txt --motifs ${motif_array[*]}

  python3 assign_motif2seq.py --input ${folder}/${genome}_R_seq.txt \
  --output ${folder}/${genome}_R_seq_motif.txt --motifs ${motif_array[*]}
done < ${list}

