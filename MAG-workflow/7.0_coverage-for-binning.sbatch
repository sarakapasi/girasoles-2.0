#!/bin/bash
#SBATCH -J binning-coverage
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=10G
#SBATCH -t 00:30:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0624_binning-coverage_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0624_binning-coverage_err.16
#SBATCH --array=1-194

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate girasoles-2-ab
cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/2_Assembly

ASSEMBLY_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/2_Assembly"
FILE_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/fastp"
NORM_FILE_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/bbnorm"

# Get sample ID and directory for this array index from the sample file made
SAMPLE_ID=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/folder_list.txt)

echo "Processing: $SAMPLE_ID"

# Find the assembly output directories
SPADES_DIR="${ASSEMBLY_DIR}/metaspades/${SAMPLE_ID}"
N_SPADES_DIR="${ASSEMBLY_DIR}/norm_metaspades/${SAMPLE_ID}"

# Check for contigs.fasta
CONTIGS="${SPADES_DIR}/contigs.fasta"
N_CONTIGS="${N_SPADES_DIR}/contigs.fasta"

# Find paired-end reads - normal
R1="${FILE_DIR}/${SAMPLE_ID}_trimmed_1_fastq.gz"
R2="${FILE_DIR}/${SAMPLE_ID}_trimmed_2_fastq.gz"

# Find paired-end reads - NORMALIZED
R1-norm="${NORM_FILE_DIR}/${SAMPLE_ID}-norm_1.fastq.gz"
R2-norm="${NORM_FILE_DIR}/${SAMPLE_ID}-norm_2.fastq.gz"

# Prepare analysis directory
ANALYSIS_DIR="${ASSEMBLY_DIR}/metaspades_abundance"
mkdir -p "$ANALYSIS_DIR"
cd "$ANALYSIS_DIR" || exit 0

# Run analysis tools to make abundance files 
echo "  Building Bowtie2 index..."
bowtie2-build "$CONTIGS" bowtie_contigs.fasta
echo "  Aligning reads to contigs..."
bowtie2 -p 16 -x bowtie_contigs.fasta -1 "${R1}" -2 "${R2}" -S contigs_vs_reads.sam
echo "  Converting and sorting SAM/BAM..."
samtools view -S --threads 10 -b contigs_vs_reads.sam > contigs_vs_reads.bam
samtools sort contigs_vs_reads.bam -o contigs_vs_reads.sorted.bam
echo "  Generating depth file..."
jgi_summarize_bam_contig_depths --outputDepth coverage_for_metabat.txt contigs_vs_reads.sorted.bam
cut -f1,3 coverage_for_metabat.txt | sed '1d' > coverage_for_maxbin.txt

# Prepare analysis directory - normalized metaspades
N_ANALYSIS_DIR="${ASSEMBLY_DIR}/norm_metaspades_abundance"
mkdir -p "$N_ANALYSIS_DIR"
cd "$N_ANALYSIS_DIR" || exit 0

# Run analysis tools to make abundance files 
echo "  Building Bowtie2 index for normalized files..."
bowtie2-build "$N_CONTIGS" bowtie_contigs.fasta
echo "  Aligning reads to contigs..."
bowtie2 -p 16 -x bowtie_contigs.fasta -1 "${R1-norm}" -2 "${R2-norm}" -S contigs_vs_reads.sam
echo "  Converting and sorting SAM/BAM..."
samtools view -S --threads 10 -b contigs_vs_reads.sam > contigs_vs_reads.bam
samtools sort contigs_vs_reads.bam -o contigs_vs_reads.sorted.bam
echo "  Generating depth file..."
jgi_summarize_bam_contig_depths --outputDepth coverage_for_metabat.txt contigs_vs_reads.sorted.bam
cut -f1,3 coverage_for_metabat.txt | sed '1d' > coverage_for_maxbin.txt

echo "Done with $SAMPLE_ID"
