#!/bin/bash
cd /home/ubuntu
touch iamWORKER
source dask_env/bin/activate
pip install "click>=7,<8"
#dask-scheduler tcp://<TCP_ADDR>:8786 --nprocs 4
