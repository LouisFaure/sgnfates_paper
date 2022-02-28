# SGN fates paper code reproducibility
[![Line count](https://raw.githubusercontent.com/LouisFaure/sgnfates_paper/linecount/badge.svg)](https://github.com/LouisFaure/sgnfates_paper/actions/workflows/linecount.yml)
![DOI](https://img.shields.io/badge/DOI-unpublished-red)

## Required packages

Using conda environment, the following code should be run:

	conda create -n sgnfates -c defaults python=3.8 -y
	conda activate sgnfates
	pip install scanpy scFates harmonyTS rpy2

Then install the following package in an R session:

	install.packages('mgcv')
