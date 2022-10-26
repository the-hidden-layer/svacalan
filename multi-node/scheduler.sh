#!/bin/bash
source dask_env/bin/activate
jupyter notebook --port=8888 > /dev/null 2>&1 & 
dask-scheduler --host 0.0.0.0
