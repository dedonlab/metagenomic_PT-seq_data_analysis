#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 1                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=200mb
#########################################################################

method=$1
dep=$2
ratio=$3

for pl in 1 2; do
  folder=pl"${pl}"_M"${method}"_top200_R2/meme_dep${dep}r${ratio}
  f_sum=meme_pl${pl}_M${method}_dep${dep}r${ratio}_summary.txt
  > $f_sum

  for txt in $(ls "${folder}"/*_meme.txt); do
    gname=$(basename ${txt} | sed 's/_meme.txt//')
    if grep -q 'E-value =' $txt; then
      grep 'E-value =' $txt | xargs -i echo -e "${gname}\t{}" >> $f_sum
    fi
  done
done

