#!/bin/bash
#SBATCH -J nonpareil
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=300G
#SBATCH -t 24:00:00
#SBATCH --cpus-per-task=16
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0623_nonpareil_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0623_nonpareil_err.16

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC
conda activate girasoles-2-qc-1

# mkdir nonpareil_curve-files
# mkdir nonpareil_results

for f in fastp/*-trimmed_1.fastq.gz; do
    seqtk seq -a "$f" > "${f%.fastq.gz}.fasta"
done

for input in fastp/*-trimmed_1.fasta; do
    base="${input%-trimmed_1.fasta}"
    nonpareil -s "$input" -T kmer -f fasta -b "$base" -X 50000 -t 8
done

# File cleanup
rm fastp/*-trimmed_1.fasta
mv fastp/*.npo nonpareil_curve-files/
mv fastp/*.npa nonpareil_results/
mv fastp/*.npc nonpareil_results/
mv fastp/*.npl nonpareil_results/
