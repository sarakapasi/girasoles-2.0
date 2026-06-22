#!/bin/bash
#SBATCH -J kraken2-build
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=150G
#SBATCH -t 0:30:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0622_kraken2-build_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0622_kraken2-build_err.16

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate girasoles-2-qc-1

cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/

kraken2-build --build --db kraken2_human_db/
kraken2-build --clean --db kraken2_human_db/
