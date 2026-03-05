#!/bin/bash

list=$1
job=$2

# 1. assign motif to pileups.
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

# 2. relocate pt site. 
# R strand : pt site = pos (col2) + start site (col7)
# F strand : new pos = pos + (length($5) - $7 + 1)

while IFS=$'\t' read -r genome pipeline method motif; do
  awk -F '\t' '{print $0"\t"$2+length($5)-$7+1}' "${job}"_top200_R2/vcf_per_OTU/${genome}_F_seq_motif.txt > "${job}"_top200_R2/vcf_per_OTU/${genome}_F_seq_motif_newsite.txt
  awk -F '\t' '{print $0"\t"$2+$7}' "${job}"_top200_R2/vcf_per_OTU/${genome}_R_seq_motif.txt > "${job}"_top200_R2/vcf_per_OTU/${genome}_R_seq_motif_newsite.txt
done < list_genome_motif.txt

# 3. merge pileups distance <=3.
# The input file is a tab delimited txt file with 8 columns. The 2nd, 3rd, 4th, 7th and 8th columns are numbers.
# A python script that merges rows of the input file and save the output to a new tsv file. Between all rows have the same first column (strings), and when the absolute abstract of the two numbers in the 8th columns are less than 10, print the row between the two rows whose value in the 7th column is more close to 10 and replace the 4th columns with the sum of the 4th columns of the two rows. When the difference of the value in the 7th column of the two rows is tie, print the row of which the 4th column is larger. If the values in the 4th columns are still the same, print the first occurring row and replace the 4th columns with the sum of the 4th columns of the two rows.
while IFS=$'\t' read -r genome pipeline method motif; do
  python3 merge_pileup.py "${job}"_top200_R2/vcf_per_OTU/${genome}_F_seq_motif_newsite.txt "${job}"_top200_R2/site/${genome}_F_seq_motif_merge.txt
  python3 merge_pileup.py "${job}"_top200_R2/vcf_per_OTU/${genome}_R_seq_motif_newsite.txt "${job}"_top200_R2/site/${genome}_R_seq_motif_merge.txt
done < list_genome_motif.txt

## END
