#!/bin/sh
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --job-name="<job>"
#SBATCH --mail-user=rdxmig002@myuct.ac.za
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --partition=ada

# find-and-replace <job> for job name and <rmd> for run

date
echo "<job>"

# - select the top one to preview a bookdown chapter
# - select the second to run a bookdown chapter as a single Rmd 
# and remove pandoc=FALSE if you want to actual create the HTML
# - to build the whole project or do anything else, 
# just replace the code after sourcing .Rprofile with what you want
# singularity exec $sif/ar422.sif Rscript -e "source('.Rprofile'); bookdown::preview_chapter('<rmd>.Rmd')"
# singularity exec $sif/ar422.sif Rscript -e "source('.Rprofile'); rmarkdown::render('<rmd>.Rmd', output_file = projr::projr_path_get_dir('cache', 'pipeline-expr.html'), run_pandoc = FALSE)"

date
