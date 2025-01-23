#!/bin/bash

SAMPLE=$(basename $1)

mkdir ${SAMPLE}_out
mkdir ${SAMPLE}_out/out

RSEM/rsem-calculate-expression --star \
	--star-path STAR/source \
	--paired-end \
	--no-bam-output \
	--star-gzipped-read-file \
	-p 16 \
	data/${SAMPLE}_1.fq.gz \
	data/${SAMPLE}_2.fq.gz \
	../spatial-test/data/genome/human_genome \
	${SAMPLE}_out/out
	
