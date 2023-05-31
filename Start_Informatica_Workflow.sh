#!/bin/bash
#===============================================================================================================================#
#
# Shell Script Name 	: Start_Informatica_Workflow.sh	
#
# Author		        : Stuti Nigam		
#
# Date			        : 7/2/2015	
#
# Description/Object	: Wrapper script to run Informatica workflow	
#               		
# Parameters		    : User name, Folder Name, Workflow Name
#               		
# History		        :
#
#  DATE		VERSION		CHANGED BY		CHANGE DESCRIPTION
#  --------------------------------------------------------------------------------------------------------------------------
#  7/2/2015  1.1		exmash			Added functionality to run only failed sessions in second run.
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
export DATE=`date +%Y-%m-%d-%H_%M_%S_%N`
export LOG_FILE=$LOG_DIR/Run_Workflow_"$WORKFLOW_NAME"_`date +%Y-%m-%d-%H_%M_%S_%N`.log

#Removing Carriage Return from File Validation Functions Script
sed -i -e 's/\r//' $SCRIPT_DIR/File_Validation_functions.sh

#Calling Function file
. $SCRIPT_DIR/File_Validation_functions.sh

#Creating log file for this session run
touch $LOG_FILE

export USER_NAME=$1
export WORKFLOW_NAME=$3
export FOLDER_NAME="$2"
export INFA_PASS

		l_f_extract_batch_date 
		BATCH_DATE=`echo $l_query_ret | cut -d',' -f2`
		BATCH_ID=`echo $l_query_ret | cut -d',' -f1`
		
		#echo $l_query_ret
		echo $BATCH_DATE
		echo $BATCH_ID

		echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_insert_step_audit."	>> $LOG_FILE

		l_f_failed_session_name $WORKFLOW_NAME $BATCH_ID
		
		
		echo $l_query_ret 
		#echo $l_query_ret > $TMP_DIR/session_names.txt
		if [ "$l_query_ret" = "" ]
		then
					
			pmcmd startworkflow -sv ${INFA_SERVICE_NAME} -d ${INFA_DOMAIN_NAME} -usd ${USR_DOMAIN_NAME} -u ${USER_NAME} -p "$INFA_PASS" -f "$FOLDER_NAME" -wait ${WORKFLOW_NAME} >$LOG_FILE

			RC=$?
			echo 
			echo "$0: pmcmd Return Code=$RC"
		   #Checking pmcmd return code to determine whether the workflow has been executed successfully or failed to execute 

			if [ $RC -eq 0 ] ; then
				echo "$0: Workflow $WORKFLOW_NAME completed Successfully."
			else
				echo "$0: ERROR! pmcmd failed to run workflow $WORKFLOW_NAME!"
				exit 1
			fi
		
		else		
			while IFS= read -r line
			do
				SESSION_NAME=$line
				echo $SESSION_NAME
				pmcmd starttask -sv ${INFA_SERVICE_NAME} -d ${INFA_DOMAIN_NAME} -usd ${USR_DOMAIN_NAME} -u ${USER_NAME} -p "$INFA_PASS" -f "$FOLDER_NAME" -wait -w ${WORKFLOW_NAME} ${SESSION_NAME} >>$LOG_FILE
				
				pmcmd gettaskdetails -sv ${INFA_SERVICE_NAME} -d ${INFA_DOMAIN_NAME} -usd ${USR_DOMAIN_NAME} -u ${USER_NAME} -p "$INFA_PASS"  -f "$FOLDER_NAME" -w  ${WORKFLOW_NAME} ${SESSION_NAME} > $TMP_DIR/log.txt
				
				STATUS=`grep 'Task run status:' log.txt | cut -d'[' -f2 | cut -d']' -f1`
				
				#Checking pmcmd return code to determine whether the workflow has been executed successfully or failed to execute 

				if [ $STATUS = "Succeeded" ] ; then
					echo "$0: Session $SESSION_NAME completed Successfully."
				else
					echo "$0: Error: Session $SESSION_NAME Failed with some error"
				fi

			done <<< "$l_query_ret"
		fi
