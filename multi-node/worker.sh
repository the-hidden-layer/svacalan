#!/bin/bash
cd /home/ubuntu
echo "i am worker" > id.txt
source dask_env/bin/activate
#dask-worker tcp://172.31.31.176:8786 --nprocs 4
