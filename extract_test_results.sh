#!/bin/bash

#
# Results will be extracted from raw output to results/{dataset_name}_{learner_type}/extracted_data
#
# Designed to be run by run_ande_tests.sh 

#conditionally set these variables for the results to be extracted  manually after running "run_ande_tests.sh" 
#otherwise they will be set by export variables in "run_ande_tests.sh" automatically

: ${dataset_name='localization'}
: ${learner_type='A3DE'}


#extracted results from this script will be stored in: results/${dataset_name}_${learner_type}/extracted_data
extracted_directory="results/${dataset_name}_${learner_type}/extracted_data"
mkdir -p "$extracted_directory"
extracted_directory="${extracted_directory}/"
extracted_results_file="${extracted_directory}extracted_results_${dataset_name}_${learner_type}.txt"

#the format for where the raw output results are stored already
output_directory="results/${dataset_name}_${learner_type}/raw_data/"
output_file_results="${output_directory}results_${learner_type}_${dataset_name}.txt"
output_file_memory="${output_directory}mem_output_${dataset_name}_${learner_type}.txt"
output_file_running_times="${output_directory}running_times_${dataset_name}_${learner_type}.txt"

#setup temp directory for storing temp columns of different results, deleted at end of script
temp_directory="results/${dataset_name}_${learner_type}/temp"
mkdir -p "$temp_directory"
temp_directory="${temp_directory}/"


#extract results for these learner variations
plain_=true
sketch_=true
lossy_ws_=true
lossy_sws_=true

#search for results of each learner variation
if [[ ! -e "$output_file_results" || `wc -l < $output_file_results | awk '{print $1}'` -le 10 ]]; then 
	plain_=false 
	echo "plain false"
fi
if [[ ! -e "${output_directory}results_${learner_type}_${dataset_name}_sketch.txt" || `wc -l < ${output_directory}results_${learner_type}_${dataset_name}_sketch.txt | awk '{print $1}'` -le 10 ]]; then 
	sketch_=false 
	echo "sketch false"
fi
if [[ ! -e "${output_directory}results_${learner_type}_${dataset_name}_lossy_ws.txt" || `wc -l < ${output_directory}results_${learner_type}_${dataset_name}_lossy_ws.txt | awk '{print $1}'` -le 10 ]]; then 
	lossy_ws_=false 
	echo "lossy ws false"
fi
if [[ ! -e "${output_directory}results_${learner_type}_${dataset_name}_lossy_sws.txt" || `wc -l < ${output_directory}results_${learner_type}_${dataset_name}_lossy_sws.txt | awk '{print $1}'` -le 10 ]]; then 
	lossy_sws_=false 
	echo "lossy sws false"
fi


#build up column names header
header_columns="Memory"
if [ "$sketch_" = true ]; then 
	header_columns="$header_columns\tMinSketch" 
fi
if [ "$plain_" = true ]; then 
	header_columns="$header_columns\tTrue-Counts" 
fi
if [ "$lossy_ws_" = true ]; then 
	header_columns="$header_columns\tLossy-MinSketch-WS" 
fi
if [ "$lossy_sws_" = true ]; then 
	header_columns="$header_columns\tLossy-MinSketch-SWS" 
fi

#setup the extracted results file with header of column names
#echo "Memory RMSE-${learner_type} RMSE-${learner_type}-sketch RMSE-${learner_type}-lossy-ws RMSE-${learner_type}-lossy-sws " > "$extracted_results_file"
echo -e "$header_columns" > "$extracted_results_file"



#get RMSE for plain learner_type, add to seperate temp column
if [ "$plain_" = true ]; then
	grep "RMSE All Classes:" "$output_file_results" | awk '{print $4;}' > "$temp_directory"temp_plain_rmse.txt
fi

#get the RMSEs for min sketch, add it as temp column
if [ "$sketch_" = true ]; then
	output_file_results="${output_directory}results_${learner_type}_${dataset_name}_sketch.txt"
	grep "RMSE All Classes:" "$output_file_results" | awk '{print $4;}' > "$temp_directory"temp_sketch_rmse.txt
	if [ "$plain_" = true ]; then
		echo "" | cat - "$temp_directory"temp_sketch_rmse.txt > temp && mv temp "$temp_directory"temp_sketch_rmse.txt
	fi
fi

#get the RMSEs for lossy ws, add it as temp column
if [ "$lossy_ws_" = true ]; then
	output_file_results="${output_directory}results_${learner_type}_${dataset_name}_lossy_ws.txt"
	grep "RMSE All Classes:" "$output_file_results" | awk '{print $4;}' >> "$temp_directory"temp_lossy_ws_rmse.txt
	if [ "$plain_" = true ]; then
		echo "" | cat - "$temp_directory"temp_lossy_ws_rmse.txt > temp && mv temp "$temp_directory"temp_lossy_ws_rmse.txt
	fi
fi

#get the RMSEs for lossy sws, add it as temp column
if [ "$lossy_sws_" = true ]; then
	output_file_results="${output_directory}results_${learner_type}_${dataset_name}_lossy_sws.txt"
	grep "RMSE All Classes:" "$output_file_results" | awk '{print $4;}' >> "$temp_directory"temp_lossy_sws_rmse.txt
	if [ "$plain_" = true ]; then
		echo "" | cat - "$temp_directory"temp_lossy_sws_rmse.txt > temp && mv temp "$temp_directory"temp_lossy_sws_rmse.txt
	fi
fi



#get the memory values for the learner types that ran
memory_file_created=false
if [ "$plain_" = true ]; then 
	grep "memusg: peak =" "$output_file_memory" | awk '{print $4;exit}' > "$temp_directory"temp_memory.txt
	memory_file_created=true
fi

#get the number of sketch widths used, add all the corresponding memory values to temp memory column
if [ "$sketch_" = true ]; then 
	noSketchWidths=`wc -l < "$temp_directory"temp_sketch_rmse.txt | awk '{print $1}'`
elif [ "$lossy_ws_" = true ]; then 
	noSketchWidths=`wc -l < "$temp_directory"temp_lossy_ws_rmse.txt | awk '{print $1}'`
elif [ "$lossy_sws_" = true ]; then 
	noSketchWidths=`wc -l < "$temp_directory"temp_lossy_sws_rmse.txt | awk '{print $1}'`
fi

if [[ "$sketch_" = true || "$lossy_ws_" = true || "$lossy_sws_" = true ]]; then
	if [ "$memory_file_created" = true ]; then
		grep "memusg: peak =" "$output_file_memory" | awk -v noWidths="$noSketchWidths" 'NR > 1 && NR < noWidths+1 {print $4;}' >> "$temp_directory"temp_memory.txt
	else
		grep "memusg: peak =" "$output_file_memory" | awk -v noWidths="$noSketchWidths" 'NR > 1 && NR < noWidths+1 {print $4;}' > "$temp_directory"temp_memory.txt
	fi
fi



#build up paste command
paste_command="${temp_directory}temp_memory.txt"
if [ "$sketch_" = true ]; then 
	paste_command+=" ${temp_directory}temp_sketch_rmse.txt" 
fi
if [ "$plain_" = true ]; then 
	paste_command+=" ${temp_directory}temp_plain_rmse.txt" 
fi
if [ "$lossy_ws_" = true ]; then 
	paste_command+=" ${temp_directory}temp_lossy_ws_rmse.txt" 
fi
if [ "$lossy_sws_" = true ]; then 
	paste_command+=" ${temp_directory}temp_lossy_sws_rmse.txt" 
fi

#concatenate all the temp table columns together in one file
#paste "$temp_directory"temp_memory.txt "$temp_directory"temp_plain_rmse.txt "$temp_directory"temp_sketch_rmse.txt "$temp_directory"temp_lossy_ws_rmse.txt "$temp_directory"temp_lossy_sws_rmse.txt >> "$extracted_results_file"
paste $paste_command >> "$extracted_results_file"


#remove temp directory and its files
rm -rf "$temp_directory"

#run R script to graph results
Rscript graph-results.R
