#!/bin/bash

job=$1
dep=$2
ratio=$3

folder="${job}"_top200_R2/meme_dep${dep}r${ratio}
f_sum=meme_${job}_dep${dep}r${ratio}_summary.txt
> $f_sum

for txt in $(ls "${folder}"/*_meme.txt); do
  gname=$(basename ${txt} | sed 's/_meme.txt//')
  if grep -q 'E-value =' $txt; then
    grep 'E-value =' $txt | xargs -i echo -e "${gname}\t{}" >> $f_sum
  fi
done

