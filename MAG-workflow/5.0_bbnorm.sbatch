#!/bin/bash
#SBATCH -J bbnorm
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=300G
#SBATCH -t 24:00:00
#SBATCH --cpus-per-task=16
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0623_bbnorm_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0623_bbnorm_err.16

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC
conda activate girasoles-2-qc-1

# Make output directory for normalized files and stats
# mkdir bbnorm
# mkdir bbnorm_hist_files

echo ""
echo "Step 1: Running bbnorm..."
echo "=========================================="


QC_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC"
cd fastp

for r1 in *-trimmed_1.fastq.gz; do
    sample=${r1%-trimmed_1.fastq.gz}

    bbnorm.sh \
        in1="${sample}-trimmed_1.fastq.gz" \
        in2="${sample}-trimmed_2.fastq.gz" \
        out1="${QC_DIR}/bbnorm/${sample}-norm_1.fastq.gz" \
        out2="${QC_DIR}/bbnorm/${sample}-norm_2.fastq.gz" \
        target=40 \
        hist="${QC_DIR}/bbnorm_hist_files/${sample}-norm_hist.txt"
done

echo ""
echo "=========================================="
echo "File normalization completed successfully!"
