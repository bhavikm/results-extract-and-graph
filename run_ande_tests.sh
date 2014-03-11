#!/bin/bash

###### USAGE ######
#
#  ./run_ande_tests.sh DATASET LEARNER_TYPE [plain] [sketch] [lossy_ws] [lossy_sws]
#  
#  DATASET must be name of folder containing data and prefix of .pmeta and .pdata files
#  LEARNER_TYPE is type of learner to run experiments on, AODE, A2DE, A3DE etc
#  provide types of learner variations to run, if none provided all will be run
#
#  example usage:
#  ./run_ande_tests.sh poker-hand A2DE plain sketch
#
#  Results will be output to results/{dataset_name}_{learner_type}/raw_data
#
###################

if [ $# < 2 ]
  then
    echo "Usage is: ./run_ande_tests.sh DATASET LEARNER_TYPE [plain] [sketch] [lossy_ws] [lossy_sws]"
    exit
else
  if [ -d "$1" ]
    then
      dataset_name="$1"
    else
      echo "DATASET folder doesn't exist"
      exit
  fi
  if [[ $2 = "AODE" || $2 = "A2DE" || $2 = "A3DE" || $2 = "A4DE" || $2 = "A5DE" ]]
    then
      learner_type="$2"
    else
      echo "LEARNER_TYPE not valid"
      exit
  fi
fi

#run these learner variations
plain_=true
sketch_=true
lossy_ws_=true
lossy_sws_=true

export dataset_name
export learner_type

output_directory="results/${dataset_name}_${learner_type}/raw_data"
mkdir -p "$output_directory"
output_directory="${output_directory}/"

output_file_results="${output_directory}results_${learner_type}_${dataset_name}.txt"
output_file_memory="${output_directory}mem_output_${dataset_name}_${learner_type}.txt"
output_file_running_times="${output_directory}running_times_${dataset_name}_${learner_type}.txt"

export output_file_memory
export output_file_running_times

#set sketch widths to be used by sketch variations of learner

#sketchWidths=( 500 1000 2000 3000 6000 9000 12000 15000 20000 25000 30000 35000 40000 45000 50000 60000 83000 100000 120000 160000 200000 ) # widths for AODE
#sketchWidths=( 5000000 750000 1000000 1250000 2500000 5000000 7500000 10000000 15000000 20000000 27125000 31700000 62500000 ) # widths for A2DE
#sketchWidths=( 20000 30000 40000 50000 60000 70000 80000 90000 100000 ) #poker hand a2de
#sketchWidths=( 25000 50000 100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000  ) #localization a2de
#sketchWidths=( 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1250000 1500000 1750000 2000000 ) #localization a3de
#sketchWidths=( 100000000 200000000 400000000 800000000 1200000000 1600000000 ) # widths for A3DE
#sketchWidths=( 100000000 200000000 300000000 400000000 500000000 600000000 700000000 800000000 ) # widths for A3DE covtype
#sketchWidths=( 2500000 5000000 10000000 15000000 20000000 2500000 30000000 35000000 40000000 ) #widths for A4DE poker-hand dataset
#sketchWidths=( 100 200 300 400 500 700 1000 2000 3000 6000 9000 12000 15000 20000 ) #a1de poker hand
#sketchWidths=( 10000 20000 40000 60000 80000 100000 150000 200000 250000 300000 ) #a3de donation
sketchWidths=( 2000 5000 7000 10000 15000 20000 25000 30000 35000 40000 45000 50000 60000 70000 80000 90000 100000 ) #a1de localization


dataset_metafile_path="${dataset_name}/${dataset_name}_mdl.pmeta"
dataset_data_path="${dataset_name}/${dataset_name}_mdl.pdata"

tLen=${#sketchWidths[@]}

#for linux installation to link madoka library, 
#export LD_LIBRARY_PATH=madoka/lib/.libs/

#clear the output files
echo "" > "$output_file_results"
echo "" > "$output_file_memory"
echo "" > "$output_file_running_times"




if [ "$plain_" = true ]; then 
  ############### first experiment - plain AnDE #################################
  echo "${learner_type} plain - ${dataset_name}" >> "$output_file_memory"
  echo "${learner_type} plain - ${dataset_name}" >> "$output_file_running_times"
  echo "Running normal ${learner_type} - ${dataset_name} dataset"

  ./memusg ./petal "$dataset_metafile_path" "$dataset_data_path" -x2 -v2 -l"$learner_type" >> "$output_file_results"
  echo "" >> "$output_file_results"
  ###############################################################################
fi


if [ "$sketch_" = true ]; then 
  ############### second experiment - sketch AnDE #############################
  echo "" >> "$output_file_memory"
  echo "" >> "$output_file_running_times"
  echo "${learner_type} MIN SKETCH - ${dataset_name}" >> "$output_file_memory"
  echo "${learner_type} MIN SKETCH - ${dataset_name}" >> "$output_file_running_times"
  echo "Starting min sketch experiments for ${learner_type} - ${dataset_name} dataset"
  output_file_results="${output_directory}results_${learner_type}_${dataset_name}_sketch.txt"

  # run AnDE with Min Sketch for all sketch widths
  for (( i=0; i<${tLen}; i++ ));
  do
    echo "sketch width = ${sketchWidths[$i]}" >> "$output_file_memory"
    echo "sketch width = ${sketchWidths[$i]}" >> "$output_file_running_times"
    j=`expr $i + 1`
    echo "Running petal experiment, ${learner_type} min sketch, $j of ${tLen}"
    ./memusg ./petal "$dataset_metafile_path" "$dataset_data_path" -x2 -v2 -l"$learner_type"_SKETCH -w${sketchWidths[$i]} >> "$output_file_results"
    echo "" >> "$output_file_results"
  done
  ###############################################################################
fi

if [ "$lossy_ws_" = true ]; then 
  ############### third experiment - lossy sketch WS AnDE ###################
  echo "" >> "$output_file_memory"
  echo "" >> "$output_file_running_times"
  echo "${learner_type} LOSSY WS - ${dataset_name}" >> "$output_file_memory"
  echo "${learner_type} LOSSY WS - ${dataset_name}" >> "$output_file_running_times"

  output_file_results="${output_directory}results_${learner_type}_${dataset_name}_lossy_ws.txt"

  echo "Starting lossy-ws experiments for ${learner_type} - ${dataset_name} dataset"

  # run AnDE with Min Sketch for all sketch widths
  for (( i=0; i<${tLen}; i++ ));
  do
    echo "sketch width = ${sketchWidths[$i]}" >> "$output_file_memory"
    echo "sketch width = ${sketchWidths[$i]}" >> "$output_file_running_times"
    j=`expr $i + 1`
    echo "Running petal experiment, ${learner_type} lossy ws, $j of ${tLen}"
    ./memusg ./petal "$dataset_metafile_path" "$dataset_data_path" -x2 -v2 -l"$learner_type"_LOSSY -lcu_ws -w${sketchWidths[$i]} >> "$output_file_results"
    echo "" >> "$output_file_results"
  done
###############################################################################
fi


if [ "$lossy_sws_" = true ]; then 
  ############### fourth experiment - lossy sketch SWS AnDE ###################
  echo "" >> "$output_file_memory"
  echo "" >> "$output_file_running_times"
  echo "${learner_type} LOSSY SWS - ${dataset_name}" >> "$output_file_memory"
  echo "${learner_type} LOSSY SWS - ${dataset_name}" >> "$output_file_running_times"

  output_file_results="${output_directory}results_${learner_type}_${dataset_name}_lossy_sws.txt"

  echo "Starting lossy-sws experiments for ${learner_type} - ${dataset_name} dataset"

  # run AnDE with Min Sketch for all sketch widths
  for (( i=0; i<${tLen}; i++ ));
  do
    echo "sketch width = ${sketchWidths[$i]}" >> "$output_file_memory"
    echo "sketch width = ${sketchWidths[$i]}" >> "$output_file_running_times"
    j=`expr $i + 1`
    echo "Running petal experiment, ${learner_type} lossy sws, $j of ${tLen}"
    ./memusg ./petal "$dataset_metafile_path" "$dataset_data_path" -x2 -v2 -l"$learner_type"_LOSSY -lcu_sws -w${sketchWidths[$i]} >> "$output_file_results"
    echo "" >> "$output_file_results"
  done
  ###############################################################################
fi

bash extract_test_results.sh
