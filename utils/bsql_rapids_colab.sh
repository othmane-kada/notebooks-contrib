#!/bin/bash

set -eu

RAPIDS_VERSION="${1:-0.10}"

wget -nc https://github.com/gumdropsteve/bsql-demos/raw/feature/utils/utils/colab_env.py
echo "Checking for GPU type:"
python colab_env.py

if [ ! -f Miniconda3-4.5.4-Linux-x86_64.sh ]; then
    echo "Removing conflicting packages, will replace with BlazingSQL and RAPIDS compatible versions"
    # remove existing xgboost and dask installs
    pip uninstall -y xgboost dask distributed

    # intall miniconda
    echo "Installing conda"
    wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh
    chmod +x Miniconda3-4.5.4-Linux-x86_64.sh
    bash ./Miniconda3-4.5.4-Linux-x86_64.sh -b -f -p /usr/local
    
    echo "Installing BlazingSQL and RAPIDS $RAPIDS_VERSION packages from the stable release channel"
    echo "Please standby, this will take a few minutes..."
    # install RAPIDS packages
    conda install -y --prefix /usr/local \
        -c rapidsai/label/xgboost -c rapidsai -c nvidia -c conda-forge \
        -c blazingsql/label/cuda10.0 -c blazingsql -c defaults \
        cudatoolkit=10.1 \
        cudf=$RAPIDS_VERSION cuml cugraph gcsfs pynvml \
        dask-cudf \
        xgboost \
        blazingsql-calcite blazingsql-orchestrator blazingsql-ral blazingsql-python
    
    pip install flatbuffers
    
      
    echo "Copying shared object files to /usr/lib"
    # copy .so files to /usr/lib, where Colab's Python looks for libs
    cp /usr/local/lib/libcudf.so /usr/lib/libcudf.so
    cp /usr/local/lib/librmm.so /usr/lib/librmm.so
    cp /usr/local/lib/libnccl.so /usr/lib/libnccl.so
fi

echo ""
echo "********************************************************"
echo "Your Google Colab instance is BlazingSQL + RAPIDS ready!"
echo "********************************************************"
