#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 5-00:00:00
#SBATCH --mem=5gb
#######################3
dir=$1 # dir of vcf_per_OTU

# $1=chr, $2=pos, $3=DP, $4=delta-DP
# 'BEGIN{print '0'} and END{print '0'}: create 0,0 at the 1 and last line as DP
# head -n -2 or |tail -n +3: get the 0 to N-1 or 2 to N+1 lines.
# head -n -2 or : $4= the 0th to N-1 lines. $3-$4: row(n) - row(n-1) = F strand pileup.
# tail -n +3: $4= the 2nd to N+1 lines. $3-$4: row(n) - row(n+1) = R strand pileup.

for vcf in $(ls $dir/*vcf); do
  fout=${vcf%.vcf}
  paste -d ' ' <(awk -F '\t' '{print $1,$2,$5}' $vcf) \
  <(awk -F '\t' 'BEGIN{print '0'};{print $5};END{print '0'}' $vcf |head -n -2) | \
  awk '($3-$4)>0 {print $1,$2,$3,($3-$4)}' > ${fout}_F.txt

  paste -d ' ' <(awk -F '\t' '{print $1,$2,$5}' $vcf) \
  <(awk -F '\t' 'BEGIN{print '0'};{print $5};END{print '0'}' $vcf |tail -n +3) | \
  awk '($3-$4)>0 {print $1,$2,$3,($3-$4)}' > ${fout}_R.txt
>&2 echo $vcf
done
