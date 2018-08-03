#!/bin/bash

# wait for host to be ready
./wait

# run script
Rscript --vanilla main.R
