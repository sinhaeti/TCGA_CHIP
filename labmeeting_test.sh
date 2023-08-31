#!/bin/bash

#SBATCH --job-name=Test_Script
#SBATCH --partition=panda_physbio
#SBATCH --begin=now
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=4G
#SBATCH --time=1-00:00:00
#SBATCH --exclude=node002.panda.pbtech,node007.panda.pbtech,node010.panda.pbtech

echo "test!"  > test.txt