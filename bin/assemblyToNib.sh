#!/bin/sh

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
#  Usage:
#
    usage="assemblyToNib.sh"
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


# list of mouse chromosomes
mouseChrList="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y M"

# list of human chromosomes
humanChrList="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y"

# create the log file
cd `dirname $0`/..
LOG=`pwd`/assemblyToNib.log
rm -f ${LOG}

#
#  Verify the argument(s) to the shell script.
#

if [ $# -ne 0 ]
then
    echo "Usage: $usage" | tee -a ${LOG}
    exit 1
fi

#
#  Establish the configuration file names.
#
CONFIG=`pwd`/Configuration

#
#  Make sure the configuration file is readable.
#
if [ ! -r ${CONFIG} ]
then
    echo "Cannot read configuration file: ${CONFIG}" | tee -a ${LOG}
    exit 1
fi

#
# Source the configuration file
#
. ${CONFIG}

# get the chromosome list for the requested organism
if [ ${ORGANISM} = "mouse" ]
then
    chrList=$mouseChrList
    echo "chromosome list for mouse: $chrList" | tee -a ${LOG}
elif [ ${ORGANISM} = "human" ]
then
    chrList=$humanChrList
    echo echo "chromsome list for human: $chrList" | tee -a ${LOG}
else
    echo "unsupported organism: ${ORGANISM}" | tee -a ${LOG}
    exit 1
fi


# clean out the output directory
echo "removing all files from ${OUTPUTDIR}" | tee -a ${LOG}
rm -f ${OUTPUTDIR}/*

# go to the input directory and get the list of chromosome files 
cd ${INPUTDIR}
echo "pwd: `pwd`"
zipped_files=`ls ${FILENAME_PATTERN}`

# unzip the list of files in the input directory
for f in ${zipped_files}
do
	# get filename without the compression extension
	prefix=`echo $f | sed "s/${ZIP_EXT}//"`
	echo "uncompressing ${INPUTDIR}/$f to ${OUTPUTDIR}/${prefix}" | tee -a ${LOG}

	# decompress to output directory
	${ZIP_UTILITY} $f > ${OUTPUTDIR}/${prefix}
done 

echo "" | tee -a ${LOG}

# go to the output dir
cd ${OUTPUTDIR}

# get the list of unzipped chromosome files
unzipped_files=`ls *${UNZIPPED_EXT}`

# faToNib each file adding nib extension and removing unzipped file
for f in ${unzipped_files}
do   
	echo  "Performing faToNib on $f and writing to ${outputdir}/${f}.to${NIB_EXT}" | tee -a ${LOG}
        ${FATONIB} $f $f.to${NIB_EXT}
	rm $f
done 

echo "" | tee -a ${LOG}

# rename each file
for chr in ${chrList}
do
        echo "renaming *${PRE_CHR}${chr}${POST_CHR}* to chr${chr}${NIB_EXT}" | tee -a ${LOG}
        mv *${PRE_CHR}$chr${POST_CHR}* chr${chr}${NIB_EXT}
done
