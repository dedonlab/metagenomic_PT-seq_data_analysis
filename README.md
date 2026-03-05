## Overview
This foler contains python scripts and bash commands used in the manuscripts entitled  
**"PT-seq: A method for metagenomic analysis of phosphorothioate epigenetics in complex microbial communities"**  
Author: *Yifeng Yuan, Michael S. DeMott, Shane R. Byrne, and Peter C. Dedon*

It aims to determine the reference genomes for the PT-seq data mining,  trim PT-seq reads and align them to the reference genomes, identify read pileups, extract sequences including 5 flanking nts at the pileup sites and identify the conserved motifs.

## Dependencies and environment  
sh, python, R  
RAM >= 100G is required. Threads >=4 is recommended.

#### The software/tools below should be installed and added to your system’s PATH so that it can be invoked from the command line. Specific versions are not required.  
bbmap v35.85 https://archive.jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/installation-guide/  
fastqc v0.11.8 https://github.com/s-andrews/FastQC  
Kraken2 v2.1.3 https://github.com/DerrickWood/kraken2  
Bracken v2.9 https://github.com/jenniferlu717/Bracken  
jdk v1.8.0-101 https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html  
Mapper v1.1.0-beta05 https://github.com/mathjeff/mapper  
bowtie2 v2.4.5 https://github.com/BenLangmead/bowtie2/releases  
samtools v1.19.2 https://github.com/samtools/samtools/releases  
bedtools v2.30.0 https://github.com/arq5x/bedtools2/releases  
SMARTcleaner-master v1.0 https://github.com/dzhaobio/SMARTcleaner  
seqkit v2.1.0 https://bioinf.shenwei.me/seqkit  
python v3.5.2 and higher https://www.python.org/downloads/release/python-352/  
#### The installation time for tools above should be no more than 1 hour.  
MEME-suit v5.3.3 #Please follow the instructions of the MEME suite via its website at http://meme-suite.org  
Dependences for MEME-suit v5.3.3  
perl v5.18.2 https://www.cpan.org/src  
ghostscript v9.52 https://ghostscript.com/releases   
automake v1.15 https://ftp.gnu.org/gnu/automake  
autoconf v2.69 https://www.gnu.org/software/autoconf/  
python v3.5.2 and higher https://www.python.org/downloads/release/python-352/  
zlib v1.2.11 https://github.com/jrmwng/zlib-1.2.11  
xz v5.2.3 https://github.com/tukaani-project/xz/releases  
lzma v4.32.7 https://sourceforge.net/projects/lzma/  
#### Depending on the environment of the system, the installation time for MEME-suite can be from less than 1 hour to about 3 hours.  

## Usage

### 0. Prepare  
1. Install the dependences
2. Download the scripts. Place them in the work directory, e.g. work.
4. Keep the demo dataset in work/demo/
5. To deplete human sequence contamination, please download the hg19_main_mask_ribo_animal_allplant_allfungus.fa.gz file at https://zenodo.org/records/1208052 and place it in the work/demo folder with the demo reads.
6. Modify trim.sh with ${path_to_your_bbmap}
7. For demo data analysis, users can start with trimmed reads (\*_final.fastq) and demo reference genomes available at https://doi.org/10.6084/m9.figshare.31476859. Extract and put the folder in the work/demo folder.

### 1. Trim reads  
RAM >= 50G is required. For real PT-seq dataset, we recommond thread >= 10.  
```
# Ensure bbmap and fastqc added to your system’s PATH so that it can be invoked from the command line.  

sh trim.sh demo/demo_1.fastq demo/demo_2.fastq job_demo  
```  
The output files for the next step are trimmed reads: `job_demo_R1_final.fastq` and `job_demo_R2_final.fastq`. The output files also include intermediate .fq files and QC report files.

### 2. Prepare reference genome using UHGG2 and Kraken2-Bracken  
Map reads to UHGG2 genomes to estimate the composition of the gut microbiome. Either PT-seq reads or metagenomic sequencing reads can be used (pipeline 1 and pipeline 2 in the manuscript). Download the UHGG2 Kraken2 and Bracken database (e.g. database150mers.kmer_distrib) from https://www.ebi.ac.uk/metagenomics/genome-catalogues/human-gut-v2-0-2. Put the 'myDB' in the work/UHGG2 folder.  
```
# 1. Kraken2
# Ensure Kraken2 and Bracken  added to your system’s PATH so that it can be invoked from the command line.  
mydb= path to myDB, e.g. work/UHGG2/myDB  
dir_w= work directory, e.g. work  

# Threads >=8 is recommended.   
t=number of threads  

k_report=work/UHGG2/demo_kraken.report  
k_file=work/UHGG2/demo_kraken.kraken  
read1=work/demo/demo_R1_final.fastq  
read2=work/demo/demo_R2_final.fastq  

kraken2 --use-names --paired --threads $t --db $mydb --report $k_report $read1 $read2 > ${k_file}  

# 2. Bracken  
READ_LEN=150  
KMER_LEN=35

# Threads >=8 is recommended.  
THREADS= number of threads  

cd ${myDB}  
BRACKEN_OUTPUT_FILE=work/UHGG2/demo.bracken  
python path_to_Bracken/Bracken-master/src/est_abundance.py -i ${k_report} -k database${READ_LEN}mers.kmer_distrib -o ${BRACKEN_OUTPUT_FILE}
```

Output: work/UHGG2/demo.bracken is the table of estimated abundance of UHGG2 genomes. 

### 3. Align PTseq reads to the reference genomes  
We used the most abundant 200 genomes estimated by Kraken2-Bracken as the reference genomes of the gut microbiome for the sample.  
Retrieve the most abundant 200 genomes (fna files) from https://www.ebi.ac.uk/metagenomics/genome-catalogues/human-gut-v2-0-2. Put them in the folder work/demo/fna_200clean. 
For demo, the compressed reference genomes are provided at https://doi.org/10.6084/m9.figshare.31476859. Extract and put the 'fna_200clean' folder in the work/demo directory.  

Prepare mapper scripts, 'mapper_brackentop200_R12.sh' and 'mapper_brackentop200_R2.sh', following the instruction https://github.com/mathjeff/mapper.  
'mapper_brackentop200_R12.sh' is used to align read 1 and 2, and 'mapper_brackentop200_R2.sh' is used to align read 2 only.

A demo 'demo_mapper_top200_R12.sh' and 'demo_mapper_top200_R2.sh' are provided in the repository.  

```
# RAM >= 100G is required. Threads >= 10 is recommended.
# Ensure mapper added to your system’s PATH so that it can be invoked from the command line.  
threads= number of threads

read1=work/demo/demo_R1_final.fastq  
read2=work/demo/demo_R2_final.fastq

dir_m=demo_top200_R12 # path to output  
sh demo_mapper_top200_R12.sh $read1 $read2 ${dir_m} ${threads}  

dir_m=demo_top200_R2 # path to output  
sh demo_mapper_top200_R2.sh $read1 $read2 ${dir_m} ${threads}  
```

Output: demo_top200_R12/top200.vcf and demo_top200_R2/top200.vcf.

### 4. Convert vcf files to read pileups  
```
# 1. split vcf for each reference genome  
sh splitvcf_bygenome.sh demo_top200_R12/top200.vcf  
sh splitvcf_bygenome.sh demo_top200_R2/top200.vcf  

# Output: demo_top200_R12/vcf_per_OTU and demo_top200_R2/vcf_per_OTU  

# 2. convert vcf to pileups  
sh vcf2plup.sh demo_top200_R12/vcf_per_OTU  
sh vcf2plup.sh demo_top200_R2/vcf_per_OTU  

# Output: demo_top200_R12/vcf_per_OTU/*_R.txt and demo_top200_R12/vcf_per_OTU/*_F.txt.  
# F: - strand; R: + strand.  
# Column 1: chr; column 2: position; column 3: coverage; column4: read pileup depth.  

# 3. keep pileups in R2 only
sh plup_keepR2.sh demo_top200_R12/vcf_per_OTU demo_top200_R2/vcf_per_OTU

# Output: demo_top200_R12/vcf_per_OTU/*_F_set.txt and *_R_set.txt.  
# F: - strand; R: + strand.  
# Column 1: chr; column 2: position; column 3: coverage; column4: read pileup depth.

# 4. retrieve sequences of pileups
# Ensure samtools added to your system’s PATH so that it can be invoked from the command line.  
# flank= number of flanking nts. 2n+1 nts will be retrieved. For example  
flank=5

# for + strand  
sh plup2seq_R.sh pl1_M1_top200_R2/vcf_per_OTU vcf ${flank}  

# for - strand, reverse complementary sequences will be retrieved.  
sh plup2seq_R.sh pl1_M1_top200_R2/vcf_per_OTU vcf ${flank}

```

### 5. Motif detection using MEME-suite  

```
# Ensure meme and seqkit added to your system’s PATH so that it can be invoked from the command line.
# job = jobname. e.g. demo.
# d = The minimal depth of read pileups. The larger depth, the more specificity and less sensitivity. 0.5-3 is good range for both specificity and sensitivity for motif detection.  
# r = The minimal ratio of read pileup depth to coverage. The larger ratio, the more specificity and less sensitivity. 0.1-0.5 is good range for both specificity and sensitivity for motif detection.  
# t= number of threads. t>=2 is recommended.

job=demo  
r=0.1
d=1
t=4

sh seq2fasta.sh ${job} ${d} ${r}  

# Output: demo_top200_R2/vcf_per_OTU/*_dep${depth}r${ratio}min8.fasta  

sh meme.sh ${job} ${d} ${r} ${t}  

# Output: demo_top200_R2/meme_dep${dep}r${ratio}/*_meme.txt and demo_top200_R2/meme_dep${dep}r${ratio}/*_meme.html.  
# For details of output files, see the instruction of meme-suite.  

# summarize meme results  

sh summary_meme.sh ${job} ${d} ${r}  

# Output: meme_${job}_dep${dep}r${ratio}_summary.txt.
```

Depending on the numbers of sites and E-value, motifs and PT-containing genomes then can be called per reference genome by the users. In the manuscript, we used a cut of E-value of 0.05 and a cutoff of the numbers of sites of 200.  
Output: list_genome_motif.txt. A tab delimited txt file of PT-containing genomes. The 1st column is genome ID. The 2nd column is job name. The 3rd column are space delimited motifs. For example:  
MGYG000000562	demo	GAAC GTTC  
MGYG000001302.1	demo	CAG CCA  
MGYG000001346	1	demo CAG  

### 6. Locate and merge PT sites  
Errors in library preparation, sequencing, trimming, and so on can cause shift of the read 2 of a read. As a result, we merged 3 consecutive pileups to the one with the large read depth.

```
job=demo  # job name

sh assign_motif2seq_merge.sh list_genome_motif.txt ${demo}

```
Intermediate files: "${job}"_top200_R2/site/${genome}_R_seq_motif_merge.txt and "${job}"_top200_R2/site/${genome}_F_seq_motif_merge.txt. Merged pileups in +/- strand, respectively.  
Output: "${job}"_top200_R2/site/${genome}_allsite.txt
**Column 1 is genome ID. Column 2 is the start position of the sequence. Column 3 is coverage. Column 4 is read pileup depth. Column 5 is sequence. Column 6 is motif. Column 7 is postion of pt in the sequence. Column 8 is the position of pt in the genome. Column 9 is strand.**

### 7. Summarize and report the profile of PT sites depending on the depth and depth-to-coverage ratio  
The cutoff of the depth of read pileups and the cutoff of pileup-depth-to-coverage ratio determine the specificity and sensitivity of PT site detection. The larger depth and ratio, the more specificity and less sensitivity. Therefore, we summarize the number of PT sites and the specificity of PT sites/total pileup sites for a range of depth from 1 to 50 and a range of depth-to-coverage ratio from 0.1 to 1.0.

```

```

## Contributors
Yifeng Yuan, Ph.D.  yuanyifeng@mit.edu  
Michael S. DeMott, Ph.D.  msdemott@mit.edu  
Anni Zhang, Ph.D.  anni.zhang@ntu.edu.sg  
Peter C. Dedon, Ph.D. (Principal Investigator and corresponding author)

## Help and Issues
Please contact Yifeng Yuan at yuanyifeng@ufl.edu or Michael S. DeMott at msdemott@mit.edu

## Version History
v0.9.0 -- Submission version. Initial release. 
