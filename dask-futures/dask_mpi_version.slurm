#!/bin/bash -l 
#SBATCH --time=01:0:0
#SBATCH --ntasks=32
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=48
#SBATCH --hint=nomultithread
#SBATCH --mem=376G
#SBATCH --job-name=dask_batch

module load python

export LC_ALL=C.UTF-8
export LANG=C.UTF-8



# setup ssh tunneling
# get tunneling info
node=$(hostname -s)
user=$(whoami)
submit_host=${SLURM_SUBMIT_HOST}
dashboard_port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
sched_port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')



srun -c $SLURM_CPUS_PER_TASK -n $SLURM_NTASKS -N ${SLURM_NNODES} \
--cpu-bind=cores --hint=nomultithread \
dask-mpi  --nthreads ${SLURM_CPUS_PER_TASK} \
		--memory-limit="94GiB" \
		--local-directory=${PWD}/workers${SLURM_JOBID} \
		--scheduler-file=scheduler_${SLURM_JOBID}.json --interface=hsn0 \
		--scheduler-port=${sched_port} --dashboard-address=${dashboard_port} \
		--worker-class distributed.Worker &


echo "
To connect to the Dask Dashboard, copy the following line and paste in new termial, then using URL in a browser : localhost:10001 

ssh -L ${dashboard_port}:${node}:${dashboard_port} ${user}@${submit_host}.hpc.kaust.edu.sa
"


sleep 10
time -p  python dask_futures_matmul.py -p 10000 --min 8192 --max 16384

