#!/bin/bash
#SBATCH -N 1                       # Number of nodes. You must always set -N 1 unless you receive special instruction from the system admin
#SBATCH -n 4                       # Number of tasks. Don't specify more than 16 unless approved by the system admin
#SBATCH --mail-type=END            # Type of email notification- BEGIN,END,FAIL,ALL. Equivalent to the -m option in SGE
#SBATCH --mail-user=yuanyifeng@ufl.edu # Email to which notifications will be sent. Equivalent to the -M option in SGE. You must replace [] with your email address.
#SBATCH -t 1-00:00:00
#SBATCH --mem=2gb
###############################

#module load meme/5.0.4
#module load meme/4.11.3
module swap mvapich2  mpich/3.2
module load meme/5.3.3
#module load openmpi/1.10.4

method=$1
dep=$2
ratio=$3

for pl in 1 2; do
  folder=pl"${pl}"_M"${method}"_top200_R2
  dir_o=${folder}/meme_dep${dep}r${ratio}

  for file in $(ls "${folder}"/vcf_per_OTU/*_R_seq.txt); do
    gname=$(basename $file| sed 's/_R_seq.txt//')
    fas="${folder}"/vcf_per_OTU/${gname}_dep"${dep}"r${ratio}min8.fasta

    meme -p 4 -dna -objfun classic -nmotifs 6 -mod zoops -evt 0.05 -time 3000 -minw 3 -maxw 4 -markov_order 0 -nostatus -oc ${dir_o} $fas

    mv ${dir_o}/meme.html ${dir_o}/${gname}_meme.html
    mv ${dir_o}/meme.txt ${dir_o}/${gname}_meme.txt
  done
done


