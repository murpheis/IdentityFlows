#!/bin/bash
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --mail-user=emily.eisner@berkeley.edu
#SBATCH --nodes=1 --cpus-per-task=8

stata-mp -b cleanCPS_00003.do  cleanCPS_00003.log
