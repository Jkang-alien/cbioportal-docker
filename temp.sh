#!/bin/bash

# reference

# execute: user@device:directory# bash pipe.sh

## set multi_thread

## configure

## define program
program_vcf2maf=/home/molpath/mskcc-vcf2maf-decbf60/vcf2maf.pl

## define dir
dir_input=/home/molpath/Downloads/NGS_OCA/Variants/vcf
dir_temp=${dir_input}/temp
mkdir ${dir_temp}
dir_output=${dir_input}/vcf
mkdir ${dir_output}
dir_execute=${dir_output}

## input sample
cp ${dir_input}/*.vcf  ${dir_temp}
ls ${dir_temp}/*.vcf > ${dir_execute}/list_input_dir_files.txt

list_input_dir_files=()
i=0
while read -r line
do
    list_input_dir_files[i]=${line}
    let "i=i+1"
done < ${dir_execute}/list_input_dir_files.txt
echo ${i}

list_input_files=()
j=0
while (( ${j} < ${i} ))
do
    list_input_files[j]=${list_input_dir_files[j]##*/}
    let "j=j+1"
done
echo ${j}

list_sample_names=()
j=0
while (( ${j} < ${i} ))
do
    list_sample_names[j]=${list_input_files[j]%%_*}
    let "j=j+1"
done
echo ${j}



############################################################################################
####### execute by samples #######
j=0
while (( ${j} < ${i} ))
do
    echo "#################################################################"
    echo "##### "$(date)" : "$[${j}+1]"/"${i}" : "${list_sample_names[j]}" #####"
    perl ${program_vcf2maf} --input-vcf ${list_input_dir_files[j]} \
        --output-maf ${dir_output}/${list_sample_names[j]}.maf --tumor-id ${list_sample_names[j]}
    let "j=j+1"
done



##############################################################################################################
# remove unneeded files
rm ${dir_execute}/list_input_dir_files.txt
rm -rf ${dir_temp}

# save end time
time_end=$(date)

# end project
echo "###########################################################"
echo "###################### VCF to MAF ########################"
echo "##### start time: "$time_start" #####"
echo "##### end time: "$time_end" #####"
echo "##### All steps are finished. #####"


