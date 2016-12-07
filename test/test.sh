#!/bin/bash
#set -x

# These variables correspond to the inputs and parameter ids from the apps.json file. 
# The API will pass the actual values into this script prior to execution.
INPUT=${input1} 

# Conditional create an input/output directory in the local scratch folder
if [ ! -d input ]; then mkdir input; fi
if [ ! -d output ]; then mkdir output; fi

# These variables correspond to the inputs and parameter ids from the apps.json file. 
# The API will pass the actual values into this script prior to execution.
INPUT1=~/lus/input1.qiime
INPUT2=~/lus/input2.qiime
INPUT3=~/lus/input3.qiime

# Conditional create an input/output directory in the local scratch folder
if [ ! -d input ]; then mkdir input; fi
if [ ! -d output ]; then mkdir output; fi

# Copy from source directory to the input directory
cp $INPUT1 input/
cp $INPUT2 input/
cp $INPUT3 input/

# Figure out the filename that has been copied into input/
# Here, I use a clever trick for grabbing the last field of any slash-delim path - it's similar in 
# function to basename, but is a simple string operation rather than a system call. It can therefore
# work on URLs as well as iRODS paths and local filesystem paths.
#
# See http://tldp.org/LDP/LGNET/18/bash.html for more cool stuff like this.
#
FILENAME1=${INPUT1##*/} 
FILENAME2=${INPUT2##*/} 
FILENAME3=${INPUT3##*/}


# Check for existence of input files...
if [[ -e input/$FILENAME1 && -e input/$FILENAME2 && -e input/$FILENAME3 ]]; then
        echo "files found"
        module load bioinfo/qiime/1.9.1	

        #TODO: have script check for the output of this and kill the process if there are errors
        #validate_mapping_file.py -m input/$FILENAME1 -o output/mapping_output

        #Demultiplex and quality filter reads
        split_libraries.py -m input/$FILENAME1 -f input/$FILENAME2 -q input/$FILENAME3 -o output/split_library_output

        #De novo OTU picking
        #1.) Pick a representative sequence for each OTU (pick_rep_set.py)
        #2.) Assign taxonomy to OTU representative sequences (assign_taxonomy.py)
        #3.) Align OTU representative sequences (align_seqs.py)
        #4.) Filter the alignment (filter_alignment.py)
        #5.) Build a phylogenetic tree (make_phylogeny.py)
        #6.) Make the OTU table (make_otu_table.py)
        pick_de_novo_otus.py -i output/split_library_output/seqs.fna -o output/otus


fi

# no need to stage out data, your output will be archived for you.

