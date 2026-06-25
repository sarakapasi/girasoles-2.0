#!/bin/bash
#SBATCH -J assembly
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=600G
#SBATCH -t 24:00:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0624_assembly_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0624_assembly_err.16

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate girasoles-2-ab

# Parent directory containing all samples
NORM_DIRECT="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/bbnorm"
REG_DIRECT="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/fastp"

# Make output directories
cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/2_Assembly/
mkdir metaspades
mkdir norm_metaspades

# Metaspades

for r1 in "${REG_DIRECT}/*-trimmed_1.fastq.gz"; do
    sample=${r1%-trimmed_1.fastq.gz}
    r2="${sample}-trimmed_2.fastq.gz"

    echo "Assembling sample: $sample"
    metaspades.py \
        -1 "$r1" \
        -2 "$r2" \
        -o "metaspades/${sample}"

done

# Normalized Metaspades

for r1 in "${NORM_DIRECT}/*-norm_1.fastq.gz"; do
    sample=${r1%-norm_1.fastq.gz}
    r2="${sample}-norm_2.fastq.gz"

    echo "Assembling normalized sample: $sample"
    metaspades.py \
        -1 "$r1" \
        -2 "$r2" \
        -o "norm_metaspades/${sample}"
done
