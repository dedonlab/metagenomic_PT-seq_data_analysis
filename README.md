## Overview
This foler contains python scripts and bash commands used in the manuscripts entitled  
**"PT-seq: A method for metagenomic analysis of phosphorothioate epigenetics in complex microbial communities"**  
Author: *Yifeng Yuan, Michael S. DeMott, Shane R. Byrne, and Peter C. Dedon*

It aims to determine the reference genomes for the PT-seq data mining,  trim PT-seq reads and align them to the reference genomes, identify read pileups, extract sequences including 5 flanking nts at the pileup sites and identify the conserved motifs.

## Dependencies and environment
sh, python, R

#### The software/tools below should be installed and added to your system’s PATH so that it can be invoked from the command line.
bbmap v35.85 https://archive.jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/installation-guide/  
fastqc v0.11.8 https://github.com/s-andrews/FastQC  
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
2. Download the scripts and the demo dataset. Place them in the work directory, e.g. work.
3. Keep the demo dataset in work/demo/
4. (Optional) To deplete human sequence contamination, please download the hg19_main_mask_ribo_animal_allplant_allfungus.fa.gz file at https://zenodo.org/records/1208052 and place it in the work/demo folder with the demo reads.
5. Modify trim.sh with ${path_to_your_bbmap}

### 1. Trim  
1.1 trim reads: RAM >= 50G is required. For real PT-seq dataset, we recommond thread >= 10.  
```
sh trim.sh demo/demo_1.fastq demo/demo_2.fastq job_demo  
```  
The output files for the next step are trimmed reads: `job_demo_R1_final.fastq` and `job_demo_R2_final.fastq`. The output files also include intermediate .fq files and QC report files.



## Contributors
Yifeng Yuan, Ph.D.  yuanyifeng@mit.edu  
Michael S. DeMott, Ph.D.  msdemott@mit.edu  
Anni Zhang, Ph.D.  anni.zhang@ntu.edu.sg  
Peter C. Dedon, Ph.D. (Principal Investigator and corresponding author)

## Help and Issues
Please contact Yifeng Yuan at yuanyifeng@ufl.edu or Michael S. DeMott at msdemott@mit.edu

## Version History
v0.9.0 -- Submission version. Initial release. 
