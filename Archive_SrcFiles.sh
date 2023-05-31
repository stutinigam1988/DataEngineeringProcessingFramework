#!/bin/bash
#===============================================================================================================================#
#
# Shell Script Name 	: Archive_SrcFiles.sh	
#
# Author		        : Stuti Nigam		
#
# Date			        : 25 Jun 2019
#
# Description/Object	: Script for Archiving source files	
#               		
# Parameters		    :NA	
#               		
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
export LOG_FILE=$LOG_DIR/File_Archive_`date +%Y-%m-%d-%H_%M_%S`.log

#Removing Carriage Return from File Validation Functions Script
sed -i -e 's/\r//' $SCRIPT_DIR/File_Validation_functions.sh

#Calling Function file
. /u02/cifs/informatica/INT_INFA_TEST/CDD_DEV/Scripts/File_Validation_functions.sh

#Creating log file for this session run
touch $LOG_FILE

		l_f_extract_batch_date 
		BATCH_DATE=`echo $l_query_ret | cut -d',' -f2`
		BATCH_ID=`echo $l_query_ret | cut -d',' -f1`
		
		echo $l_query_ret
		echo $BATCH_DATE
		echo $BATCH_ID

		echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_insert_step_audit."	>> $LOG_FILE

		l_f_extract_file_names $BATCH_ID
		
		echo $l_query_ret >> $LOG_FILE
		
		echo $l_query_ret  | tr " " "\n" > $TMP_DIR/file_names.txt
		
		sed -i s/xlsx/txt/g $TMP_DIR/file_names.txt
				
		
ARCHIVAL_FOLDER="$ARCHIVAL_DIR"/"$BATCH_DATE"
echo "Archival Folder is : $ARCHIVAL_FOLDER" >> $LOG_FILE
PROC_FILE_FOLDER="$ARCHIVAL_FOLDER"/"PROCESSED_FILES"
if [ -d "$ARCHIVAL_FOLDER" ]
then
	echo "Batch Date : $BATCH_DATE Archival Folder exists" >> $LOG_FILE
else
    echo "Creating the $BATCH_DATE archival folder" >> $LOG_FILE
	mkdir $ARCHIVAL_FOLDER
fi

if [ -d "$PROC_FILE_FOLDER" ]
then
	echo "Processed file Folder exists" >> $LOG_FILE
else
	echo "Creating the $BATCH_DATE archival folder" >> $LOG_FILE
	mkdir $PROC_FILE_FOLDER
fi

		
while read line
	do
		echo $line >> $LOG_FILE
	    ZIPPED_FILE_NAME=$line.gz
		gzip $SOURCE_DIR/$line
		mv $SOURCE_DIR/$ZIPPED_FILE_NAME $PROC_FILE_FOLDER
		echo "$line file archived successfully" >> $LOG_FILE
	
	done	< $TMP_DIR/file_names.txt


