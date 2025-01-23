#!/bin/bash

for sample in data/*/; do
	./run_sample.sh $sample
done
