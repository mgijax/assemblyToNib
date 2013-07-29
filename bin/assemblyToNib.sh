#!/bin/sh -x

#
#  $Header
#  $Name
#
#  assemblyToNib.sh
###########################################################################
#
#  Purpose:  This script unzips and nib formats the assembly fasta files and
#            renames them for use by the seqfetch tool and the BLAT server
#
#  Usage: assemblyToNib.sh
#
#
#  Env Vars:
#
#      See the configuration file
#
#  Inputs:
#
#      - Configuration file
#      - fasta format assembly files
#
#  Outputs:
#
#      - log file
#      - nib files
#
#  Exit Codes:
#
#      0:  Successful completion
#      1:  Fatal error occurred
#      2:  Non-fatal error occurred
#
#  Assumes:  Nothing
#
#  Implementation:
#
#  Notes:  None
#
###########################################################################

usage="assemblyToNib.sh"

# list of mouse chromosomes
mouseChrList="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y MT"

# list of human chromosomes
humanChrList="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y"

# create the log file
cd `dirname $0`/..
LOG=`pwd`/assemblyToNib.log
rm -f ${LOG}

date >> ${LOG} 
#
#  Verify the argument(s) to the shell script.
#

if [ $# -ne 0 ]
then
    echo "Usage: $usage" | tee -a ${LOG}
    exit 1
fi

#
#  Establish the configuration file name
#
CONFIG_LOAD=`pwd`/Configuration

#
#  Make sure the configuration file is readable
#
if [ ! -r ${CONFIG_LOAD} ]
then
    echo "Cannot read configuration file: ${CONFIG_LOAD}" | tee -a ${LOG}
    exit 1
fi

#
# source config file
#
. ${CONFIG_LOAD}

#
#  Make sure the master configuration file is readable
#

if [ ! -r ${CONFIG_MASTER} ]
then
    echo "Cannot read configuration file: ${CONFIG_MASTER}" | tee -a ${LOG}
    exit 1
fi

if [ -r ${LOG_DIAG} ]
then
    rm ${LOG_DIAG}
fi
touch ${LOG_DIAG}

if [ -r ${LOG_PROC} ]
then
    rm ${LOG_PROC}
fi
touch ${LOG_PROC}

#
# get the chromosome list for the requested organism
#

if [ ${ORGANISM} = "mouse" ]
then
    chrList=${mouseChrList}
    echo "chromosome list for mouse: $chrList" >> ${LOG_DIAG}
elif [ ${ORGANISM} = "human" ]
then
    chrList=${humanChrList}
    echo "chromosome list for human: $chrList" >>  ${LOG_DIAG}
else
    echo "unsupported organism: ${ORGANISM}" | tee -a ${LOG_DIAG}
    exit 1
fi

###########################################################################
#
# main
#
###########################################################################

#
# clean out the output directories
#

#
# go to the input directory and get the list of chromosome files 
#

cd ${INPUTDIR}
zipped_files=`ls ${FILENAME_PATTERN}`
echo "INPUTDIR: $INPUTDIR"
echo "zipped_files: $zipped_files"

#
# unzip the chromosome files to the FASTA output directory
# 
echo "Uncompressing chromosome files\n" >> ${LOG_DIAG} 

for f in ${zipped_files}
do
	# get filename without the compression extension
	prefix=`echo $f | sed "s/${ZIP_EXT}//"`
	echo "uncompressing ${INPUTDIR}/$f to ${FA_OUTPUTDIR}/${prefix}" >> ${LOG_DIAG}

	# decompress to output directory
	gunzip -c $f >> ${FA_OUTPUTDIR}/${prefix} 
        STAT=$?
	if [ ${STAT} -ne 0 ] 
	then	
	    "gunzip $f failed" | tee -a ${LOG_DIAG} 
	fi
done 

#
# go to the fasta dir and rename the files 
#
# e.g renaming *.1.* to chr1.fa
#
# Ensembl and UCSC have different chars pre and post chromosome number in 
# their filenames thus the use of PRE_CHAR and POST_CHAR
cd ${FA_OUTPUTDIR}

echo "Renaming files\n" >> ${LOG_DIAG} ${LOG_PROC} 
for chr in ${chrList}
do
        echo "renaming *${PRE_CHR}${chr}${POST_CHR}* to chr${chr}${FA_EXT}" | tee -a ${LOG_DIAG} 
        mv *${PRE_CHR}$chr${POST_CHR}* chr${chr}${FA_EXT} >> ${LOG_DIAG}
	STAT=$?
	if [ ${STAT} -ne 0 ]
	then	
            "renaming chromosome  ${chr} file failed" | tee -a ${LOG_DIAG}
	fi
done

#
# get the list of FASTA chromosome files and faToNib them to the 
# NIB output dir
#
# e.g. Performing faToNib on chr1.fa and writing to /data/research/dna/build_nib/chr1.nib

unzipped_files=`ls *${UNZIPPED_EXT}`

echo "running  ${FATONIB}\n" >> ${LOG_DIAG} ${LOG_PROC}
 
# faToNib each file adding nib extension 
for f in ${unzipped_files}
do   	prefix=`echo $f | sed "s/${FA_EXT}//"`
	echo  "Performing faToNib on $f and writing to ${NIB_OUTPUTDIR}/`basename $prefix`${NIB_EXT}" >> ${LOG_DIAG}
        # don't redirect output to log, stdout is huge
        ${FATONIB} $f ${NIB_OUTPUTDIR}/`basename $prefix`${NIB_EXT} >> ${LOG_DIAG}
	STAT=$?
        if [ ${STAT} -ne 0 ] 
	then
            "faToNib $f failed" | tee -a ${LOG_DIAG}
	fi
	
done 

date >> ${LOG}
