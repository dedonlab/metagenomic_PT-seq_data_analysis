#!/bin/bash

# input columns: scaffold, pos, cov_at_pos, pileup_dep_in_R12 or pileup_dep_in_R2.
# output columns: scaffold, pos, cov_at_pos, pileup_dep_in_R12.
dir_fr12=$1
dir_fr2=$2

cutoff=0.5 # cutoff of pileup depth =0.5.

for g in $(ls ${dir_fr2}/*vcf); do
  gname=$(basename $g | sed 's/.vcf//' )

  fr2=${dir_fr2}/${gname}_F.txt
  fr12=${dir_fr12}/${gname}_F.txt
  fout=${dir_fr2}/${gname}_F_set.txt
  
  # output columns: scaffold, pos, cov_at_pos, pileup_dep_in_R12.
  awk -v c=$cutoff '(NR==FNR){a[$1":"$2];next}($4>=c&&$1":"$2 in a)' ${fr2} ${fr12} > ${fout}

  #remove negative number(positions)
  sed -i '/-/d' ${fout}

  # output columns: scaffold, pos, cov_at_pos, pileup_dep_in_R2, pileup_dep_in_R12.
  # awk -v c=$cutoff '(NR==FNR&&$4>=c){a[$1":"$2];next}($4>=c&&$1":"$2 in a)' ${fr12} ${fr2} > ${fr2}.r12.tmp # output: scaffold, pos, cov_at_pos, pileup_dep_in_R2.
  # awk -v c=$cutoff '(NR==FNR){b[$1":"$2];next}($1":"$2 in b)' ${fr2}.r12.tmp ${fr12} | awk '{print $4}'> ${fr12}.tmp # output : pileup_dep_in_R12.
  #paste -d ' ' ${fr2}.r12.tmp ${fr12}.tmp > ${fr2}  # paste: scaffold, pos, cov_at_pos, pileup_dep_in_R2, pileup_dep_in_R12.
  #rm ${fr12}.tmp ${fr2}.r12.tmp
  
  fr2=${dir_fr2}/${gname}_R.txt
  fr12=${dir_fr12}/${gname}_R.txt
  fout=${dir_fr2}/${gname}_R_set.txt

  # output columns: scaffold, pos, cov_at_pos, pileup_dep_in_R12.
  awk -v c=$cutoff '(NR==FNR){a[$1":"$2];next}($4>=c&&$1":"$2 in a)' ${fr2} ${fr12} > ${fout}

  #remove negative number(positions)
  sed -i '/-/d' ${fout}
  
  # output columns: scaffold, pos, cov_at_pos, pileup_dep_in_R2, pileup_dep_in_R12.
  #awk -v c=$cutoff '(NR==FNR&&$4>=c){a[$1":"$2];next}($4>=c&&$1":"$2 in a)' ${fr12} ${fr2} > ${fr2}.r12.tmp
  #awk -v c=$cutoff '(NR==FNR){b[$1":"$2];next}($1":"$2 in b)' ${fr2}.keep${cutoff}.tmp ${fr12} | awk '{print $4}'> ${fr12}.tmp
  #paste -d ' ' ${fr2}.r12.tmp ${fr12}.tmp > ${fr2}
  #rm ${fr12}.tmp ${fr2}.r12.tmp
done


#### END ####
