#!/bin/bash
cd /home/ubuntu
echo "i am scheduler" > id.txt
source dask_env/bin/activate
pip install "click>=7,<8"
jupyter notebook --port=8888 > /dev/null 2>&1 & 
dask-scheduler --host 0.0.0.0 &
DASK_SCHEDULER_ADDR=`cat /var/log/cloud-init-output.log | grep Scheduler | sed -n -e 's/^.*tcp:/tcp:/p'`
