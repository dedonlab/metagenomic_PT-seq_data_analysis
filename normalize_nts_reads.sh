#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=2gb
##########################

ratio=$1

for pipeline in 1 2; do
  for method in 1 2 3 4 ; do
    #python3 normalize_nts_reads.py --input ptsite_r${ratio}_pl${pipeline}_M${method}_depth.txt --output ptsite_r${ratio}_pl${pipeline}_M${method}_depth_normalized.txt --pipeline ${pipeline} --method ${method}
    python3 normalize_nts_reads.py --input allsite_r${ratio}_pl${pipeline}_M${method}_depth.txt --output allsite_r${ratio}_pl${pipeline}_M${method}_depth_normalized.txt --pipeline ${pipeline} --method ${method}
  done
done

