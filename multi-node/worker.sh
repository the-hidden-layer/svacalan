#!/bin/bash
echo "Hello, World!" > test.txt # just a test.
source dask_env/bin/activate
pip install "click>=7,<8"
#dask-scheduler tcp://172.31.31.176:8786 --nprocs 4
