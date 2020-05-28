#!bin/bash

#create directories for each tool in the current working directory. Preferably all the genome files and database files should be in the same folder

#append the exact path to each program. it depends on the location where you installed them. 

#enter accession ids or file names (without .fastq or .fastq.gz extensions) separated by spaces and within double quotes. Change variables "f" and "r" depending on the extension of file.

#all parameters choosen are based on Sanger Institute tutorial on WGS. Cross validation with different parameters should be done.

#the PATHs for each tool depends on the installation directory of the tool. Change paths whereever necessary. For the script, I installed in $HOME/softwares directory.

acc_list=<file names/acc ids>

#start loop for accessing the files or accession ids

for acc in $acc_list; do
	f="_1.fastq.gz"
	r="_2.fastq.gz"
	acc_f=$acc$f
	acc_r=$acc$r
	echo $acc
	echo $acc_f
	echo $acc_r

	#run trimmomatic for trimming reads
	f1="_1_paired.fastq.gz"
	f2="_1_unpaired.fastq.gz"
	r1="_2_paired.fastq.gz"
	r2="_2_unpaired.fastq.gz"
	acc_f1=$acc$f1
	acc_f2=$acc$f2
	acc_r1=$acc$r1
	acc_r2=$acc$r2

	sudo java -jar ../../softwares/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 $acc_f $acc_r trimmomatic/$acc_f1 trimmomatic/$acc_f2 trimmomatic/$acc_r1 trimmomatic/$acc_r2 ILLUMINACLIP:../../softwares/Trimmomatic-0.39/adapters/TruSeq2-PE.fa:2:30:10 LEADING:15 TRAILING:10 SLIDINGWINDOW:4:15 MINLEN:36

	#run mash for mash stats
	sk1="sketch"$acc_f1
	stat1=$acc_f1"_mashstats"
	sk2="sketch"$acc_r1
	stat2=$acc_r1"_mashstats"
	echo "Starting Mash on $acc ..."
	mash sketch -o /tmp/$sk1 -k 32 -m 3 -r trimmomatic/$acc_f1 2> mash/$stat1
	mash sketch -o /tmp/$sk2 -k 32 -m 3 -r trimmomatic/$acc_r1 2> mash/$stat2
	echo "Successfully completed Mash. Output files are in $PWD/mash"

	#seqtk
	seqtk_1=$acc_f1"_seqtk_stats"
	seqtk_2=$acc_r1"_seqtk_stats"
	echo "Starting SEQTK on $acc ..."
	seqtk fqchk -q 25 trimmomatic/$acc_f1 > seqtk/$seqtk_1
	seqtk fqchk -q 25 trimmomatic/$acc_r1 > seqtk/$seqtk_2
	echo "Successfully completed SEQTK. Output files are in $PWD/seqtk"

	#lighter for read correction
	lig_out=$acc"_lighter.out"
	echo "Starting LIGHTER on $acc ..."
	sudo ../../softwares/Lighter/lighter -od lighter -r trimmomatic/$acc_f1 -r trimmomatic/$acc_r1 -K 32 4920000 -maxcor 1 2> lighter/$lig_out
	echo "Successfully completed LIGHTER. Output files are in $PWD/lighter"

	#flash for merging reads
	cor1=$acc"_1_paired.cor.fq.gz"
	cor2=$acc"_2_paired.cor.fq.gz"
	echo "Starting FLASH on $acc ..."
	../../softwares/FLASH-1.2.11-Linux-x86_64/flash -m 20 -M 100 -d flash -o $acc -z lighter/$cor1 lighter/$cor2
	echo "Successfully completed FLASH. Output files are in $PWD/flash"

	#spades genome assembly
	exfrag=$acc".extendedFrags.fastq.gz" #recoding each flash output##extendedfrags
	nc1=$acc".notCombined_1.fastq.gz" #not combined_1
	nc2=$acc".notCombined_2.fastq.gz" #not combined_2
	echo "Starting genome assembly with SPAdes on $acc ..."
	sudo ../../softwares/SPAdes-3.14.1-Linux/bin/spades.py --pe1-1 flash/$nc1 --pe1-2 flash/$nc2 --pe1-m flash/$exfrag --only-assembler --tmp-dir /tmp/$acc -k 21,33,43,53,63,75 --threads 2 -o spades/
	echo "Successfully completed SPAdes. Output files are in $PWD/spades"
	fasta=$acc"_contigs.fasta"
	sudo mv spades/contigs.fasta $PWD/$fasta
	echo "contigs in fasta format in $PWD"
	

	#checking quality of assembly
	quast=$acc"_quast.out"
	echo "Starting QUAST for checking genome assembly of $acc .."
	quast.py $PWD/$fasta -o quast/$quast
	echo "Successfully completed checking quality of assembly. Output files are in $PWD/quast"

	#annotation of genome with prokka
	echo "Annotating $acc genome with prokka.."
	prokka --proteins /media/dell/work/ngs/prokka_gbk_file.gbff --outdir prokka/proka/ --force $fasta --genus Streptococcus --species pneumoniae --mincontiglen 200 --prefix $acc
	echo "Successfully completed Prokka. Output files are in $PWD/prokka"

done
