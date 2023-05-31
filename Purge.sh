#!/bin/bash
#===============================================================================================================================#
#
# Shell Script Name 	: Purge.sh	
#
# Author		        : Stuti Nigam		
#
# Date			        : 25 Jun 2015	
#
# Description/Object	: Script for Purging Files	
#               		
# Parameters		    : Na
#               		
#
#  DATE			VERSION		CHANGED BY		CHANGE DESCRIPTION
#  --------------------------------------------------------------------------------------------------------------------------
#  25 Jun 2015   1.0	 	
#
#===============================================================================================================================#

#####################  main  #############################

#Getting the name of the script
script_name=$( basename $0 )

#Calling configuration file
. /u02/Scripts/Configuration_File.cfg

find $LOG_DIR -mtime $RET_PERIOD -exec rm -f {} \;

if [ $? = 0 ]
then
	echo "Files older than $RET_PERIOD are purged successfully from location $LOG_DIR."
else
	echo "$script_name script failed due to some error"
	exit 1
fi

find $ARCHIVAL_DIR -mtime $RET_PERIOD -exec rm -f {} \;

if [ $? = 0 ]
then
	echo "Files older than $RET_PERIOD are purged successfully from location $ARCHIVAL_DIR."
else
	echo "$script_name script failed due to some error"
	exit 1
fi
