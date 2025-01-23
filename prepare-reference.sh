#!/bin/bash

wget ftp://ftp.ensembl.org/pub/release-112/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget ftp://ftp.ensembl.org/pub/release-112/gtf/homo_sapiens/Homo_sapiens.GRCh38.112.gtf.gz

gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.112.gtf.gz

RSEM/rsem-prepare-reference --gtf Homo_sapiens.GRCh38.112.gtf \
		       --star \
			--star-path STAR/source \
			-p 16 \
		       Homo_sapiens.GRCh38.dna.primary_assembly.fa \
		       ref/human_ensembl

gzip Homo_sapiens.GRCh38.dna.primary_assembly.fa
gzip Homo_sapiens.GRCh38.112.gtf
