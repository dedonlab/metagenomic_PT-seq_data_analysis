## Overview
This foler contains python scripts and bash commands used in the manuscripts entitled  
**"PT-seq: A method for metagenomic analysis of phosphorothioate epigenetics in complex microbial communities"**  
Author: *Yifeng Yuan, Michael S. DeMott, Shane R. Byrne, and Peter C. Dedon*

It aims to determine the reference genomes for the PT-seq data mining,  trim PT-seq reads and align them to the reference genomes, identify read pileups, extract sequences including 5 flanking nts at the pileup sites and identify the conserved motifs.

## Dependencies and environment  
sh, python, R

#### The software/tools below should be installed and added to your system’s PATH so that it can be invoked from the command line. Specific versions are not required.  
bbmap v35.85 https://archive.jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/installation-guide/  
fastqc v0.11.8 https://github.com/s-andrews/FastQC  
Kraken2 v2.1.3 https://github.com/DerrickWood/kraken2  
Bracken v2.9 https://github.com/jenniferlu717/Bracken
bowtie2 v2.4.5 https://github.com/BenLangmead/bowtie2/releases  
samtools v1.19.2 https://github.com/samtools/samtools/releases/  
bedtools v2.30.0 https://github.com/arq5x/bedtools2/releases  
SMARTcleaner-master v1.0 https://github.com/dzhaobio/SMARTcleaner  
seqkit v2.1.0 https://bioinf.shenwei.me/seqkit/  
#### The installation time for tools above should be no more than 1 hour.  
MEME-suit v5.3.3 #Please follow the instructions of the MEME suite via its website at http://meme-suite.org  
Dependences for MEME-suit v5.3.3  
perl v5.18.2 https://www.cpan.org/src/  
ghostscript v9.52 https://ghostscript.com/releases/  
automake v1.15 https://ftp.gnu.org/gnu/automake/  
autoconf v2.69 https://www.gnu.org/software/autoconf/  
python v3.5.2 and higher https://www.python.org/downloads/release/python-352/  
zlib v1.2.11 https://github.com/jrmwng/zlib-1.2.11  
jdk v1.8.0-101 https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html  
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
sh trim.sh demo/demo_1.fastq demo/demo_2.fastq job_demo  
```  
The output files for the next step are trimmed reads: `job_demo_R1_final.fastq` and `job_demo_R2_final.fastq`. The output files also include intermediate .fq files and QC report files.

### 2. Prepare reference genome using UHGG2 and Kraken2-Bracken  
Map reads to UHGG2 genomes to estimate the composition of the gut microbiome. Either PT-seq reads or metagenomic sequencing reads can be used (pipeline 1 and pipeline 2 in the manuscript). Download the UHGG2 Kraken2 and Bracken database (e.g. database150mers.kmer_distrib) from https://www.ebi.ac.uk/metagenomics/genome-catalogues/human-gut-v2-0-2. Put the 'myDB' in the work/UHGG2 folder.  
```
# 1. kraken2
mydb= path to myDB, e.g. work/UHGG2/myDB  
dir_w= work directory, e.g. work
t=number of threads

k_report=work/UHGG2/demo_kraken.report  
k_file=work/UHGG2/demo_kraken.kraken  
read1=work/demo/demo_R1_final.fastq  
read2=work/demo/demo_R2_final.fastq  

kraken2 --use-names --paired --threads $t --db $mydb --report $k_report $read1 $read2 > ${k_file}  

# 2. Bracken  
READ_LEN=150  
KMER_LEN=35  
THREADS= number of threads  

cd ${myDB}  
BRACKEN_OUTPUT_FILE=work/UHGG2/demo.bracken  
python path_to_Bracken/Bracken-master/src/est_abundance.py -i ${k_report} -k database${READ_LEN}mers.kmer_distrib -o ${BRACKEN_OUTPUT_FILE}
```

### 3. Align PTseq reads to the reference genomes
We used the most abundant 200 genomes estimated by Kraken2-Bracken as the reference genomes of the gut microbiome for the sample.

2\) map reads to genome, identify pileups and extract sequences at pileup site with 6 flanking nt.
    input: reference genome, trimmed reads, job name
   
   <pre><code>sh main.sh demo/UYXE01.1.fsa demo/demo_1.fastq demo/demo_2.fastq demo</code></pre>

    The output files for the next step are fasta file of pileups before filter: `dome_pileup_dep0.fasta` 
   and tab delimited .txt files: `dome_pileup_dep0_F.pos.txt` and `demo_pileup_dep0_R.pos.txt`. The columnns are:
   
    scaffold id, chromosome position of pileup, coverage, pileup depth, depth to coverage ratio, sequence (6 flank nt)
   
   3\) identify conserved motifs using MEME-suit. Input file `dome_pileup_dep0.fasta`. Output: meme/dome_pileup_dep0.txt`
   
   <pre><code>sh meme.sh</code></pre>

   4\) merge pileup sites.

   <pre><code>sh mergepileup.sh</code></pre>

   The output file is a tab delimited txt file with columns: scaffold, genome position, coverage, depth of read 2, depth-to-coverage ratio, sequence with 6-nt flanking, strand, motif.

   5\) calculate the number of pileups.
   
   <pre><code>sh motif_stat.sh</code></pre>

   The output file is a txt file with motifs such as, CAG, CCA, GATC/GATC, GAAC/GTTC, and corresponding number of modified motif sites.

   6\) Summarize the number of pileups per gene class.
   
   <pre><code>sh pileup_to_gffClass.sh</code></pre>
   
   <pre><code>sh summary_geneClass.sh</code></pre>
   The output file is a table of gene class (CDS, rRNA, tRNA) and corresponding number of total motif sites and modified motif sites.

## Contributors
Yifeng Yuan, Ph.D.  yuanyifeng@mit.edu  
Michael S. DeMott, Ph.D.  msdemott@mit.edu  
Anni Zhang, Ph.D.  anni.zhang@ntu.edu.sg  
Peter C. Dedon, Ph.D. (Principal Investigator and corresponding author)

## Help and Issues
Please contact Yifeng Yuan at yuanyifeng@ufl.edu or Michael S. DeMott at msdemott@mit.edu

## Version History
v0.9.0 -- Submission version. Initial release. 
