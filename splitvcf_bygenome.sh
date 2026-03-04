#!/bin/bash

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
