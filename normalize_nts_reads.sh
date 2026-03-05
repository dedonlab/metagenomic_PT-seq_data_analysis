#!/bin/bash

job=$1
nts=$2
reads=$3

for ratio in $(seq 0.1 0.1 1) ; do
    python3 normalize_nts_reads.py --input ptsite_${job}_r${ratio}_depth.txt --output ptsite_${job}_r${ratio}_depth_normalized.txt --nts ${nts} --reads ${reads}
    python3 normalize_nts_reads.py --input allsite_${job}_r${ratio}_depth.txt --output allsite_${job}_r${ratio}_depth_normalized.txt --nts ${nts} --reads ${reads}
done

