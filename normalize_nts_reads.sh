#!/bin/bash

job=$1

for ratio in $(seq 0.1 0.1 1) ; do
    python3 normalize_nts_reads.py --input ptsite_${job}_r${ratio}_depth.txt --output ptsite_${job}_r${ratio}_depth_normalized.txt --job ${job}
    python3 normalize_nts_reads.py --input allsite_${job}_r${ratio}_depth.txt --output allsite_${job}_r${ratio}_depth_normalized.txt --job ${job}
done

