#!/bin/bash
#===============================================================================================================================#
#
# Shell Script Name 	: File_Validation.sh	
#
# Author		        : Stuti Nigam		
#
# Date			        : 03Dec2014	
#
# Description/Object	: Script for File Validation	
#               		
# Parameters		    : Step Id	
#               		
# History		        :
#
#  DATE		VERSION		CHANGED BY		CHANGE DESCRIPTION
#  --------------------------------------------------------------------------------------------------------------------------
#  
#
#===============================================================================================================================#

#####################  main  #############################

#Expanding Alias
shopt -s expand_aliases

#creating standard error and information variables
PrInf=": Info-"
PrErr=": Error-"

#exporting standard error and information variables
export PrInf
export PrErr

#creating alias on date variables
alias DATE='echo `date +%Y-%m-%d-%H:%M:%S`'

#Appending Standard Information and error variables with Date
alias PrInfD='echo $PrInf `DATE`'
alias PrErrD='echo $PrErr `DATE`'

#exporting Information and Error variables for logging messages to log files
export PrInfD
export PrErrD

#Getting the name of the script
script_name=$( basename $0 )

#Defining Date and Time format applicable to this session of script
DATE_PATTERN=YYYYMMDD
TIME_PATTERN=HHMISS

#Calling configuration file
. /u02/cifs/informatica/INT_INFA_TEST/CDD_DEV/Scripts/Configuration_File.cfg

#Creating log file Variable for this session of script run
export LOG_FILE=$LOG_DIR/File_Historic_`date +%Y-%m-%d-%H_%M_%S_%N`.log

#Removing Carriage Return from Generic Functions Script
sed -i -e 's/\r//' $SCRIPT_DIR/GENERIC_FUNCTIONS.sh

#Removing Carriage Return from File Validation Functions Script
sed -i -e 's/\r//' $SCRIPT_DIR/File_Validation_functions.sh

#Calling Function file
echo "SCRIPT_DIR::$SCRIPT_DIR*************************************************************************************"
. $SCRIPT_DIR/File_Validation_functions.sh

#Creating log file for this session run
touch $LOG_FILE



#Trigger message for start of script written to Log file
echo "Process Started...." > $LOG_FILE
echo "SCRIPT NAME: $script_name" >> $LOG_FILE

start_dt=$1
end_dt=$2


l_f_extract_historic_batch_dates $start_dt $end_dt

if [ $? -ne 0 ]
then
     echo "`PrErrD` : An error occurred in executing l_f_create_frameworkss_info function to create feed information"
else
    echo "query return is:"$l_query_ret >> $LOG_FILE
	echo "$l_query_ret" >> historic_load_date
fi

while IFS= read -r line
do
    #echo "$line"
	l_f_extract_historic_step_upd "$line" -2
	l_f_extract_historic_batch_upd "$line" -9999
	
	./File_Validation_NonUDX.sh -2

done <<< "$l_query_ret"
