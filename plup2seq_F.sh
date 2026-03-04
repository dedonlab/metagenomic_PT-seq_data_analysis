#!/bin/bash
# require samtools
# input columns: scaffold, pos, cov_at_pos, pileup_dep_mapper_R12.

dir_fr2=$1
vcf=$2 # file extension.
vcf=${vcf:="*vcf"} # file extension: default .vcf.

f=$3

for g in $(ls ${dir_fr2}/${vcf}); do
  gid=$(basename $g | sed 's/.vcf//' )

  genome='/home/yfyuan/data/PTseq/2025M1-4/fna_200clean/'${gid}'.fna'

  if [ -f $genome -a -f ${genome}.fai ] ; then
      plup=${dir_fr2}/${gid}_F_set.txt
      seq_out=${dir_fr2}/${gid}_F_seq.txt
      #remove negative number(positions)
      sed -i '/-/d' ${plup}
      >${seq_out}.tmp
      awk '{print $1,$2}' $plup | while read a b; do
        posl=$(($b-$f))
        if [ $posl -lt 0 ]; then
          posl=1
        fi
        posr=$(($b+$f))
        seq=$(samtools faidx -c -i $genome ${a}:${posl}-${posr} | grep -v '^>' )
        if [ -n $seq ] ; then
          echo "$seq" >> ${seq_out}.tmp
        else
          echo "NA" >> ${seq_out}.tmp
        fi
      done #awk.
      paste -d ' ' $plup ${seq_out}.tmp > ${seq_out}
      rm ${seq_out}.tmp
      
  else
    >&2 echo "$genome not exist"
  fi
done #genome.
