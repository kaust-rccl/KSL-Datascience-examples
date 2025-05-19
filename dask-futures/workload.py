from dask.distributed import Client,as_completed
import os,time, subprocess as sb
import numpy as np
import argparse


parser = argparse.ArgumentParser(description='Dask Futures example.')
parser.add_argument('-t','--tasks', 
                    type=int, default=1000,
                    help='Total number of tasks ')
args = parser.parse_args()

client = Client(scheduler_file='scheduler.json')  # start local workers as processes


    
def func(matrix_size):
    matrix_a = np.random.rand(matrix_size, matrix_size).astype(np.float64) # Use float64 for more accurate timing
    matrix_b = np.random.rand(matrix_size, matrix_size).astype(np.float64)
    # Check if matrices can be multiplied
    if matrix_a.shape[1] != matrix_b.shape[0]:
        print("Error: Matrices are not compatible for multiplication.")
        return None

    # Get dimensions
    rows_a = matrix_a.shape[0]
    cols_a = matrix_a.shape[1]  # Also the number of rows in matrix_b
    cols_b = matrix_b.shape[1]

    # Create an empty result matrix
    result_matrix = np.zeros((rows_a, cols_b), dtype=matrix_a.dtype) # Ensure correct dtype

    # Perform matrix multiplication with explicit loops
    for i in range(rows_a):
        for j in range(cols_b):
            for k in range(cols_a):
                # This is the core of the matrix multiplication.
                # We're doing it element by element.
                result_matrix[i, j] += matrix_a[i, k] * matrix_b[k, j]
    return "Done"

print(f"Total tasks:  {args.tasks}")
x=np.random.randint(low=450,high=512,size=args.tasks).tolist()

#futures=client.map(func,x)
futures=list()
for i in range(len(x)):
    futures.append(client.submit(func,x[i]))
 
print(f"Total of {len(futures)} futures launched.")
for future in as_completed(futures):
    print('result: ',future.result())

client.close()

    
    


   
    