#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 5-00:00:00
#SBATCH --mem=2gb
#############################################

fin_vcf=$1

dir_out=$(cd "$(dirname "$fin_vcf")"; pwd -P)/vcf_per_OTU # get the dir of vcf file.

mkdir $dir_out || true  # create vcf_per_OTU in the dir of vcf file.

awk -F "\t" -v d=$dir_out 'FNR>1{split($1, subfield,"_"); print>(d"/"subfield[1]".vcf")}' $fin_vcf

#awk -F "\t" -v d=$dir_out 'FNR>1{if ($1~/GUT_GENOME/) {split($1, subfield,"_"); print>(d"/"subfield[1]"_"subfield[2]".vcf")} \
#else {split($1, subfield,"_"); print>(d"/"subfield[1]"_"subfield[2]"_"subfield[3]"_"subfield[4]".vcf")}}' $fin_vcf

#awk -F "\t" -v d=$dir_out 'FNR>1{if ($1~/^ncbi_/||$1~/^nt_/) print>(d"/"$1".vcf");\
#else if ($1~/^GUT_/) {split($1, subfield,"_"); print>(d"/"subfield[1]"_"subfield[2]".vcf")}\
#else if ($1~/^ptrc_/||$1~/^prtc_/) {split($1, subfield,"_"); print>(d"/"subfield[1]"_"subfield[2]"_"subfield[3]".vcf")}\
#else {split($1, subfield,"_"); print>(d"/"subfield[1]"_"subfield[2]"_"subfield[3]"_"subfield[4]".vcf")}}' $fin_vcf
