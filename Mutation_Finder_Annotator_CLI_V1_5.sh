#!/bin/bash
#B.T. January 24, 2023
#Command line version
##################################################################################################################################
# Help
[ "$1" = "-h" -o "$1" = "--help" ] && echo "

Mutation Finder and Annotator (MFA) command line version 1.5

ABOUT: 
This program identifies DNA sequence variants unique to one or more selected samples preset in a mulit-sample VCF file.  Both heterozygous and homozygous alternative alleles are returned in a new VCF file titled output.vcf. Putative induced mutations are next annotated using the program SnpEff producing the following files:  annotated_output.vcf, snpEff_genes.txt, snpEff_summary.html

PREREQUISITES:
1) A multisample VCF that is compressed with bgzip (ending in .vcf.gz), 2) an index of the .vcf.gz file (using tabix), 3) A SnpEff genome database that matches the genome assembly used to generate the VCF file, 4) the following tools installed: 
SnpEff, SnpSift, Java, bash, zenity, awk, tr, datamash, bcftools. This program was built to run on Ubuntu 20.04 and higher. See the readme file for information on using with other opperating systems.  

TO RUN:

1) Provide permission for this program to run on your computer (open a terminal window and type chmod +x Mutation_Finder_Annotator_CL_V1_3.sh).  Check to make sure that the name is an exact match to the .sh file you are using as the version may change.
  
2) Test to see if this works by launching the program without any arguments (./Mutation_Finder_Annotator_CL_V1_3.sh). You should should see some information on what you need to do to run the program.  

3) Run the program with the arguments.  Prior to doing this, you should collect the information needed.  It may be helpful to create a text file that contains all the information you need. If this seems like a lot of work, try running the GUI version, where you don't need to do any of this.  The following information is needed:  

	a: The path to the VCF file containing DNA sequence variants.  This should be a multi-sample VCF with samples from different mutant lines and associated controls.  The file should be compressed (using bgzip) and should end with .vcf.gz, and indexed (using tabix).  If you do not know the path, try opening a terminal window and dragging the file into the window.  The path should appear.  Simply remove the single quotation marks.  For example, /home/brad/Documents/VCFs/Coffee01242023.vcf.gz
	
	b: The exact name of one or more samples to search for unique mutations.  The name should be an exact match to what is on the VCF file.  For example, if the sample name is Sample1, typing sample1 will not work.  Sample names should not have spaces or special characters except for an underscore (_) and should not contain only numbers.  This is to ensure that SnpSift works properly.  The following are examples of names that will cause errors:  Brad-1, 12345.  To fix this, change the names to Brad_1 and 12345A.  

IMPORTANT: If you are supplying more than one sample, the sample names you type on the command line must be separated by a space and surrounded by double quotations. 

NOTE: This program is designed to streamline the process of finding induced mutations.  Mutations are induced more or less randomly, and so the expectation is that separate mutant lines (e.g. plants deriving from two different seed that were mutagenized) will have different mutations.  This has pracital implications on how you use this software.  For example, if you include technical replicates then you would include all replicates in your sample choice.  However, if you have included siblings from a mutant line, including all siblings will only uncover mutations that are found in all siblings.  Conversely, if siblings are present and you include only one, you will only recover mutations unique to that specific line.  To fully understand the induced mutations in a single sample from a set of siblings would require you to run this program twice (once with the single sample and once with the sibling set), or to subset the VCF so that only one sample per mutant line is present (this can be done with bcftools).  

	c: The exact name of the SnpEff genome to be used.  This is case sensitive. See the SnpEff documentation on databases (https://pcingola.github.io/SnpEff/se_buildingdb/).  If building a custom database, make sure to give it a name without spaces or special characters. 
	
	d: The full path to the SnpEff.jar file.  See section a if you are not clear on how to get the path.
	
	e: The full path to the SnpSift.jar file.  See section a if you are not clear on how to get the path.
	
4) Once you have collected all the information in section 3, you are ready to run the program.  The command structure is 

./Mutation_Finder_Annotator_CL_V1_3.sh -a path_to_VCF_File -b Samples -c SnpEff_Genome -d path_to_SnpEff -e path_to_SnpSift

Here is an example of what it looks like with real information:

./Mutation_Finder_Annotator_CL_V1_3.sh -a /home/brad/Documents/VCFs/Coffee01242023.vcf.gz -b Coffee1 -c /home/brad/snpEff/snpEff.jar -d /home/brad/snpEff/SnpSift.jar

LICENSE:  
MIT License

Copyright (c) 2023 Bradley John Till

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the *Software*), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Version Information:  Version 1.5, February 7, 2023
" && exit

############################################################################################################################


helpFunction()
{
   echo ""
   echo "Usage: $0 -a path to VCF -b Unique Mutant Samples -c SnpEff genome -d path to SnpEff -e path to SnpSift"
   echo ""
   echo -e "\t-a The full path to the .vcf.gz file you wish to use.  
   	For example /home/brad/Documents/VCFs/Coffee01242023.vcf.gz \n"
   echo -e "\t-b One or more samples to search for unique mutations.  
  	If choosing more than one, the two samples should have shared mutations 
  	NOTE: the names must be exact *case sensitive* for the program to work
  	NOTE: if providing 2 or more samples, add quotation marks and separate names by a space "
   echo -e "\t-c The exact name of the SnpEff genome to be used *case sensitive*"
   echo -e "\t-d The full path to the SnpEff.jar file"
   echo -e "\t-e The full path to the SnpSift.jar file"
   echo ""
   echo "For more detailed help and to view the license, type $0 -h"
   exit 1 # Exit script after printing help
}

while getopts "a:b:c:d:e:" opt
do
   case "$opt" in
      a ) parameterV="$OPTARG" ;;
      b ) parameterS="$OPTARG" ;;
      c ) parameterG="$OPTARG" ;;
      d ) parameterE="$OPTARG" ;;
      e ) parameterI="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterV" ] || [ -z "$parameterS" ] || [ -z "$parameterG" ] || [ -z "$parameterE" ] || [ -z "$parameterI" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Store parameters for later use
echo "$parameterV" > variantpath
echo "$parameterS" > MutantL
echo "$parameterG" > SNPeffGenome
echo "$parameterE" > SnpEffpath
echo "$parameterI" > SnpSIFTpath

############################################################################################################################

log=MFAt.log
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>MFAt.log 2>&1
now=$(date)  
echo "Mutation Finder and Annotator (MFA) command line version 1.5
-h for help
Script Started $now."  > $log

OR='\033[0;33m'
NC='\033[0m'
printf "${OR}Mutation Finder and Annotator (MFA) command line version 1.5
-h for help
Script Started $now.${NC}\n" 
#printf "Beginning to process files. From here on out, text in orange is written by your friendly neighborhood computer programmer, text in white represents information/errors that are produced by the various software tools being employed.\n" 
echo "Beginning to process files." >> $log
printf "${OR}Beginning to process files.${NC}\n"

#Generate list of all samples in VCF and make genotype code list
b=$(head -1 variantpath)
bcftools query -l $b > samplelist1 
tr ' ' '\t' < MutantL > MutantLa
datamash transpose < MutantLa > Mutants
awk 'NR==FNR{a[$1]=$1;next}{if (a[$1]) print $1, "1" ;else print $0, "2"}'  Mutants samplelist1 > SSlist
#Make the file for mutant selection to be used by SNPsift:  
#1 = isHom ( GEN[sample] ) & isVariant( GEN[sample]
#2 = isRef ( GEN[sample])
awk '{print > ($1".b")}' SSlist
printf "${OR}Generating SnpSift code.${NC}\n"
echo "Generating SnpSift code." >> log
for i in *.b; do 

awk '{if ($2==2) print "isRef (GEN["$1"]) &"; else if ($2==1) print "(isHom (GEN["$1"]) & isVariant(GEN["$1"]) || isHet ( GEN["$1"])) & "}' $i > ${i%.*}.bb
done
paste *.bb > script.stage
tr '\t' ' ' < script.stage > script.tab
#below does not seem to work with Mac, but rev cut works
#awk 'NF{NF-=1};1' script.tab > script2.tab
rev script.tab | cut -c3- | rev > script2.tab

a=$(head -1 SnpSIFTpath)
b=$(head -1 variantpath)

awk -v awkvar1="$a" -v awkvar2="$b" '{print "#!/bin/bash" "\n" "#Induced mutation identification" "\n" "java -Xmx64g -jar " awkvar1 " filter \x22"$0"\x22 " awkvar2 " > output.vcf"}' script2.tab > MutHunt.sh

printf "${OR}Finding mutations.${NC}\n"
echo "Finding mutations." >> log
# give permission for the shell script to run.  
chmod +x MutHunt.sh
./MutHunt.sh
printf "${OR}Running SNPeff to predict the effect of unique mutations.${NC}\n"  
echo "Running SNPeff to predict the effect of unique mutations." >> log  
c=$(head -1 SnpEffpath)
d=$(head -1 SNPeffGenome)

java -Xmx32g -jar $c $d output.vcf >  annotated_ouput.vcf



printf "${OR}Final processing steps.  Program almost finished.${NC}\n"
echo "Final processing steps.  Program almost finished." >> log
awk '{print "Mutants selected:", $0}' MutantL > mut2
awk '{print "SNPeff genome used:", $1}' SNPeffGenome > sng
awk '{print "Path to VCF file used:", $1}' variantpath > vpath
awk '{print "Path to SnpEFF.jar:", $1}' SnpEffpath > sepath
awk '{print "Path to SnpSIFT.jar:", $1}' SnpSIFTpath > sspath
now=$(date)  
printf "${OR}Script Finished $now. The logfile is named MFA.log.${NC}\n" 
echo "Script Finished $now." >> log
cat MFAt.log mut2 sng vpath sspath sepath > MFA.log
#Remove temporary files 

rm *.b *.bb MutHunt.sh MutantL SNPeffGenome log script.stage script.tab script2.tab samplelist1 SSlist mut2 Mutants MFAt.log variantpath vpath SnpEffpath sepath SnpSIFTpath sspath sng MutantLa
mkdir MFA_Output
mv annotated_ouput.vcf ./MFA_Output/
mv MFA.log ./MFA_Output/
mv output.vcf ./MFA_Output/
mv snpEff_genes.txt ./MFA_Output/
mv snpEff_summary.html ./MFA_Output/
#End of program 
##################################################################################################################################
