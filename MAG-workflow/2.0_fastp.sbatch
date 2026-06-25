#!/bin/bash
#SBATCH -J fastp
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=50G
#SBATCH -t 00:20:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0623_fastp_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0623_fastp_err.16
#SBATCH --array=1-194

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate girasoles-2-qc-1

SAMPLE_LIST="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/folder_list.txt"
SAMPLE_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

QC_FILE_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC"
cd ${QC_FILE_DIR}

# Prep output folders:
# mkdir fastp
# mkdir fastp-reports

echo ""
echo "Step 1: Locating input files..."
echo "=========================================="
echo "  Sample name: $SAMPLE_NAME"

TRIMMED_1="${QC_FILE_DIR}/${SAMPLE_NAME}-filtered_1.fastq.gz"
TRIMMED_2="${QC_FILE_DIR}/${SAMPLE_NAME}-filtered_2.fastq.gz"
OUTPUT_DIR="${QC_FILE_DIR}/fastp"
OUT_1="${OUTPUT_DIR}/${SAMPLE_NAME}_trimmed_1.fastq.gz"
OUT_2="${OUTPUT_DIR}/${SAMPLE_NAME}_trimmed_2.fastq.gz"

echo ""
echo "Step 2: Running fastp..."
echo "=========================================="

fastp -i "${TRIMMED_1}" -o "${OUT_1}" -I "${TRIMMED_2}" -O "${OUT_2}" -l 50 -z 9 -j "fastp-reports/${SAMPLE_NAME}.json" -h "fastp-reports/${SAMPLE_NAME}.html" --verbose 

echo ""
echo "=========================================="
echo "Fastp completed successfully!"
