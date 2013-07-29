#!/bin/sh
#
# start_blatserver.sh
###########################################################################
#
#  Purpose: start a blat server - a convenience script which passes all nib
#    files individually to the server to avoid loading multiple MT nib files due
#    to a symbolic link
#
Usage="Usage: $0 host port nibDir"
#  Example: 
#     start_blatserver.sh hobbiton 9037 /data/research/dna/mouse_build_37_nib
#  Note: Ignore the 'getsockopt error' from stderr after 'Done adding' state
#        ment. 
#  This script starts a blat server running on a specified port on a specified
#   Unix server
#
#  Assumes: nib files for chr 1 - 21, X, Y, and MT exist in 'nibDir'
#  Env Vars:
#
#      See the configuration file
#
#  Inputs:
#
#      - Configuration file
#      - command line parameters
#
#  Outputs:
#
#	- log file
#  Exit Codes:
#       This script starts the blat server in the background
#       A human needs to inspect stdout/stderr to determine if the
#       server successfully started
#
#  Implementation:
#
#  Notes:  None
#
###########################################################################
#
#  Set up a log file for the shell script in case there is an error
#  during configuration and initialization.
#
cd `dirname $0`/..
LOG=`pwd`/start_blatserver.log
rm -f ${LOG}
date > ${LOG}

# define the config file located in the product root directory
CONFIG_COMMON=Configuration

# the set of chromosome nib files to load
CHR="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y MT"

#
#  Verify the argument(s) to the shell script.
#
if [ $# -lt 3 ]
then
    echo ${Usage} | tee -a ${LOG}
    exit 1
fi

# get the command line parameters
GFHOST=$1
GFPORT=$2
NIBDIR=$3

#
#  Make sure the configuration file is readable.
#
if [ ! -r ${CONFIG_COMMON} ]
then
    echo "Cannot read configuration file: ${CONFIG_COMMON}" | tee -a ${LOG}
    exit 1
fi

# source config file
echo "Sourcing Configuration"
. ${CONFIG_COMMON}

# create diagnostic log
LOG_DIAG=${GFSERVER_LOGDIR}/start_blatserver.log

INPUTFILES=""
# create the string of input files
for c in ${CHR}
do
   INPUTFILES="${INPUTFILES} ${NIBDIR}/chr${c}.nib"
done

##################################################################
##################################################################
#
# main
#
##################################################################
##################################################################
date > ${LOG_DIAG} 

echo "${GFSERVER} start ${GFHOST} ${GFPORT} ${INPUTFILES} &" | tee -a ${LOG_DIAG}
echo "Ignore 'getsockopt error' from stderr"
${GFSERVER} start ${GFHOST} ${GFPORT} ${INPUTFILES} & 

date >> ${LOG_DIAG}
date >> ${LOG}
