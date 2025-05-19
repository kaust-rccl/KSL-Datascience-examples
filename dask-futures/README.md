# Dask futures test for Shaheen III

In this example each future consists of a matrix vector multiplication task. We launch 10000 tasks (this is a command line argument of workload.py). 

The output should print the results of future as "Done" which is the returned value by every future. 

Here is how to submit:

``sbatch scheduler.slurm``

or 
change the NUM_WORKERS to a larger number of submit the scheduler job
``sbatch scheduler.slurm``

The scheduler job runs on shared partition with modest CPU and memory resources. 
The worker jobs run on ``workq``
