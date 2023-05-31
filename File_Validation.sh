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
PrInf="Info-"
PrErr="Error-"

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
export LOG_FILE=$LOG_DIR/File_validation_"$1"_`date +%Y-%m-%d-%H_%M_%S_%N`.log

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

for STEP_ID in "$@"
do
	#creating error data file
	export ERROR_DATA=$TMP_DIR/error_data_$STEP_ID_`date +%Y-%m-%d-%H_%M_%S_%N`.txt
	touch $ERROR_DATA
    echo "Step Id is : $STEP_ID" >> $LOG_FILE
	echo "Scripts path: $SCRIPT_DIR" >> $LOG_FILE
	
	############################################################"
	#Extraction of feed and Batch related information starts here"
	#############################################################"
		
		#creating supply info file to get details about the file
		#start of function to create temporary supply info file--l_f_create_framework_info
		echo "`PrInfD` :Calling l_f_create_framework_info function to get feed information from database." >> $LOG_FILE
		l_f_create_framework_info $STEP_ID 
		#start of function return check--l_f_create_framework_info
		if [ $? -ne 0 ]
		then
			echo "`PrErrD` : An error occurred in executing l_f_create_frameworkss_info function to create feed information"
		else
			echo "query return is:"$l_query_ret >> $LOG_FILE
			echo $l_query_ret 
		fi
		#close of function return check--l_f_create_framework_info
		#close of function to create temporary supply info file--l_f_create_framework_info

		FEED_NAME=`echo $l_query_ret | cut -d'$' -f1`
		FILE_DLIM=`echo $l_query_ret | cut -d'$' -f2`
		TRAILER_RECORD_SUM_COLUMN=`echo $l_query_ret | cut -d'$' -f3`
		FILE_NM_DLIM=`echo $l_query_ret | cut -d'$' -f4`
		HDR_IDN_COL_POS=`echo $l_query_ret | cut -d'$' -f5`
		HDR_IDENTIFIER=`echo $l_query_ret | cut -d'$' -f6`
		TRL_IDN_COL_POS=`echo $l_query_ret | cut -d'$' -f7`
		TRL_IDENTIFIER=`echo $l_query_ret | cut -d'$' -f8`
		RECORD_TYPE_COL_POS=`echo $l_query_ret | cut -d'$' -f9`
		AMT_SUM_COL_POS=`echo $l_query_ret | cut -d'$' -f10`
		FILE_NAME_PATTERN=`echo $l_query_ret | cut -d'$' -f11`
		SOURCE_SYSTEM_ID=`echo $l_query_ret | cut -d'$' -f12`
		TR_AMT_SUM_COL=`echo $l_query_ret | cut -d'$' -f13`
		ARC_SRC_LOCATION=`echo $l_query_ret | cut -d'$' -f14`
		FEED_SUB_TYPE=`echo $l_query_ret | cut -d'$' -f15`
		FILE_DT_IDENTIFIER=`echo $l_query_ret | cut -d'$' -f16`
		START_REC_CNT_POS=`echo $l_query_ret | cut -d'$' -f17`
		END_REC_CNT_POS=`echo $l_query_ret | cut -d'$' -f18`
		DATE_START_POS=`echo $l_query_ret | cut -d'$' -f19`
		DATE_END_POS=`echo $l_query_ret | cut -d'$' -f20`
		FEED_ID=`echo $l_query_ret | cut -d'$' -f21`
		BATCH_DATE=`echo $l_query_ret | cut -d'$' -f22`
		LAST_BATCH_DATE=`echo $l_query_ret | cut -d'$' -f23`
		SOURCE_SYSTEM_NAME=`echo $l_query_ret | cut -d'$' -f24`
		ZERO_BYTE_VALID=`echo $l_query_ret | cut -d'$' -f25`
		TRAILER_RECORD_SUM_VALID=`echo $l_query_ret | cut -d'$' -f26`
		TRAILER_AMOUNT_SUM_VALID=`echo $l_query_ret | cut -d'$' -f27`
		HEADER_FORMAT_VALID=`echo $l_query_ret | cut -d'$' -f28`
		#Close of obtaining Feed parameters from supply_info_file and assigning to script parameters
		echo "BATCH DATE :: $BATCH_DATE"
		echo "LAST_BATCH_DATE :: $LAST_BATCH_DATE" 
		echo "SOURCE_SYSTEM_NAME :: $SOURCE_SYSTEM_NAME"
		echo "FEED_ID :: $FEED_ID" >> $LOG_FILE
		
		export ARC_SRC_LOCATION
		export FILE_NM_DLIM
		LOCAL_ZERO_BYTE_VALID=$ZERO_BYTE_VALID
		LOCAL_TRAILER_RECORD_SUM_VALID=$TRAILER_RECORD_SUM_VALID
		LOCAL_TRAILER_AMOUNT_SUM_VALID=$TRAILER_AMOUNT_SUM_VALID
		LOCAL_HEADER_FORMAT_VALID=$HEADER_FORMAT_VALID
	###############################
	#Validation Process starts here
	###############################

	#Redirecting the path to Landing Directory
	echo "FEED_NAME : $FEED_NAME" >> $LOG_FILE

	#Redirecting the path to Landing Directory
	cd $ARC_SRC_LOCATION
	echo "Landing Location : $ARC_SRC_LOCATION" >> $LOG_FILE

	export FILE_LIST=file_list_$STEP_ID_`date +%Y-%m-%d-%H_%M_%S_%N`.txt
	#Searching for feed pattern files and moving them to file
	ls $FEED_NAME* >> $LOG_FILE
	ls $FEED_NAME* > $TMP_DIR/$FILE_LIST

	#Checking whether the file present for given feed name.
	if [ ! -s $TMP_DIR/$FILE_LIST ]
	then
		echo "No File found for Feed $FEED_NAME at Landing Location $ARC_SRC_LOCATION" >> $LOG_FILE
	 exit 1
	fi	 
	FILE_PROCESSED_FLAG=0
	while read line
	do
		if [ $FILE_PROCESSED_FLAG -ne 1 ]
		then
		FILE_SIZE=0
		export AMOUNT_SUM_CHK=0
		
		ORIG_FILE_NAME=`echo $line | cut -d'$' -f1`
		echo $ORIG_FILE_NAME >> $LOG_FILE
		file_arrival_dttm=`find $ORIG_FILE_NAME -maxdepth 0 -printf "%TY-%Tm-%Td %TH:%TM\n"`
		echo $file_arrival_dttm >> $LOG_FILE
		FILE_NAME=Validation$ORIG_FILE_NAME
		echo $FILE_NAME >> $LOG_FILE
		cp $ORIG_FILE_NAME $FILE_NAME
		mv $ORIG_FILE_NAME Org_$ORIG_FILE_NAME
   
		echo "File names are" $FILE_NAME >> $LOG_FILE

		echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_insert_step_audit."	>> $LOG_FILE
		export FILE_SIZE=`wc -l $FILE_NAME|awk -F' ' '{print $1}'`
		 		
		l_f_insert_step_audit $STEP_ID "STARTED"
		
		if [ $? -ne 0 ]
		then
		 echo "`PrErrD` : An error occurred in executing l_f_insert_step_audit function." >> $LOG_FILE
		else
		 echo "l_f_insert_step_audit function is successful." >> $LOG_FILE
		 echo "ARC_SRC_LOCATION:"$ARC_SRC_LOCATION >> $LOG_FILE
		fi
	
		 echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_extract_step_log_id."	>> $LOG_FILE
		 
		l_f_extract_step_log_id $STEP_ID $BATCH_DATE "STARTED"
				
		if [ $? -ne 0 ]
		then
			echo "`PrErrD` : An error occurred in executing l_f_extract_step_log_id function." >> $LOG_FILE
		else
			echo "l_f_extract_step_log_id function is successful." >> $LOG_FILE
			STEP_LOG_ID=$l_query_ret
			echo $STEP_LOG_ID >> $LOG_FILE
		fi
		echo $ARC_SRC_LOCATION >> $LOG_FILE
	 
		#Checking whether the file present at landing location is of zero byte. 
		if [ ! -s $ARC_SRC_LOCATION/$FILE_NAME ]
		then
			echo "`PrInfD` :For file $FILE_NAME :File is a zero byte file so will not proceed for any other VALIDATION." >> $LOG_FILE
			export ZERO_BYTE_VALID=N
			export STATUS=FAILED
			#start of writing entry to error data file
			ERR_CD=$Error_Code_ZBF
			ERR_CAT_CD=$Error_Category
            echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
			#close of writing entries to error data file
			l_f_insert_error_audit $ERROR_DATA
		else
				echo "\n `PrInfD` :For file $FILE_NAME :File is not a zero byte file so will proceed for other VALIDATIONS." >> $LOG_FILE
				export ZERO_BYTE_VALID=Y
		fi
			
		# Calculating the file size for file $FILE_NAME			
		
		echo " Number of rows in $FILE_NAME is $FILE_SIZE" >> $LOG_FILE
	
		# Calculating the trailer batch date for file $FILE_NAME	   
		TRAILER_BATCH_DATE=`cat $FILE_NAME | tail -1 | awk -F'~\\\\|' '{print $1}'`
		echo "\n TRAILER_BATCH_DATE : $TRAILER_BATCH_DATE" >> $LOG_FILE
		echo "\n BATCH_DATE : $BATCH_DATE" >> $LOG_FILE
   
		if [ $ZERO_BYTE_VALID = 'Y' -a "$TRAILER_BATCH_DATE" == "$BATCH_DATE" ]
		then
		    
			echo "$STEP_LOG_ID is step log id" >> $LOG_FILE
			#Calling the function l_f_DATE_PATTERN_POS for getting position of date pattern.
			echo "`PrInfD` :For file pattern $FILE_NAME_PATTERN :Calling the function l_f_DATE_PATTERN_POS." >> $LOG_FILE

			l_f_DATE_PATTERN_POS $FILE_NAME_PATTERN $DATE_PATTERN $TIME_PATTERN $FILE_NM_DLIM

			if [ $? -ne 0 ]
			then
				echo "`PrInfD`:Failed to execute the l_f_DATE_PATTERN_POS function." >> $LOG_FILE
			else
				echo "l_f_DATE_PATTERN_POS function is successful." >> $LOG_FILE	
			fi
		
			echo "`PrInfD` :The date pattern pos is : $DATE_PATTERN_POS" >> $LOG_FILE
 
			#Calling the function l_f_file_nm_dt_ptrn_chk to check the file name convention for the date in file name	
			echo "`PrInfD` :For file $FILE_NAME :Calling the function l_f_file_nm_dt_ptrn_chk to check the file name convention for the date in file name." >> $LOG_FILE

			echo "************$FILE_NAME $DATE_PATTERN_POS $TIME_PATTERN_POS $FILE_NM_DLIM $DATE_PATTERN $TIME_PATTERN***************"
			l_f_file_nm_dt_ptrn_chk $FILE_NAME $l_DATE_PATTERN_POS $l_TIME_PATTERN_POS $FILE_NM_DLIM $DATE_PATTERN $TIME_PATTERN
			
			if [ $? -ne 0 ]
			then
				echo "`PrErrD`:For file $FILE_NAME : Failed to execute the l_f_file_nm_dt_ptrn_chk." >> $LOG_FILE
			else
				echo "`PrInfD`:For file $FILE_NAME : The l_f_file_nm_dt_ptrn_chk function to check the file name convention for the date in file name is complete." >> $LOG_FILE
			fi
		
			if [ $ZERO_BYTE_VALID = 'Y' ]
			then
				echo "`PrInfD` :For file $FILE_NAME :Calling the function l_f_trailer_date_pattern_chk to check the Date Pattern in trailer in file $FILE_NAME." >> $LOG_FILE			

				l_f_trailer_date_pattern_chk $TRAILER_BATCH_DATE
			
				if [ $? -ne 0 ]
				then
					echo "`PrErrD`:For file $FILE_NAME : Failed to execute the l_f_trailer_date_pattern_chk." >> $LOG_FILE
				else
					echo "`PrInfD`:For file $FILE_NAME :The l_f_trailer_date_pattern_chk function for trailer date pattern check is complete." >> $LOG_FILE
				fi
			fi
			
			if [ $ZERO_BYTE_VALID = 'Y' -a $TRAILER_AMOUNT_SUM_VALID = 'Y' ]
			then	   
				TRAILER_AMOUNT_SUM_VALID=N
				echo "`PrInfD` :For file $FILE_NAME :Calling the function l_f_trailer_amount_sum_chk to check the trailer amount Sum over the column $TR_AMT_SUM_COL in file $FILE_NAME."	>> $LOG_FILE		

				l_f_trailer_amount_sum_chk $FILE_NAME $TR_AMT_SUM_COL $AMT_SUM_COL_POS
			   
				if [ $? -ne 0 ]
				then
					echo "`PrErrD`:For file $FILE_NAME : Failed to execute the l_f_trailer_amount_sum_chk." >> $LOG_FILE
				else
					echo "`PrInfD`:For file $FILE_NAME :The l_f_trailer_amount_sum_chk function for trailer amount Sum over the column $TRAILER_AMOUNT_SUM_COLUMN is complete." >> $LOG_FILE
				fi
			else
				TRAILER_AMOUNT_SUM_VALID=Y
				echo "`PrInfD`:For file $FILE_NAME :The Trailer amount sum check is not applicable Continuing other validations." >> $LOG_FILE
			fi
				
			if [ $ZERO_BYTE_VALID = 'Y'  -a $TRAILER_RECORD_SUM_VALID = 'Y' ]
			then
				TRAILER_RECORD_SUM_VALID=N
				echo "`PrInfD` :For file $FILE_NAME :Calling the function l_f_trailer_record_sum_chk to check the trailer record Sum over the column $TRAILER_RECORD_SUM_COLUMN in file $FILE_NAME." >> $LOG_FILE		
				echo "FILE_NAME::$FILE_NAME , TRAILER_RECORD_SUM_COLUMN::$TRAILER_RECORD_SUM_COLUMN   " >> $LOG_FILE
				export FILE_SIZE=`expr $FILE_SIZE - 2`
				l_f_trailer_record_sum_chk $FILE_NAME $TRAILER_RECORD_SUM_COLUMN
			
				if [ $? -ne 0 ]
				then
					echo "`PrErrD`:For file $FILE_NAME : Failed to execute the l_f_trailer_record_sum_chk." >> $LOG_FILE
				else
					echo "`PrInfD`:For file $FILE_NAME :The l_f_trailer_record_sum_chk function for trailer record Sum over the column $TRAILER_RECORD_SUM_COLUMN is complete.">> $LOG_FILE
				fi
			else 
				TRAILER_RECORD_SUM_VALID=Y
				echo "`PrInfD`:For file $FILE_NAME :The Trailer record sum check is not applicable Continuing other validations." >> $LOG_FILE
			fi
			 
			if [ $ZERO_BYTE_VALID = 'Y' -a $HEADER_FORMAT_VALID = 'Y' ]
			then
				echo "`PrInfD` :For file $FILE_NAME :Calling the function l_f_header_format_chk to check the format of header record."	>> $LOG_FILE

				echo "\n Header Identifier : $HDR_IDENTIFIER" >> $LOG_FILE
				l_f_header_format_chk $FILE_NAME $HDR_IDENTIFIER 
			
				if [ $? -ne 0 ]
				then
					echo "`PrErrD`:Failed to execute the l_f_header_format_chk function." >> $LOG_FILE
				else
					
					echo "`PrInfD`:The l_f_header_format_chk function for Header format verification is complete." >> $LOG_FILE
				fi
				else
					HEADER_FORMAT_VALID=Y
					echo "`PrInfD`:For file $FILE_NAME :The Header format check is not applicable Continuing other validations." >> $LOG_FILE
				fi
	
				if [ $ZERO_BYTE_VALID = 'Y' ]
				then
					echo "`PrInfD` :For file $FILE_NAME :Calling the function l_f_compare_previous_day_data to check Previous Batch Date file."	>> $LOG_FILE

					l_f_compare_previous_day_data $ARCHIVAL_DIR $FEED_NAME "$LAST_BATCH_DATE" $ORIG_FILE_NAME

					if [ $? -ne 0 ]
					then
						echo "`PrErrD`:Failed to execute the l_f_compare_previous_day_data function." >> $LOG_FILE
					else
						echo "`PrInfD`:The l_f_compare_previous_day_data function to check Previous Batch Date file." >> $LOG_FILE
				fi
			fi
		
			echo " $ZERO_BYTE_VALID $FILE_NAME_DATE_PATTERN_VALID $TRAILER_RECORD_SUM_VALID $TRAILER_AMOUNT_SUM_VALID $HEADER_FORMAT_VALID $PREVIOUS_DATE_COMPARISON" >> $LOG_FILE
			if [ $ZERO_BYTE_VALID = 'Y' -a $FILE_NAME_DATE_PATTERN_VALID = 'Y' -a $TRAILER_RECORD_SUM_VALID = 'Y' -a $TRAILER_AMOUNT_SUM_VALID = 'Y' -a $HEADER_FORMAT_VALID = 'Y' -a $PREVIOUS_DATE_COMPARISON = 'Y' ]
			then
				export STATUS=SUCCESS
				
			 #FILE_SIZE=`wc -l $FILE_NAME|awk -F' ' '{print $1}'`
			 # echo "*********************$FILE_SIZE***********"
			 # cd $ARC_SRC_LOC
			 # cat $FILE_NAME 
				sed -e '$d' $ARC_SRC_LOCATION/$FILE_NAME > $SOURCE_DIR/$ORIG_FILE_NAME
				echo "File validation completed successfully for file $ORIG_FILE_NAME"
			else
				export STATUS=FAILED

			fi
			
			if [ $ZERO_BYTE_VALID = 'N' ] 
			then
				ERR_CD=$Error_Code_ZBF
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
				ZERO_BYTE_VALID=$LOCAL_ZERO_BYTE_VALID
			fi
    
			if [ $FILE_NAME_DATE_PATTERN_VALID = 'N' ] 
			then
				ERR_CD=$Error_Code_FNP
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA

			fi
	
			if [ $PREVIOUS_DATE_COMPARISON = 'N' ] 
			then
				ERR_CD=$Error_Code_PDC
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
			fi
	
			if [ $TRAILER_DATE_PATTERN_VALID = 'N' ] 
			then
				ERR_CD=$Error_Code_TDP
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
			fi
	
			if [ $TRAILER_RECORD_SUM_VALID = 'N' ] 
			then
				ERR_CD=$Error_Code_TRS
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
				TRAILER_RECORD_SUM_VALID=$LOCAL_TRAILER_RECORD_SUM_VALID
			fi
	
			if [ $TRAILER_AMOUNT_SUM_VALID = 'N' ] 
			then
				ERR_CD=$Error_Code_TAS
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
				TRAILER_AMOUNT_SUM_VALID=$LOCAL_TRAILER_AMOUNT_SUM_VALID
			fi
	
			if [ $HEADER_FORMAT_VALID = 'N' ] 
			then
				ERR_CD='HDR'
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
				HEADER_FORMAT_VALID=$LOCAL_HEADER_FORMAT_VALID
			fi
	
		else
			if [ $ZERO_BYTE_VALID = 'Y' ]
			then
			    ERR_CD=$Error_Code_TBND
				ERR_CAT_CD=$Error_Category
				export STATUS=FAILED
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|$FILE_NAME|$BATCH_DATE" >> $ERROR_DATA
				echo "`PrInfD` :File name $FILE_NAME is of $TRAILER_BATCH_DATE. Batch date should have been $BATCH_DATE." >> $LOG_FILE
			fi
		fi	
		#Calling the function l_f_archive_files for archiving the files 
		echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_archive_files."	>> $LOG_FILE
		echo "`PrInfD` SCRIPT_DIR:$SCRIPT_DIR."	>> $LOG_FILE	

		echo "$FILE_NAME $ORIG_FILE_NAME $FEED_NAME $BATCH_DATE"
		l_f_archive_files $FILE_NAME $ORIG_FILE_NAME $FEED_NAME $BATCH_DATE

		echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_insert_feed_audit."	>> $LOG_FILE
		echo "$STEP_LOG_ID, $FEED_ID,$FILE_SIZE ,$FILE_NAME, $BATCH_DATE , $AMOUNT_SUM_CHK ,$file_arrival_dttm ">> $LOG_FILE
		l_f_insert_feed_audit $STEP_LOG_ID $FEED_ID "$FILE_SIZE" $ORIG_FILE_NAME $BATCH_DATE "$file_arrival_dttm" $AMOUNT_SUM_CHK ""
		
		if [ $? -ne 0 ]
		then
			echo "`PrErrD` : An error occurred in executing l_f_insert_feed_audit function." >> $LOG_FILE
		else
			echo "`PrInfD`:l_f_insert_feed_audit function for inserting into Feed Audit Table is complete." >> $LOG_FILE
		fi
	
		#Calling the function l_f_update_step_audit for updating fwk_step_audit table.	

		l_f_update_step_audit $STEP_ID $STATUS $FILE_NAME "" "VALIDATION_FILE"
		if [ $? -ne 0 ]
		then
			echo "`PrErrD` : An error occurred in executing l_f_update_step_audit function." >> $LOG_FILE
		else
			echo "`PrInfD`:l_f_update_step_audit function for updating into Step Audit Table is complete." >> $LOG_FILE
			
		fi	
		
		if [ $STATUS == 'SUCCESS' ]
		then
			FILE_PROCESSED_FLAG=`expr $FILE_PROCESSED_FLAG + 1`
		fi
		
		if [ $STATUS == 'FAILED' ]
		then
			#calling function to insert entries to error tables--l_f_insert_error_audit
			echo "`PrInfD` :For file name $FILE_NAME :Calling the function l_f_insert_error_audit."	>> $LOG_FILE
			l_f_insert_error_audit  $ERROR_DATA
			#start of function return check--l_f_insert_error_audit
			if [ $? -ne 0 ]
			then
				echo "`PrErrD` : An error occurred in executing l_f_insert_error_audit function." >> $LOG_FILE
			else
				echo "`PrInfD`:l_f_insert_error_audit function for updating into Step Audit Table is complete." >> $LOG_FILE
			fi 
			echo "File validation failed for $ORIG_FILE_NAME"
			echo "File Validation Failed for File: $ORIG_FILE_NAME for BATCH_DATE: $BATCH_DATE." > $TMP_DIR/Mail_Content.txt
			echo "Mail Subject : $MAIL_SUBJECT Mail Recipients: $MAIL_RECIPIENT " >> $LOG_FILE
			echo "Mail Sent " >> $LOG_FILE
			echo "Open Attachment for details" | mail -s File_Validation_Failed -a $TMP_DIR/Mail_Content.txt  delightsimmy@gmail.com
		
		fi 		
	
	
	unset FILE_SIZE
	unset AMOUNT_SUM_CHK
	unset STATUS
	unset FILE_NAME
	unset STEP_LOG_ID
else
exit 0
fi 
done	< $TMP_DIR/$FILE_LIST
if [ $FILE_PROCESSED_FLAG -eq 0 ]
then 
exit 1
fi



done
