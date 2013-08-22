#!/bin/sh
#
# stop_blatserver.sh
###########################################################################
#
#  Purpose: remove a blat server
#
Usage="Usage: $0 host port"
#  Example: stop_blatserver.sh hobbiton 9037
#  This will remove the blat server running on port 9037 on the Unix server
#    hobbiton
#
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
#
#  Set up a log file for the shell script in case there is an error
#  during configuration and initialization.
#
cd `dirname $0`/..
LOG=`pwd`/stop_blatserver.log
rm -f ${LOG}
date > ${LOG}

# define the config file located in the product root directory
CONFIG_COMMON=Configuration

#
#  Verify the argument(s) to the shell script.
#
if [ $# -lt 2 ]
then
    echo ${Usage} | tee -a ${LOG}
    exit 1
fi

GFHOST=$1
GFPORT=$2

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

# diagnostic log
LOG_DIAG=${GFSERVER_LOGDIR}/stop_blatserver.log 

##################################################################
##################################################################
#
# main
#
##################################################################
##################################################################
date > ${LOG_DIAG}

echo "${GFSERVER} stop ${GFHOST} ${GFPORT}" | tee -a ${LOG_DIAG}
${GFSERVER} stop ${GFHOST} ${GFPORT} | tee -a ${LOG_DIAG}

date >> ${LOG_DIAG}
date >> ${LOG}

