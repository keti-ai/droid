#!/bin/bash
set -euo pipefail

# Activate correct conda and ensure runtime can find conda libs first
if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
  source ~/miniconda3/etc/profile.d/conda.sh
elif [ -f ~/anaconda3/etc/profile.d/conda.sh ]; then
  source ~/anaconda3/etc/profile.d/conda.sh
fi
conda activate polymetis-local

export CONDA_PREFIX=${CONDA_PREFIX:-$HOME/miniconda3/envs/polymetis-local}
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"
export GXX=${GXX:-$CONDA_PREFIX/bin/x86_64-conda-linux-gnu-c++}

cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
python run_server.py
