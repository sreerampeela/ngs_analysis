# ngs_analysis

PLEASE NOTE THAT THIS IS ONLY THE FIRST VERSION OF THE SCRIPT. BASED ON PARAMETERS AND INPUTS FROM USERS, NEW FEATURES WILL BE ADDED.

The above script is designed to automate bacterial genome assembly and annotation (specifically for ILLUMINA platforms) using pre-installed programs and tools on UBUNTU 18.04 version. 
The description to each program is provided as comments.
For the tool to work without any changes and to aid in resolving paths for each program/tool, please follow the instructions below (you may skip this if you are good in linux programming):

1. Create a directory called "softwares" in $HOME directory. Use sudo if prompted for permissions.
2. Extract or clone every tool in the $HOME/softwares directory using installation instructions specific for each tool. 
3. Make a directory in Desktop called "ngs_analysis" and copy all fastq or fastq.gz files into this directory. Make this as working directory.
4. Create sub-directories for each tool in the current working directory. Preferably all the genome files and database files should be in the same folder
5. Append the exact path to each program. It depends on the location where you installed them. In the script, I used redirect (based on my installation location).
6. Enter accession ids or file names (without .fastq or .fastq.gz extensions) separated by spaces and within double quotes. Change variables "f" and "r" depending on the extension of file. Alternately you can compress .fastq files using gzip to conserve space
7. All parameters choosen are based on "Genome Assembly Tutorial: Command Line" by Anthony Underwood and through discussion with experts and peers. Cross validation with different parameters should be done.

I gratefully acknowledge Anthony Underwood and my friends Ms. Jyoti Sharma and Ms. Steffi Roseand peers from LLB group for providing the tutorial and the inputs.

Hope you find it interesting.
