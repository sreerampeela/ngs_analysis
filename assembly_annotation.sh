#!bin/bash

#All the genome files and database files should be in the same folder

#Append the exact path to each program. it depends on the location where you installed them. If not sure, follow instructions in README during installation. For the script, I installed in $HOME/softwares directory.

#enter accession ids or file names (without .fastq or .fastq.gz extensions) separated by spaces and within double quotes. Change variables "f" and "r" depending on the extension of file.

#all parameters choosen are based on Sanger Institute tutorial on WGS. Cross validation with different parameters should be done.

acc_list='ERR2090225 ERR3227746'
mkdir trimmomatictest
mkdir mashtest
mkdir seqtktest
mkdir lightertest
mkdir flashtest
mkdir spadestest
mkdir quasttest
mkdir prokkatest


#start loop for accessing the files or accession ids

for acc in $acc_list; do
	f="_1.fastq.gz" #for appending extension
	r="_2.fastq.gz"
	acc_f=$acc$f
	acc_r=$acc$r
	echo $acc
	echo $acc_f
	echo $acc_r
	#declare all variables here
	f1="_1_paired.fastq.gz"
	f2="_1_unpaired.fastq.gz"
	r1="_2_paired.fastq.gz"
	r2="_2_unpaired.fastq.gz"
	acc_f1=$acc$f1
	acc_f2=$acc$f2
	acc_r1=$acc$r1
	acc_r2=$acc$r2
	sk1="sketch"$acc_f1
	stat1=$acc_f1"_mashstats"
	sk2="sketch"$acc_r1
	stat2=$acc_r1"_mashstats"
	seqtk_1=$acc_f1"_seqtk_stats"
	seqtk_2=$acc_r1"_seqtk_stats"
	lig_out=$acc"_lighter.out"
	cor1=$acc"_1_paired.cor.fq.gz"
	cor2=$acc"_2_paired.cor.fq.gz"
	exfrag=$acc".extendedFrags.fastq.gz" #recoding each flash output##extendedfrags
	nc1=$acc".notCombined_1.fastq.gz" #not combined_1
	nc2=$acc".notCombined_2.fastq.gz" #not combined_2
	fasta=$acc"_contigsss.fasta"
	quast=$acc"_quast.out"
	genes=prokka_gbk_file.gbff #download gbff files from NCBI and copy to current directory
	
	#run trimmomatic for trimming reads
	java -jar ../../softwares/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 $acc_f $acc_r trimmomatictest/$acc_f1 trimmomatictest/$acc_f2 trimmomatictest/$acc_r1 trimmomatictest/$acc_r2 ILLUMINACLIP:../../softwares/Trimmomatic-0.39/adapters/TruSeq2-PE.fa:2:30:10 LEADING:15 TRAILING:10 SLIDINGWINDOW:4:15 MINLEN:36 

	#run mash for mash stats
	
	mash sketch -o /tmp/$sk1 -k 32 -m 3 -r trimmomatictest/$acc_f1 2> mashtest/$stat1
	mash sketch -o /tmp/$sk2 -k 32 -m 3 -r trimmomatictest/$acc_r1 2> mashtest/$stat2
	
	#seqtk
	
	seqtk fqchk -q 25 trimmomatictest/$acc_f1 > seqtktest/$seqtk_1
	seqtk fqchk -q 25 trimmomatictest/$acc_r1 > seqtktest/$seqtk_2
		
	#lighter for read correction
	
	../../softwares/Lighter/lighter -od lightertest -r trimmomatictest/$acc_f1 -r trimmomatictest/$acc_r1 -K 32 4920000 -maxcor 1 2> lightertest/$lig_out
	
	#flash for merging reads
	chmod 777 -R lightertest 
	../../softwares/FLASH-1.2.11-Linux-x86_64/flash -m 20 -M 100 -d flashtest -o $acc -z lightertest/$cor1 lightertest/$cor2


	#spades genome assembly
  #the option --isolate should be used when a error "Your data seems to have high uniform coverage depth" is flagged in the warnings.log file of SPAdes. If not you may run without this option.
	sudo ../../softwares/SPAdes-3.14.1-Linux/bin/spades.py --pe1-1 flashtest/$nc1 --pe1-2 flashtest/$nc2 --pe1-m flashtest/$exfrag --only-assembler --isolate --tmp-dir /tmp/$acc -k 21,33,43,53,63,75 --threads 2 -o spadestest/
	
	sudo mv spadestest/contigs.fasta $PWD/$fasta
	
	#checking quality of assembly
	quast.py $PWD/$fasta -o quasttest/$quast

	#annotation of genome with prokka
	genus=<genus name>
  species=<species name>
	prokka --proteins $genes --outdir prokkatest/ --force $fasta --genus $genus --species $species --mincontiglen 200 --prefix $acc

done
