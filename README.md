# SgnFates_paper

Code for reproducibiliy

## Main requirements 

### R

* SingleCellExperiment 1.6.0
* scater 1.12.2 
* pagoda2 0.1.1
* scde 2.12.0 
* CellChat 0.0.2

### python

* anndata2ri 1.0.1
* scanpy 1.6.0
* palantir 0.2.1
* harmony 0.1.1
* scFates 0.1
* cellphonedb 2.1.2

## Logic of the analysis

1. [QC and preprocessing](01.Preprocessing.md) of raw count matrices in R using pagoda2 R package. 
2. [SCENIC](02.SCENIC_Analysis.md) transcription factor analysis.
3. [Initial plots and DE](02.SCENIC_Analysis.md) using scanpy python package.
4. [Linear pseudotime analysis](04.Pseudotime_Linear.ipynb) using scanpy scFates 0.1 python package.
5. [Bifurcations analysis](05.Pseudotime_Bifurcations.ipynb) using scanpy scFates 0.1 python package.
6. [Cell communication analysis (1)](06.cellphonedb.md) using cellphonedb R package.
7. [Cell communication analysis (2)](07.CellChat.md) using CellChat R package.
8. [Deafness genes](08.Deafness.ipynb) plots using scanpy python package.
9. [Supplementary](09.Make_supplementaryData.ipynb) data generation.