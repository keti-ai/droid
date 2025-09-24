#!/bin/bash
set -euo pipefail

# Activate correct conda and ensure runtime can find conda libs first
if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
  source ~/miniconda3/etc/profile.d/conda.sh
elif [ -f ~/anaconda3/etc/profile.d/conda.sh ]; then
  source ~/anaconda3/etc/profile.d/conda.sh
fi
# Some conda activation scripts (gxx) expect GXX to be set when -u is enabled
export GXX=${GXX:-$HOME/miniconda3/envs/polymetis-local/bin/x86_64-conda-linux-gnu-c++}
conda activate polymetis-local

export CONDA_PREFIX=${CONDA_PREFIX:-$HOME/miniconda3/envs/polymetis-local}
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:$LD_LIBRARY_PATH"

cd $( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
python run_server.py
