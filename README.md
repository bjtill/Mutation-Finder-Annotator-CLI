# Mutation-Finder-Annotator CLI (Command Line Interface)
A command line interface version of the Mutation-Finder-Annotator tool

GUI version is available at: https://github.com/bjtill/Mutation-Finder-Annotator-GUI


Use at your own risk.

I cannot provide support. All information obtained/inferred with this script is without any implied warranty of fitness for any purpose or use whatsoever.

ABOUT: This program identifies DNA sequence variants unique to one or more selected samples preset in a mulit-sample VCF file. Both heterozygous and homozygous alternative alleles are returned in a new VCF file titled output.vcf. Putative induced mutations are next annotated using the program SnpEff producing the following files: annotated_output.vcf, snpEff_genes.txt, snpEff_summary.html

PREREQUISITES:

A multisample VCF that is compressed with bgzip (ending in .vcf.gz)
an index of the .vcf.gz file (using tabix)
A SnpEff genome database that matches the genome assembly used to generate the VCF file
The following tools installed: SnpEff, SnpSift, Java, bash, awk, tr, datamash, bcftools. This GUI program was built to run on Ubuntu 20.04 and higher. See installation notes about running on other systems.

INSTALLATION:

Note: A GUI version of this tool exists.  You may want to try it first.  https://github.com/bjtill/Mutation-Finder-Annotator-GUI

Linux/Ubuntu: Download and uncompress the SppEff package. All other tools can be installed in the Linx command line by typing the name of the tool. Either version information if already installed, or installation instructions if not installed. Downlaod the .sh file from this page and provide it permission to execute using chmod +x .

Mac: Download and uncompress the SppEff package. Install homebrew from the terminal window. Next, install other tools using brew install from the terminal (for example brew install bcftools). The tools are: bcftools and datamash. ALso install Java JDK. 

Windows: NOT TESTED In theory you can install Linux bash shell on Windows (https://itsfoss.com/install-bash-on-windows/) and install the dependecies from the command line (except for SnpEff and SnpSit). If you try this and it works, please let me know. I don't have a Windows machine for testing.

EXAMPLE DATA:

Example data can be found in the directory MFA_Example_Data in the repository for the GUI version https://github.com/bjtill/Mutation-Finder-Annotator-GUI/tree/main/MFA_Example_Data. Information on the samples is found in the enclosed read.me file. Note that you must first install (Oryza_sativa) or build (Coffee) the SnpEff genome database before you run this tool.

TO RUN:

Collect the commmand line argument information needed prior to running the program.  It may be helpful to create a text file that contains all the information you need. If this seems like a lot of work, try running the GUI version, where you don't need to do any of this.  The following information is needed:  

a: The path to the VCF file containing DNA sequence variants.  This should be a multi-sample VCF with samples from different mutant lines and associated controls.  The file should be compressed (using bgzip) and should end with .vcf.gz, and indexed (using tabix).  If you do not know the path, try opening a terminal window and dragging the file into the window.  The path should appear.  Simply remove the single quotation marks.  For example, /home/brad/Documents/VCFs/Coffee01242023.vcf.gz
	
b: The exact name of one or more samples to search for unique mutations.  The name should be an exact match to what is on the VCF file.  For example, if the sample name is Sample1, typing sample1 will not work.  Sample names should not have spaces or special characters except for an underscore (_) and should not contain only numbers.  This is to ensure that SnpSift works properly.  The following are examples of names that will cause errors:  Brad-1, 12345.  To fix this, change the names to Brad_1 and 12345A.  

IMPORTANT: If you are supplying more than one sample, the sample names you type on the command line must be separated by a space and surrounded by double quotations. For example: "Sample1 Sample2".

NOTE: This program is designed to streamline the process of finding induced mutations.  Mutations are induced more or less randomly, and so the expectation is that separate mutant lines (e.g. plants deriving from two different seed that were mutagenized) will have different mutations.  This has pracital implications on how you use this software.  For example, if you include technical replicates then you would include all replicates in your sample choice.  However, if you have included siblings from a mutant line, including all siblings will only uncover mutations that are found in all siblings.  Conversely, if siblings are present and you include only one, you will only recover mutations unique to that specific line.  To fully understand the induced mutations in a single sample from a set of siblings would require you to run this program twice (once with the single sample and once with the sibling set), or to subset the VCF so that only one sample per mutant line is present (this can be done with bcftools).  

c: The exact name of the SnpEff genome to be used.  This is case sensitive. See the SnpEff documentation on databases (https://pcingola.github.io/SnpEff/se_buildingdb/).  If building a custom database, make sure to give it a name without spaces or special characters. 
	
d: The full path to the SnpEff.jar file.  See section a if you are not clear on how to get the path.
	
e: The full path to the SnpSift.jar file.  See section a if you are not clear on how to get the path.
	
Once you have collected all the information, you are ready to run the program. Give permission to the .sh file to run by opening a terminal and typing chmod +x followed by the .sh file name.  The command structure is 

./Mutation_Finder_Annotator_CLI_V1_5.sh -a path_to_VCF_File -b Samples -c SnpEff_Genome -d path_to_SnpEff -e path_to_SnpSift

Here is an example of what it looks like with real information:

./Mutation_Finder_Annotator_CLI_V1_5.sh -a /home/brad/Documents/VCFs/Coffee01242023.vcf.gz -b Coffee1 -c /home/brad/snpEff/snpEff.jar -d /home/brad/snpEff/SnpSift.jar
