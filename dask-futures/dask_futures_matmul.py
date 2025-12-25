import os,time
import dask
from dask.distributed import Client,as_completed
import numpy as np, argparse

parser = argparse.ArgumentParser()
parser.add_argument("--min", help="min size",
                type=int,default=512)
parser.add_argument("--max", help="max size",
                type=int,default=2048) 
parser.add_argument("-p", help="Number of kernels to launch",
                type=int,default=10000) 
args = parser.parse_args()

os.environ['OMP_NUM_THREADS']=os.environ['SLURM_CPUS_PER_TASK']

job_id=os.environ['SLURM_JOBID']
client=Client(scheduler_file='scheduler_%s.json'%job_id)
print(client)

def compute_kernel(m,n):
    matrix=np.random.randint(low=1, high=9, size=[m,n], dtype=int)
    vector=np.random.randint(low=1, high=9, size=[n,1], dtype=int)
    result=np.matmul(matrix,vector)

m_list=list()
n_list=list()
for i in range(args.p):
    m_list.append(np.random.randint(args.min,args.max))
    n_list.append(np.random.randint(args.min,args.max))

futures=list()
for i in range(args.p):
    futures.append(client.submit(compute_kernel,m_list[i],n_list[i]))

for future in as_completed(futures):
    print(future.status)





