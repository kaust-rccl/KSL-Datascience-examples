#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=192
#SBATCH --partition=workq
#SBATCH --hint=nomultithread
#SBATCH --time=01:00:00

module load python

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
mkdir workers${SLURM_JOBID}


srun -n ${SLURM_NTASKS} -c ${SLURM_CPUS_PER_TASK} -u --hint=nomultithread --cpu-bind=cores dask worker --scheduler-file=scheduler.json --interface=hsn0 --nworkers=${SLURM_CPUS_PER_TASK} --nthreads=1
