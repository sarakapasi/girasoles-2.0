#!/bin/bash
#SBATCH -J kraken2
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=300G
#SBATCH -t 24:00:00
#SBATCH --cpus-per-task=16
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0622_kraken2_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0622_kraken2_err.16
#SBATCH --array=1-194

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate girasoles-2-qc-1

SAMPLE_LIST="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/folder_list.txt"
SAMPLE_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

# Parent directory containing all samples
FILE_HOME_DIR="/storage/home/hcoda1/0/skapasi3/scratch/Girasoles-2-files"
OUTPUT_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/kraken2-out-report"
mkdir -p "$OUTPUT_DIR"
cd "/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC"

# Number of threads (match --cpus-per-task)
THREADS=16

echo ""
echo "Step 1: Locating input files..."
echo "=========================================="
echo "  Parent directory: $PARENT_DIR"
echo "  Sample name: $SAMPLE_NAME"

R1="${FILE_HOME_DIR}/${SAMPLE_NAME}/${SAMPLE_NAME}_1.fastq.gz"
R2="${FILE_HOME_DIR}/${SAMPLE_NAME}/${SAMPLE_NAME}_2.fastq.gz"

echo ""
echo "Step 2: Running Kraken2..."
echo "=========================================="

kraken2 --db kraken2_human_db/ --gzip-compressed --paired "${R1}" "${R2}" --threads $THREADS --report "${OUTPUT_DIR}/${SAMPLE_NAME}-kraken2-report.txt" --unclassified-out "${SAMPLE_NAME}-filtered#.fastq"
gzip "${SAMPLE_NAME}-filtered_1.fastq" "${SAMPLE_NAME}-filtered_2.fastq"

echo ""
echo "=========================================="
echo "Kraken2 completed successfully!"
