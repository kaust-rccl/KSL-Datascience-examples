#!/bin/bash -l
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=shared
#SBATCH --time=01:00:00
#SBATCH --hint=nomultithread

module load python

NUM_WORKERS=4
WORKER_JOB_PREFIX=test_workers
export EXP_NAME=experiment_${SLURM_JOBID}

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# get tunneling info
export XDG_RUNTIME_DIR=""
node=$(hostname -s)
user=$(whoami)
submit_host=${SLURM_SUBMIT_HOST}

sched_port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
dask_dashboard=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

if [ -f 'scheduler.json' ]; then
    rm scheduler.json
fi

srun -u --hint=nomultithread -n ${SLURM_NTASKS} -N ${SLURM_NNODES} -c ${SLURM_CPUS_PER_TASK} \
dask scheduler --scheduler-file=scheduler.json \
--dashboard-address=${node}:${dask_dashboard} --port=${sched_port} \
 --interface=hsn0 &

echo -e "


1. Command to create ssh tunnel from you workstation/laptop to cdlX:
ssh -L 8787:${node}:${dask_dashboard} ${user}@${submit_host}.hpc.kaust.edu.sa

"

while [ ! -f 'scheduler.json' ] ;
do
    sleep 4
    echo "Waiting for dask scheduler to start"
done

for ((i=1; i< $((NUM_WORKERS + 1)); i++))
    do
            sbatch -J ${WORKER_JOB_PREFIX}  worker.slurm
done

sleep 30
echo "Workload will start shortly"

python workload.py --tasks 10000

scancel -n ${WORKER_JOB_PREFIX}
exit 0
wait
