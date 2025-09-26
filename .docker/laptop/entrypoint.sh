#!/bin/bash

# activate conda
source ~/miniconda3/bin/activate robot

# run user command
exec "$@"
