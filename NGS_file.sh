#!/bin/bash

# reference

# execute: user@device:directory# bash pipe.sh

## set multi_thread

## configure

## define dir
dir_input=/home/molpath/Downloads/NGS_OCA
dir_output=${dir_input}/vcf
mkdir ${dir_output}
dir_execute=${dir_output}

## Change permisstion mode
chmod -R 777 ${dir_input}

## input sample
ls ${dir_input}/*.zip > ${dir_execute}/list_input_dir_files.txt
 
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
    unzip -d ${dir_output} ${input_dir}/${list_input_files[j]}
    let "j=j+1"
done
echo ${j}


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

dir_input=/home/molpath/Downloads/NGS_OCA/Variants
dir_output_vcf=${dir_input}/vcf
mkdir ${dir_output_vcf}/
find ${dir_input} -name '*.vcf'-exec mv -t ${dir_output_vcf} {} +


dir_input=/home/molpath/Downloads/NGS_OCA/Variants
dir_output_tsv=${dir_input}/tsv
mkdir ${dir_output_tsv}/
find ${dir_input} -name '*oncomine.tsv' -exec mv -t ${dir_output_tsv} {} +

