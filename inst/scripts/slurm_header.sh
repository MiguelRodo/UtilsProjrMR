#!/bin/sh
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --job-name="<job>"
#SBATCH --mail-user=rdxmig002@myuct.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --partition=ada

date
echo "<job>"

date
