#!/bin/bash
#SBATCH --partition=GPUQ
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

singularity exec pbrt.sif ./render_cube.sh $1 $2 $3 $4
