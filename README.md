# Replication code for RNA-seq analysis of OVCAR3 cells treated with Atovaquone

## Step 1: Downloading raw data 

Gene Expression Omnibus accession numbers are pending (as of 23 January, 2025).

In addition, the raw data files will be available on Code Ocean, which promises a reproducible environment to ensure consistent results. 
Although we have not yet tested it (as of 23 January, 2025), and, hence, do not yet make it available.

## Step 2: Obtaining expression estimates

We used RSEM (v1.3.3) with the STAR aligner (v2.7.11) to obtain estimates of the expression per gene per sample - ensure these are installed by following the instructions at https://github.com/deweylab/RSEM and https://github.com/alexdobin/STAR, respectively.

For our reference genome, we used the Ensembl GRCh38 assembly release 112. You can download this source and prepare it as a reference for RSEM as shown in `prepare-reference.sh`.

Next, we run `rsem-calculate-expression` on the fq.gz files for each sample, using the reference we just constructed, to obtain expression estimates for each gene in each sample.
These results are aggregated using `rsem-generate-data-matrix`, and the output of that is processed in `colname-fixer.R` to tidy up the column names.

The results of these steps are saved in `expression.mat`.

## Step 3: Performing DE analysis/GSEA

Differential Expression analysis was performed using *DESeq2*, and the results of this analysis were used to perform GSEA using *pathfindR*.
Details of these analyses can be found in `generate-results.Rmd`, which also contains the code needed to recreate the plots from the paper.

