#!/bin/bash
#SBATCH -J multitrim
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=300G
#SBATCH -t 24:00:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0622_multitrim_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0622_multitrim_err.16
#SBATCH --array=1-194

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate multitrim

SAMPLE_LIST="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/folder_list.txt"
SAMPLE_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

KRAKEN_OUT_FILE_DIR = "/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC"
cd ${KRAKEN_OUT_FILE_DIR}
mkdir multitrim

echo ""
echo "Step 1: Locating input files..."
echo "=========================================="
echo "  Parent directory: $PARENT_DIR"
echo "  Sample name: $SAMPLE_NAME"

TRIMMED_1="${KRAKEN_OUT_FILE_DIR}/${SAMPLE_NAME}-filtered_1.fastq.gz"
TRIMMED_2="${KRAKEN_OUT_FILE_DIR}/${SAMPLE_NAME}-filtered_2.fastq.gz"

echo ""
echo "Step 2: Running multitrim..."
echo "=========================================="

multitrim -1 "${TRIMMED_1}" -2 "${TRIMMED_2}" --output multitrim --prefix "${SAMPLE_NAME}-processed" --zip gzip

echo ""
echo "=========================================="
echo "Multitrim completed successfully!"
