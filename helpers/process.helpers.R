library(parallel)
library(pagoda2)
library(Seurat)
#library(ElPiGraph.R)
library(dplyr)
library(reticulate)
library(grid)
library(gridExtra)
library(dendextend)
#library(dynplot)
library(quadprog)
library(loomR)


library(mgcv)
library(pbapply)


library(crestree)


library(ggpubr)
library(rdist)

#source("_helpers/dynwrap.helpers.R")


pc.select <- function(p2,plt=F,elbow=T){
  
  x <- cbind(1:length(p2$misc$PCA$d), p2$misc$PCA$d)
  line <- x[c(1, nrow(x)),]
  proj <- princurve::project_to_curve(x, line)
  return(which.max(proj$dist_ind))
  
}

doUMAP <- function(PCA,n_neighbors,min_dist,max_dim=2,seed.use=42){
  require(reticulate)
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
    py_set_seed(seed = seed.use)
  }
  umap_import <- import(module = "umap", delay_load = TRUE)
  umap <- umap_import$UMAP(n_neighbors = as.integer(x = n_neighbors), 
                           n_components = as.integer(x = max_dim), metric = "correlation", 
                           min_dist = min_dist)
  
  umap_output <- umap$fit_transform(as.matrix(x = PCA))
  rownames(umap_output)=rownames(PCA)
  colnames(umap_output)=paste0("UMAP",1:max_dim)
  
  return(umap_output)
}


doPalantir <- function(PCA,n_neighbors,min_dist,n_eig=NULL,seed.use=42){
  library(reticulate)
  
  palantir=import("palantir")
  pd=import("pandas")
  umap=import("umap")
  
  pca_py=pd$DataFrame(r_to_py(PCA))
  cat("Runing diffusion maps... ")
  dm_res=palantir$utils$run_diffusion_maps(pca_py)
  cat("done\n")
  if (!is.null(n_eig)){
    ms_data = palantir$utils$determine_multiscale_space(dm_res,n_eigs=as.integer(n_eig))
  } else {
    ms_data = palantir$utils$determine_multiscale_space(dm_res)
  }
  
  ms_data=as.matrix(ms_data);
  rownames(ms_data)=rownames(PCA);colnames(ms_data)=paste0("Dim",1:ncol(ms_data))
  
  
  set.seed(seed = seed.use)
  py_set_seed(seed = seed.use)
  
  cat("Runing UMAP... ")
  
  fit=umap$UMAP(n_neighbors=as.integer(n_neighbors),min_dist=min_dist)
  u=fit$fit_transform(ms_data)
  
  cat("done\n")
  
  rownames(u)=rownames(ms_data)
  return(list(ms_data=ms_data,umap=u))
}


p2.wrapper <- function(counts,n_neighbors=30,min_dist=.3,npcs=100,pcsel=T,k=20,...) {
  rownames(counts) <- make.unique(rownames(counts))
  p2 <- Pagoda2$new(counts,n.cores=parallel::detectCores()/2,...)
  p2$adjustVariance(plot=T,gam.k=10)
  p2$calculatePcaReduction(nPcs=npcs,n.odgenes=NULL,maxit=1000)
  
  if (pcsel){
    opt=pc.select(p2);cat(paste0(opt," PCs retained\n"))
    p2$reductions$PCA=p2$reductions$PCA[,1:opt]
  }
  
  cat("Computing UMAP... ")
  p2$embeddings$PCA$UMAP=doUMAP(p2$reductions$PCA,n_neighbors,min_dist)
  
  cat("done\n")
  p2$makeKnnGraph(k=k,type='PCA',center=T,distance='cosine');
  p2$getKnnClusters(method=conos::leiden.community,type='PCA',name = "leiden")
  invisible(p2)
}


p2w.wrapper <- function(p2,app.title = 'Pagoda2', extraWebMetadata = NULL, n.cores = 4) {
  cat('Calculating hdea...\n')
  hdea <- p2$getHierarchicalDiffExpressionAspects(type='PCA',clusterName='leiden',z.threshold=3, n.cores = n.cores)
  metadata.forweb <- list();
  metadata.forweb$leiden <- p2.metadata.from.factor(p2$clusters$PCA$leiden,displayname='leiden')
  metadata.forweb <- c(metadata.forweb, extraWebMetadata)
  genesets <- hierDiffToGenesets(hdea)
  appmetadata = list(apptitle=app.title)
  cat('Making KNN graph...\n')
  p2$makeGeneKnnGraph(n.cores=n.cores)
  make.p2.app(p2, additionalMetadata = metadata.forweb, geneSets = genesets, dendrogramCellGroups = p2$clusters$PCA$leiden, show.clusters=F, appmetadata = appmetadata)
}


