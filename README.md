# SGN fates paper code reproducibility
[![Line count](https://raw.githubusercontent.com/LouisFaure/sgnfates_paper/linecount/badge.svg)](https://github.com/LouisFaure/sgnfates_paper/actions/workflows/linecount.yml)
![DOI](https://img.shields.io/badge/DOI-unpublished-red)

## Required packages

Using conda environment, the following code should be run:

	conda create -n sgnfates -c conda-forge -c r python=3.8 r-mgcv rpy2 -y
	conda activate sgnfates
	pip install scFates harmonyTS
	pip install git+https://github.com/LouisFaure/anndata2pagoda
