#!/bin/bash
#SBATCH -J binning-maxbin-metabat
#SBATCH -A gts-ktk3-coda20
#SBATCH -n 8
#SBATCH --mem=10G
#SBATCH -t 00:45:00
#SBATCH -q inferno
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -o /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0624_maxbin-metabat_out.16
#SBATCH -e /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/log/0624_maxbin-metabat_err.16
#SBATCH --array=1-194

source /storage/home/hcoda1/0/skapasi3/r-ktk3-0/miniconda3/etc/profile.d/conda.sh
conda activate girasoles-2-ab

cd /storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/3_Binning/

SAMPLE_LIST="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/1_QC/folder_list.txt"
SAMPLE_NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLE_LIST")

# Initialize assembly directories
ASSEMBLY_DIR="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/2_Assembly"
METASP_SAMPLE_DIR="${ASSEMBLY_DIR}/metaspades/${SAMPLE_NAME}"
N_METASP_SAMPLE_DIR="${ASSEMBLY_DIR}/norm_metaspades/${SAMPLE_NAME}"

# Initialize assembly files used for binning
METASP_CONTIGS_FILE="${METASP_SAMPLE_DIR}/contigs.fasta"
N_METASP_CONTIGS_FILE="${N_METASP_SAMPLE_DIR}/contigs.fasta"

# Initialize coverage files (made in a previous step)
METASP_COVERAGE_MX="${ASSEMBLY_DIR}/metaspades_abundance/${SAMPLE_NAME}/coverage_for_maxbin.txt"
N_METASP_COVERAGE_MX="${ASSEMBLY_DIR}/norm_metaspades_abundance/${SAMPLE_NAME}/coverage_for_maxbin.txt"
METASP_COVERAGE_MB="${ASSEMBLY_DIR}/metaspades_abundance/${SAMPLE_NAME}/coverage_for_metabat.txt"
N_METASP_COVERAGE_MB="${ASSEMBLY_DIR}/norm_metaspades_abundance/${SAMPLE_NAME}/coverage_for_metabat.txt"

# Prepare bin folders
METASP_MAXBIN_BINS="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/3_Binning/metaspades_maxbin/${SAMPLE_NAME}"
METASP_METABT_BINS="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/3_Binning/metaspades_metabat/${SAMPLE_NAME}"
N_METASP_MAXBIN_BINS="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/3_Binning/norm_metaspades_maxbin/${SAMPLE_NAME}"
N_METASP_METABT_BINS="/storage/home/hcoda1/0/skapasi3/r-ktk3-0/Girasoles-2/3_Binning/norm_metaspades_metabat/${SAMPLE_NAME}"

## Metaspades/Maxbin Combo
mkdir -p "$METASP_MAXBIN_BINS"
cd "$METASP_MAXBIN_BINS" || exit 0

echo "  Running Maxbin on Metaspades contig file ..."
echo "$METASP_COVERAGE_MX" >> abund_list
run_MaxBin.pl -contig "${METASP_CONTIGS_FILE}" -out "${METASP_MAXBIN_BINS}/out" -abund_list abund_list -min_contig_length 5000 -max_iteration 50 -prob_threshold 0.5  -markerset 107 
gzip -cd out.marker_of_each_bin.tar.gz | tar -xf -

## Norm Metaspades/Maxbin Combo
mkdir -p "$N_METASP_MAXBIN_BINS"
cd "$N_METASP_MAXBIN_BINS" || exit 0

echo "  Running Maxbin on Normalized Metaspades contig file ..."
echo "$N_METASP_COVERAGE_MX" >> abund_list
run_MaxBin.pl -contig "${N_METASP_CONTIGS_FILE}" -out "${N_METASP_MAXBIN_BINS}/out" -abund_list abund_list -min_contig_length 5000 -max_iteration 50 -prob_threshold 0.5  -markerset 107 
gzip -cd out.marker_of_each_bin.tar.gz | tar -xf -

## Metaspades/Metabat Combo
echo "  Running Metabat on Metaspades contig file ..."
mkdir -p "$METASP_METABT_BINS"
metabat2 --inFile "${METASP_CONTIGS_FILE}" --outFile "${METASP_METABT_BINS}/bin" --abdFile "${METASP_COVERAGE_MB}" --minContig 5000 --maxP 95 --minS 60 --maxEdges 200 --pTNF 0  --minCV 1.0 --minCVSum 1.0 --seed 0 --minClsSize 200000 > process_log_METASP.txt

## Norm Metaspades/Metabat Combo
echo "  Running Metabat on Normalized Metaspades contig file ..."
mkdir -p "$N_METASP_METABT_BINS"
metabat2 --inFile "${N_METASP_CONTIGS_FILE}" --outFile "${N_METASP_METABT_BINS}/bin" --abdFile "${N_METASP_COVERAGE_MB}" --minContig 5000 --maxP 95 --minS 60 --maxEdges 200 --pTNF 0  --minCV 1.0 --minCVSum 1.0 --seed 0 --minClsSize 200000 > process_log_N_METASP.txt

echo "Done with $SAMPLE_NAME"
