results-extract-and-graph
=========================

Example of bash shell scripts that run a command line program that outputs results, then extract results from raw output and graph results in R

Requires R to be installed on command line

To use:

git clone https://github.com/bhavikm/results-extract-and-graph
cd results-extract-and-graph
chmod a+x *.sh
./extract_test_results.sh

This will extract results from the example results directory, then use the R script to produce PDF graph of these extracted results

