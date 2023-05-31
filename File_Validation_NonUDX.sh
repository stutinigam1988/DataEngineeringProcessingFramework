#shell Script Name         : File_Validation_NonUDX.sh     
#shell Script Name         : File_Validation_NonUDX.sh     
#
# Author                    : Stuti Nigam                     
#
# Date                      : 13APR2014               
#
# Description/Object        : Script for File Validation of Non UDX format files
#                                             
# Parameters                : Step Id           
#                                             
# History                    :
#
#  DATE                 VERSION                              CHANGED BY                     CHANGE DESCRIPTION
#  --------------------------------------------------------------------------------------------------------------------------
#  
#
#===============================================================================================================================#


#####################  MAIN  #############################


#expanding alias
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
# Getting the name of the script
script_name=$( basename $0 )
#Defining Date and Time format applicable to this session of script
DATE_PATTERN=YYYYMMDD
TIME_PATTERN=HHMISS
#Calling configuration file 
. /u02/Scripts/Configuration_File.cfg
#Calling Function file
. $SCRIPT_DIR/File_Validation_functions.sh

#Creating log file Variable for this session of script run
export LOG_FILE=$LOG_DIR/File_validation_NonUDX_"$1"_`date +%Y-%m-%d-%H_%M_%S`.log
#Creating log file for this session run
touch $LOG_FILE
#creating error data file
export ERROR_DATA=$TMP_DIR/error_data_nonUDX_"$1"_`date +%Y-%m-%d-%H_%M_%S`.txt
touch $ERROR_DATA
FILE_NAME=File_Names_nonUDX
export FILE_LIST=$TMP_DIR/"$FILE_NAME"_"$1"_`date +%N`
touch $FILE_LIST
echo "$FILE_LIST is file list file after modifications"
#Trigger message for start of script written to Log file
echo "Process Started...." > $LOG_FILE
echo "SCRIPT NAME: $script_name" >> $LOG_FILE

#STEP ID is the parameter for this script
#start of loop for step id
for STEP_ID in "$@"
do

		echo "Step Id is : $STEP_ID" >> $LOG_FILE

		############################################################"
		#Extraction of feed and Batch related information starts here"
		#############################################################"
		
		#creating supply info file to get details about the file
		#start of function to create temporary supply info file--l_f_create_framework_info
		echo "`PrInfD` :Creating the Feed info file $SUPPLY_FILE_DIR/$SUPPLY_FILE_NAME ." >> $LOG_FILE
		l_f_create_framework_info $STEP_ID 
		#start of function return check--l_f_create_framework_info
		
		if [ $? -ne 0 ]
		then
			echo "`PrErrD` : An error occurred in executing l_f_create_framework_info function to create feed information"
		else
			FEED_INFO="$l_query_ret"
			#$l_query_ret > $TMP_DIR/file_list_nonUDX.txt
		
		#close of function return check--l_f_create_framework_info
		#close of function to create temporary supply info file--l_f_create_framework_info
			
		#tr -d "\n\r" < $TMP_DIR/file_list_nonUDX.txt > $SUPPLY_FEED_INFO_FILE
		#Start of Obtaining Feed parameters from supply_info_file and assigning to script parameters
		
		FEED_NAME=`echo "$FEED_INFO" | cut -d'$' -f1`
		FILE_DLIM=`echo $FEED_INFO | cut -d'$' -f2`
		TRAILER_RECORD_SUM_COLUMN=`echo $FEED_INFO | cut -d'$' -f3`
		FILE_NM_DLIM=`echo $FEED_INFO | cut -d'$' -f4`
		HDR_IDN_COL_POS=`echo $FEED_INFO | cut -d'$' -f5`
		HDR_IDENTIFIER=`echo $FEED_INFO | cut -d'$' -f6`
		TRL_IDN_COL_POS=`echo $FEED_INFO | cut -d'$' -f7`
		TRL_IDENTIFIER=`echo $FEED_INFO | cut -d'$' -f8`
		RECORD_TYPE_COL_POS=`echo $FEED_INFO | cut -d'$' -f9`
		AMT_SUM_COL_POS=`echo $FEED_INFO | cut -d'$' -f10`
		FILE_NAME_PATTERN=`echo $FEED_INFO | cut -d'$' -f11`
		SOURCE_SYSTEM_ID=`echo $FEED_INFO | cut -d'$' -f12`
		TR_AMT_SUM_COL=`echo $FEED_INFO | cut -d'$' -f13`
		ARC_SRC_LOCATION=`echo $FEED_INFO | cut -d'$' -f14`
		FEED_SUB_TYPE=`echo $FEED_INFO | cut -d'$' -f15`
		FILE_DT_IDENTIFIER=`echo $FEED_INFO | cut -d'$' -f16`
		START_REC_CNT_POS=`echo $FEED_INFO | cut -d'$' -f17`
		END_REC_CNT_POS=`echo $FEED_INFO | cut -d'$' -f18`
		DATE_START_POS=`echo $FEED_INFO | cut -d'$' -f19`
		DATE_END_POS=`echo $FEED_INFO | cut -d'$' -f20`
		FEED_ID=`echo $FEED_INFO | cut -d'$' -f21`
		BATCH_DATE=`echo $FEED_INFO | cut -d'$' -f22`
		LAST_BATCH_DATE=`echo $FEED_INFO | cut -d'$' -f23`
		SOURCE_SYSTEM_NAME=`echo $FEED_INFO | cut -d'$' -f24`
		ZERO_BYTE_VALID=`echo $FEED_INFO | cut -d'$' -f25`
		TRAILER_RECORD_SUM_VALID=`echo $FEED_INFO | cut -d'$' -f26`
		TRAILER_AMOUNT_SUM_VALID=`echo $FEED_INFO | cut -d'$' -f27`
		HEADER_FORMAT_VALID=`echo $FEED_INFO | cut -d'$' -f28`
		TRAILER_FORMAT_VALID=`echo $FEED_INFO | cut -d'$' -f29`
		FL_NM_PATTERN_VALID=`echo $FEED_INFO | cut -d'$' -f30`
		ACTUAL_LOC=`echo $FEED_INFO | cut -d'$' -f31`
		FEED_NAME_BN=`echo "$FEED_INFO" | cut -d'$' -f32`
		TAB_NAME=`echo "$FEED_INFO" | cut -d'$' -f33`
		INPUT_FILE_TYPE=`echo "$FEED_INFO" | cut -d'$' -f34`
		
		echo "$FEED_NAME_BN) is feed name for this"
		#Close of obtaining Feed parameters from supply_info_file and assigning to script parameters
		############################################################
		# Extraction of file and batch related information ends here
		############################################################
		fi
		###############################
		#Validation Process starts here
		###############################
		echo "$ARC_SRC_LOCATION for here"
		#Redirecting the path to Landing Directory
echo "$BATCH_DATE is bdate   $FEED_NAME "  >> $LOG_FILE
	if [ $FEED_SUB_TYPE == 'ExchangeRate' ]
	then
		year=`echo $BATCH_DATE | cut -c 1-4`
		month=`echo $BATCH_DATE | cut -c 5-6`
		day=`echo $BATCH_DATE | cut -c 7-8`
		SEARCH_FILE_NAME="$FEED_NAME-$year-$month-$day"
	elif [ $FEED_SUB_TYPE = 'BISNODE' ]
		then
		echo "$FEED_NAME_BN"
		SEARCH_FILE_NAME="$FEED_NAME_BN $BATCH_DATE"
		echo "$FEED_NAME is feed name"
		echo "$SEARCH_FILE_NAME**is search file"
	fi
	
	if [ $FEED_SUB_TYPE = 'ExchangeRate'  -o $FEED_SUB_TYPE = 'BISNODE' ] 
	then
		 echo "$SEARCH_FILE_NAME is search file" >> $LOG_FILE
		l_f_pick_files "$SEARCH_FILE_NAME"
	
			#start of function return check --l_f_insert_step_audit
		if [ $? -ne 0 ]
		then
				echo "`PrErrD`: An error occurred in fetching relevant files" >> $LOG_FILE
		else
                echo "`PrInfD`:files fetched successfully" >> $LOG_FILE
			 
			#close of function return check--l_f_insert_step_audit
            #close of function call to insert entry into step audit--l_f_insert_step_audit
		
			if [ $FILE_PRESENT = 'Y' ]
			then
				
				echo "$FILE_NAME_TO_COPY" >> $LOG_FILE
				cp "$FILE_NAME_TO_COPY" $ARC_SRC_LOCATION
				
			else
				echo "No file found for this batch date in actual source location. Script will not proceed further" >> $$LOG_FILE
			fi
		fi

		cd $ARC_SRC_LOCATION
		echo "$ARC_SRC_LOCATION" >> $LOG_FILE
		echo "$FILE_NAME_TO_COPY -- $ARC_SRC_LOCATION"  >> $LOG_FILE
			CONV_FILE=`echo "$FILE_NAME_TO_COPY" | tr " " "_"`
			
			mv "$FILE_NAME_TO_COPY" "$CONV_FILE" 
			echo "$CONV_FILE is converted file and it is present here" >> $LOG_FILE
			
		echo "Landing Location : $ARC_SRC_LOCATION" >> $LOG_FILE
	fi
		
		cd $ARC_SRC_LOCATION
		
		echo "outside bisnode and bloomberg loop"
		
		#Searching for feed pattern files and moving them to file
		
		echo "($FEED_NAME) **is feed name for this run" >> $LOG_FILE
		
		ls "$FEED_NAME"* >> $LOG_FILE
		
		echo "ILE_LIST ::$FILE_LIST"
		
		ls "$FEED_NAME"* > $FILE_LIST
		
		echo "FILE_LIST ::$FILE_LIST"
		
		#Checking for absence of files for FEED_NAME (pattern) fetched above. 
		#Files with specific pattern are  searched and copied to file from which file names will be fetched for loop processing	
		
		if [ ! -s $FILE_LIST ]
		then
			 echo "`PrInfD`:No File found for Feed $FEED_NAME at Landing Location $ARC_SRC_LOCATION" 
			 echo "`PrInfD`:No File found for Feed $FEED_NAME at Landing Location $ARC_SRC_LOCATION" >> $LOG_FILE
			# start of function call to insert entry into step audit table to mark start of step-l_f_insert_step_audit
			l_f_insert_step_audit $STEP_ID "STARTED"
			#start of function return check --l_f_insert_step_audit
			if [ $? -ne 0 ]
			then
				echo "`PrErrD`: An error occurred in executing l_f_insert_step_audit function." >> $LOG_FILE
			else
                echo "`PrInfD`:l_f_insert_step_audit function is successful." >> $LOG_FILE
			fi 
			#close of function return check--l_f_insert_step_audit
            #close of function call to insert entry into step audit--l_f_insert_step_audit
			
			#start of function call to  extract step_log_id for that step (only status started) --l_f_extract_step_log_id
			l_f_extract_step_log_id $STEP_ID $BATCH_DATE "STARTED"
			
			#start of function return check --l_f_extract_step_log_id
            if [ $? -ne 0 ]
			then
			    echo "`PrErrD` : An error occurred in executing l_f_extract_step_log_id function." >> $LOG_FILE
            else
                echo "`PrInfD`:l_f_extract_step_log_id function is successful." >> $LOG_FILE
				STEP_LOG_ID=$l_query_ret 
				
			fi
			#close of function return check--l_f_extract_step_log_id
            #close of function call to extract step_log_id --l_f_extract_step_log_id
			
			# start of function call to update entry into step audit table to mark failure of step-l_f_update_step_audit
			
			
			l_f_update_step_audit $STEP_ID "FAILED" "NOFILE" "" "NO_FILE"
			#start of function return check --l_f_update_step_audit
			if [ $? -ne 0 ]
			then
				echo "`PrErrD`: An error occurred in executing l_f_update_step_audit function." >> $LOG_FILE
			else
                echo "`PrInfD`:l_f_update_step_audit function is successful." >> $LOG_FILE
            fi 
			#close of function return check--l_f_update_step_audit
            #close of function call to insert entry into step audit--l_f_update_step_audit
			
			#start of writing entry to error data file
			ERR_CD=$Error_Code_FNF
			ERR_CAT_CD=$Error_Category
            echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|" "|$BATCH_DATE" > $ERROR_DATA
			#close of writing entries to error data file
			l_f_insert_error_audit $ERROR_DATA
                    #start of function return check--l_f_insert_error_audit
                    if [ $? -ne 0 ]
                    then
                                                                
                    echo "`PrErrD` : An error occurred in executing l_f_update_step_audit function." >> $LOG_FILE
                    else
                    echo "`PrInfD`:l_f_update_step_audit function for updating into Step Audit Table is complete." >> $LOG_FILE
                    fi 
                    #close of function return check--l_f_insert_error_audit
                    #close of function --l_f_insert_error_audit
		fi             
		#close of moving files to file name list
		FILE_PROCESSED_FLAG=0			
		while read line 
		do
		
		
		if [ $FILE_PROCESSED_FLAG -ne 1 ]
		then
		FILE=`echo "$line" | cut -d'$' -f1`
		#Writing the name of currently processed file name to log file
			echo "`PrInfD`:File with file name :$FILE is found and fetched for processing "  >> $LOG_FILE
			file_arrival_dttm=`find "$FILE" -maxdepth 0 -printf "%TY-%Tm-%Td %TH:%TM\n"`
			
			#Rename the file to append Org 
			ORIG_FILE_NAME=Org_"$FILE"
			mv "$FILE" "$ORIG_FILE_NAME"
			echo "$ORIG_FILE_NAME is the original renamed file"  >> $LOG_FILE
			FILE_RENAMED=Validation"$FILE"
			touch "$FILE_RENAMED"
			cat "$ORIG_FILE_NAME" > "$FILE_RENAMED"
			echo "$FILE_RENAMED is the validation file" >> $LOG_FILE
			#Handling file name pattern for exchange rate file
			FILE_NAME=`echo "$FILE_RENAMED" | sed 's/-/_/4' | sed 's/-/_/1' | sed 's/-//g' `
			
			touch "$FILE_NAME"
			mv "$FILE_RENAMED" "$FILE_NAME"
			
			# start of function call to insert entry into step audit table to mark beginning of step-l_f_insert_step_audit
			l_f_insert_step_audit $STEP_ID "STARTED"
			#start of function return check --l_f_insert_step_audit
			if [ $? -ne 0 ]
			then
				echo "`PrErrD`: An error occurred in executing l_f_insert_step_audit function." >> $LOG_FILE
			else
                echo "`PrInfD`:l_f_insert_step_audit function is successful." >> $LOG_FILE
            fi 
			#close of function return check--l_f_insert_step_audit
            #close of function call to insert entry into step audit--l_f_insert_step_audit
            			
			#start of function call to  extract step_log_id for that step (only status started) --l_f_extract_step_log_id
			l_f_extract_step_log_id $STEP_ID $BATCH_DATE "STARTED"
			#start of function return check --l_f_extract_step_log_id
            if [ $? -ne 0 ]
			then
			    echo "`PrErrD` : An error occurred in executing l_f_extract_step_log_id function." >> $LOG_FILE
            else
                echo "`PrInfD`:l_f_extract_step_log_id function is successful." >> $LOG_FILE
				STEP_LOG_ID=$l_query_ret 
			fi
			#close of function return check--l_f_extract_step_log_id
            #close of function call to extract step_log_id --l_f_extract_step_log_id
						
			#Starting validation of zero byte file
			if [ ! -s "$FILE_NAME" ]
            then  
                echo "`PrInfD`:For file "$FILE" :File is a zero byte file so will not proceed for any other VALIDATION." >> $LOG_FILE
				
                export ZERO_BYTE_VALID=N
				
				echo "File Validation Failed for File: "$FILE" for BATCH_DATE: $BATCH_DATE" > $TMP_DIR/Mail_Content.txt
				echo "`PrInfD`:Mail Subject : $MAIL_SUBJECT Mail Recipients: $MAIL_RECIPIENT " >> $LOG_FILE
  				echo "Mail Sent " >> $LOG_FILE
				echo "Open Attachment for details" | mail -s File_Validation_Failed -a $TMP_DIR/Mail_Content.txt  delightsimmy@gmail.com
					AMT_SUM_CHK=0			
				#start of function call to make entry into feed audit--l_f_insert_feed_audit
				l_f_insert_feed_audit $STEP_LOG_ID $FEED_ID 0 "$FILE" $BATCH_DATE "$file_arrival_dttm" $AMT_SUM_CHK ""
				# start of function return check--l_f_insert_feed_audit
				if [ $? -ne 0 ]
				then
					echo "`PrErrD` : An error occurred in executing l_f_insert_feed_audit function." >> $LOG_FILE
				else
					echo "`PrInfD`: l_f_insert_feed_audit function for inserting into Feed Audit Table is complete." >> $LOG_FILE
				fi
                #close of function return check--l_f_insert_feed_audit
                #close of function call to insert entry into feed audit table
							
            else
                echo "`PrInfD` :For file $FILE :File is not a zero byte file so will proceed for other VALIDATIONS." >> $LOG_FILE
                echo "$FEED_ID : $BATCH_ID :"$FILE" : ZERO_BYTE_CHK : VALIDATED" >> $LOG_FILE
                export ZERO_BYTE_VALID=Y                                                                  
            fi
			echo "`PrInfD`:Value for Zero byte flag is $ZERO_BYTE_VALID" >> $LOG_FILE
			# ending validation of zero byte file 
			
			
			#starting validations for non zero byte files  
            if [ $ZERO_BYTE_VALID = 'Y' ]
			then
				#starting header and footer validations for incoming files
				#starting header validations for incoming files
				if [ $HEADER_FORMAT_VALID = 'Y' ] 
				then
				#start of function call to check header format--l_f_header_format_chk
				
				l_f_header_format_chk_nonUdX "$FILE_NAME" $HDR_IDENTIFIER $FEED_SUB_TYPE
				#start of function return check for header--l_f_header_format_chk
				if [ $? -ne 0 ]
                then
					echo "`PrErrD`:For file $VALIDATION_FILE : Failed to execute the l_f_header_format_chk" >> $LOG_FILE
				else
					echo "`PrInfD`:For file $VALIDATION_FILE : The l_f_header_format_chk function to check the file name convention for the date in file name is complete." >> $LOG_FILE
					echo "`PrInfD`:$HEADER_FORMAT_VALID is validation flag for header" >> $LOG_FILE
				fi
				else
				export HEADER_FORMAT_VALID='Y'
				fi
				#close of function return check--l_f_header_format_chk
				#close of function call to check header format--l_f_header_format_chk
				
				
				# starting footer validations for incoming files
				if [ $TRAILER_FORMAT_VALID = 'Y' ] 
				then
				#start of function call to check footer format--l_f_footer_format_chk
				l_f_footer_format_chk_nonUdX "$FILE_NAME" $TRL_IDENTIFIER $FEED_SUB_TYPE
				#start of function return check--l_f_footer_format_chk
				
		
				if [ $? -ne 0 ]
                then
                    echo "`PrErrD`:For file $VALIDATION_FILE : Failed to execute the l_f_file_nm_dt_ptrn_chk." >> $LOG_FILE
				else
                    echo "`PrInfD`:For file $VALIDATION_FILE : The l_f_file_nm_dt_ptrn_chk function to check the file name convention for the date in file name is complete." >> $LOG_FILE
                 	echo "`PrInfD`:$TRAILER_FORMAT_VALID is the flag for validation of trailer " >> $LOG_FILE
				fi
				else
				export TRAILER_FORMAT_VALID='Y'
				fi
				#close of function return check--l_f_footer_format_chk
				#close of function call to check footer format--l_f_footer_format_chk
								
				
				#Calling function to insert Rundate in feed audit table
				#calculating File Size and removing header footer(only exchange rate) of incoming file
				if [ "$FEED_SUB_TYPE" == "ExchangeRate" ] 
				then
					#obtaining trailer batch date from file contents
					TRAILER_BATCH_DATE=`grep "$FILE_DT_IDENTIFIER" "$FILE_NAME" | cut -c $DATE_START_POS-$DATE_END_POS`
					#Calling function to insert Rundate in feed audit table
				
					if [ $TRAILER_BATCH_DATE -eq $BATCH_DATE ] 
                    then
					export TRAILER_DATE_PATTERN_VALID=Y
                        
					else
						export TRAILER_DATE_PATTERN_VALID=N
					fi
						
					if [ $HEADER_FORMAT_VALID == "Y" -a $TRAILER_FORMAT_VALID == "Y" ] 
					then
						var_start=`grep -n "$HDR_IDENTIFIER" "$FILE_NAME"  |  awk -F':' '{print $1}'`
						var_end=`grep -n "$TRL_IDENTIFIER" "$FILE_NAME"  |  awk -F':' '{print $1}'`
						var_start_data=`expr $var_start + 1`
						var_end_data=`expr $var_end - 1`
						eval sed -e '${var_start_data},${var_end_data}!d' "$ORIG_FILE_NAME" > "$FILE_NAME"
						export FILE_SIZE=`wc -l "$FILE_NAME" |awk -F' ' '{print $1}'`
					else
						export FILE_SIZE=0
					fi
				elif [ "$FEED_SUB_TYPE" == "ENTRA" ]
				
					then
					#obtaining trailer batch date from file contents
					TRAILER_BATCH_DATE=`grep "$FILE_DT_IDENTIFIER" "$FILE_NAME" | cut -c $DATE_START_POS-$DATE_END_POS`
					#Calling function to insert Rundate in feed audit table
					BATCH_DATE_TOMM=$BATCH_DATE
					
					echo "$TRAILER_BATCH_DATE and $BATCH_DATE_TOMM are values"
					if [ $TRAILER_BATCH_DATE -eq $BATCH_DATE_TOMM ] 
                    then
					export TRAILER_DATE_PATTERN_VALID=Y
                        
					else
						export TRAILER_DATE_PATTERN_VALID=N
					fi
					if [ $HEADER_FORMAT_VALID == "Y" -a $TRAILER_FORMAT_VALID == "Y" ] 
					then
						FILE_COUNT=`wc -l "$FILE_NAME" |awk -F' ' '{print $1}'`
						export FILE_SIZE=`expr $FILE_COUNT - 2`
					else
						export FILE_SIZE=0
					fi
			else
					TRAILER_BATCH_DATE=""
					export TRAILER_DATE_PATTERN_VALID=Y
					if [ $HEADER_FORMAT_VALID == "Y" -a $TRAILER_FORMAT_VALID == "Y" ] 
					then
						FILE_COUNT=`wc -l "$FILE_NAME" |awk -F' ' '{print $1}'`
						export FILE_SIZE=`expr $FILE_COUNT - 2`
					else
						export FILE_SIZE=0
					fi
				fi				
                #closing File Size calculation and header footer removal
				export AMT_SUM_CHK=0
				echo "$STEP_LOG_ID $FEED_ID $FILE_SIZE "$FILE" $BATCH_DATE "$file_arrival_dttm" $AMT_SUM_CHK "$TRAILER_BATCH_DATE" "
				#start of function call to make entry into feed audit--l_f_insert_feed_audit
				echo "$STEP_LOG_ID $FEED_ID $FILE_SIZE "$FILE" $BATCH_DATE "$file_arrival_dttm" $AMT_SUM_CHK "$TRAILER_BATCH_DATE" are here"
				l_f_insert_feed_audit $STEP_LOG_ID $FEED_ID $FILE_SIZE "$FILE" $BATCH_DATE "$file_arrival_dttm" $AMT_SUM_CHK "$TRAILER_BATCH_DATE"
				
                #start of function return check--l_f_insert_feed_audit
				if [ $? -ne 0 ]
				then
                    
					echo "`PrErrD` : An error occurred in executing l_f_insert_feed_audit function." >> $LOG_FILE
				else
                    
                    echo "`PrInfD`: l_f_insert_feed_audit function for inserting into Feed Audit Table is complete." >> $LOG_FILE
				fi
                #close of function return check--l_f_insert_feed_audit
                #close of function call to insert entry into feed audit table
		
				 if [ $INPUT_FILE_TYPE == "XLS" ] 
				 then
				
				l_f_xls_to_text "$FILE_NAME" "$FILE" "$TAB_NAME"
				 
				 if [ $? -ne 0 ]
				 then
                    
					 echo "`PrErrD` : An error occurred in executing l_f_xls_to_text function." >> $LOG_FILE
					 export STATUS='FAILED'
				 else
                    
                     echo "$PrInfD : l_f_xls_to_text function  is complete." >> $LOG_FILE
					 export STATUS='SUCCESS'
				 fi
				 echo "$FILE_RENAMED $FILE $FEED_NAME $BATCH_DATE for bis"
				
				 fi
				
				if [ $INPUT_FILE_TYPE != "XLS" ] 
				then
				echo "bis node not"
				# starting file name level validations
				#start of function call to obtain date and time pattern in the file name--l_f_DATE_PATTERN_POS
				l_f_DATE_PATTERN_POS "$FILE_NAME_PATTERN" $DATE_PATTERN $TIME_PATTERN $FILE_NM_DLIM
				#start of function return check--l_f_DATE_PATTERN_POS
                if [ $? -ne 0 ]
                then
                    echo "`PrInfD`:Failed to execute the l_f_DATE_PATTERN_POS function." >> $LOG_FILE
                else
					echo "`PrInfD`:l_f_DATE_PATTERN_POS function is successful." >> $LOG_FILE               
                    
					echo "`PrInfD` :The date pattern position is : $DATE_PATTERN_POS" >> $LOG_FILE
					echo "`PrInfD` :The time pattern position is : $TIME_PATTERN_POS" >> $LOG_FILE
					
                fi                                                
                #close of function return check--l_f_DATE_PATTERN_POS
				#close of function call to obtain date time position--l_f_DATE_PATTERN_POS
				
				#start of function call to check date time pattern in file name--l_f_file_nm_dt_ptrn_chk
				echo "`PrInfD` :For file $VALIDATION_FILE :Calling the function l_f_file_nm_dt_ptrn_chk to check the file name convention for the date in file name." >> $LOG_FILE
				
				if [ $FL_NM_PATTERN_VALID = 'Y' ] 
				then
				l_f_file_nm_dt_ptrn_chk "$FILE_NAME" $l_DATE_PATTERN_POS $l_TIME_PATTERN_POS $FILE_NM_DLIM $DATE_PATTERN $TIME_PATTERN $FEED_SUB_TYPE
                #start of function return check--l_f_file_nm_dt_ptrn_chk  
                if [ $? -ne 0 ]
                then
                    echo "`PrErrD`:For file $VALIDATION_FILE : Failed to execute the l_f_file_nm_dt_ptrn_chk." >> $LOG_FILE
				else
                    echo "`PrInfD`:For file $VALIDATION_FILE : The l_f_file_nm_dt_ptrn_chk function to check the file name convention for the date in file name is complete." >> $LOG_FILE
                    
				fi
				else 
				export FILE_NAME_DATE_PATTERN_VALID=Y
				fi
				#close of function return check --l_f_file_nm_dt_ptrn_chk
				#close of function call to check date time pattern in file name--l_f_file_nm_dt_ptrn_chk
							
				#closing file level validations
				#starting validations of Entra files
				if [ $FEED_SUB_TYPE == "ENTRA" ] 
                then 
					#start of function call to check record count--l_f_trailer_rec_cnt_chk
                    if [ $TRAILER_FORMAT_VALID == "Y" -a  $HEADER_FORMAT_VALID == "Y" ] 
					then
					
					l_f_trailer_rec_cnt_chk_nonUDX "$FILE_NAME" $FILE_SIZE $TRL_IDENTIFIER $START_REC_CNT_POS $END_REC_CNT_POS
					#start of function return check--l_f_trailer_rec_cnt_chk
                    if [ $? -ne 0 ]
					then
						echo "`PrErrD` : An error occurred in executing the function l_f_trailer_rec_cnt_chk." >> $LOG_FILE
 					else
						echo " `PrInfD`:l_f_trailer_rec_cnt_chk function is successful." >> $LOG_FILE
					fi
					#close of function return check--l_f_trailer_rec_cnt_chk
					#close of function --l_f_trailer_rec_cnt_chk
					else 
					
					export TRAILER_RECORD_SUM_VALID=N
					fi
					
				else
				export TRAILER_RECORD_SUM_VALID=Y
				fi
				#closing validations for Entra  file
			
			
			#zero byte if closed here
			#closing validations for Files
			
			############################
			#Validation Process ended
			############################
			echo "$LAST_BATCH_DATE"
			#calling function to check for previous day data--l_f_compare_previous_day_data
			l_f_compare_previous_day_data_nonUDX $ARCHIVAL_DIR "$FEED_NAME" "$LAST_BATCH_DATE" "$ORIG_FILE_NAME"  
			 # start of function return check--l_f_compare_previous_day_data
			if [ $? -ne 0 ] 
			then
				echo "`PrErrD` : An error occurred in executing l_f_compare_previous_day_data" >> $LOG_FILE
              
			else
				
                echo "`PrInfD`:l_f_compare_previous_day_data function for inserting into Error Audit Table is complete" >> $LOG_FILE
			fi
			#close of function return check--l_f_compare_previous_day_data
			#closing function to check for previous day data--l_f_compare_previous_day_data
			cd $ARC_SRC_LOCATION
			###############################################
			#starting entries of  files in framework tables
			###############################################
			#starting entries of files in error file 
						
			#check for validity of file name date pattern
            if [ $FILE_NAME_DATE_PATTERN_VALID = 'N' ] 
            then
				ERR_CD=$Error_Code_FNP
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" > $ERROR_DATA
            else
				echo "`PrInfD`:No error in File name pattern" >> $LOG_FILE         
            fi
			#closing validity check for file name date pattern
			#starting validity check for trailer record sum
            if [ $TRAILER_RECORD_SUM_VALID = 'N' ] 
            then
                ERR_CD=$Error_Code_TRS
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" >> $ERROR_DATA
            else
				echo "`PrInfD`:No error in trailer record sum" >> $LOG_FILE         
            fi
			#close of validity check for trailer record sum
			#start validity check of trailer date pattern
            if [ $TRAILER_DATE_PATTERN_VALID = 'N' ] 
            then
				ERR_CD=$Error_Code_TDP
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" >> $ERROR_DATA
            else
				echo "`PrInfD`:No error in trailer date pattern" >> $LOG_FILE         
            fi
			#close validity of trailer date pattern
			#start validity check of trailer format
            if [ $TRAILER_FORMAT_VALID = 'N' ] 
            then
                ERR_CD=$Error_Code_TFP
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" >> $ERROR_DATA
            else
				echo "`PrInfD`:No error in trailer date pattern" >> $LOG_FILE         
            fi
			#close validity of trailer format check
			#start validity of header format check
            if [ $HEADER_FORMAT_VALID = 'N' ] 
            then
                ERR_CD=$Error_Code_HFP
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" >> $ERROR_DATA
            else
				echo "`PrInfD`:No error in header format for this file"    >> $LOG_FILE         
            fi
			#closing validity of header format check
			#starting entry of zero byte file in error file
			
			#closing entry of files in error file
			#starting entry of prev day comp in error file
			if [ $PREVIOUS_DATE_COMPARISON = 'N' ] 
            then
                ERR_CD=$Error_Code_PDC
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" >> $ERROR_DATA
            else
				echo "`PrInfD`:Previous day comparison is successful" >> $LOG_FILE         
            fi
	fi
	#close non bisnode fnc
fi
			echo "$ZERO_BYTE_VALID IS ZBF==  $FILE_NAME_DATE_PATTERN_VALID IS FNDP==  $TRAILER_DATE_PATTERN_VALID IS TDP==   $PREVIOUS_DATE_COMPARISON IS PDC ==  $TRAILER_RECORD_SUM_VALID IS TRS  == $HEADER_FORMAT_VALID IS HFV == $TRAILER_FORMAT_VALID  IS TFV== "
			#starting update entry of file in step audit
			if [ $ZERO_BYTE_VALID = 'N' ] 
            then
                ERR_CD=$Error_Code_ZBF
				ERR_CAT_CD=$Error_Category
				echo "$STEP_LOG_ID|$ERR_CD|$ERR_CAT_CD|"$FILE"|$BATCH_DATE" >> $ERROR_DATA
            else
				echo "`PrInfD`:File is not a zero byte file" >> $LOG_FILE         
            fi
			if [ $ZERO_BYTE_VALID == "N" -a "$INPUT_FILE_TYPE" == 'XLS' ] 
			then
			export STATUS=FAILED
			fi
			if [ "$INPUT_FILE_TYPE" != 'XLS' ]
			then
			echo " $ZERO_BYTE_VALID == "Y" -a  $FILE_NAME_DATE_PATTERN_VALID == "Y" -a  $TRAILER_DATE_PATTERN_VALID == "Y" -a  $PREVIOUS_DATE_COMPARISON == "Y" -a  $TRAILER_RECORD_SUM_VALID  == "Y" -a  $HEADER_FORMAT_VALID == "Y" -a  $TRAILER_FORMAT_VALID == "Y" ">>$LOG_FILE
			if [ $ZERO_BYTE_VALID == "Y" -a  $FILE_NAME_DATE_PATTERN_VALID == "Y" -a  $TRAILER_DATE_PATTERN_VALID == "Y" -a  $PREVIOUS_DATE_COMPARISON == "Y" -a  $TRAILER_RECORD_SUM_VALID  == "Y" -a  $HEADER_FORMAT_VALID == "Y" -a  $TRAILER_FORMAT_VALID == "Y" ]
            then
				#set status as Success
                export STATUS=SUCCESS
				echo "$STATUS is the status of this file" >> $LOG_FILE
				else
				#set status as failed
				export STATUS=FAILED
				echo "$STATUS this is status"
				#calling function to insert entries to error tables--l_f_insert_error_audit
                    l_f_insert_error_audit $ERROR_DATA
                    #start of function return check--l_f_insert_error_audit
                    if [ $? -ne 0 ]
                    then
                                                                
                    echo "`PrErrD` : An error occurred in executing l_f_update_step_audit function." >> $LOG_FILE
                    else
                    echo "`PrInfD`:l_f_update_step_audit function for updating into Step Audit Table is complete." >> $LOG_FILE
                    fi
					                                                fi
                                                fi
                                                                if [ $STATUS == 'SUCCESS' ] 
                                                                then
																FILE_PROCESSED_FLAG=`expr $FILE_PROCESSED_FLAG + 1`
                                                                #moving validation file in case of success
                                                                echo "$FILE_NAME--$SOURCE_DIR---$FILE"
                                                                cp "$FILE_NAME" $SOURCE_DIR/"$FILE"
                                                                #archiving original file in case of success
                                                                l_f_archive_files "$FILE_RENAMED" "$FILE" "$FEED_NAME" $BATCH_DATE
																l_f_update_step_audit $STEP_ID $STATUS "$FILE" "" "VALIDATION_FILE"
                                                                #start of function return check--l_f_update_step_audit
                                                               if [ $? -ne 0 ]
                                                                then
                                                                                echo "`PrErrD` : An error occurred in executing l_f_update_step_audit function." >> $LOG_FILE
																else
                                                                                echo "`PrInfD`:l_f_update_step_audit function for updating into Step Audit Table is complete." >> $LOG_FILE
                                                                fi 
																
																fi
                                                                if [ $STATUS == 'FAILED' ] 
                                                                then
                                                                echo "File Validation Failed for File: $FILE for BATCH_DATE: $BATCH_DATE" > $TMP_DIR/Mail_Content.txt
                                                                echo "Mail Subject : $MAIL_SUBJECT Mail Recipients: $MAIL_RECIPIENT " >> $LOG_FILE
                                                                echo "Mail Sent " >> $LOG_FILE
                                                                echo "Open Attachment for details" | mail -s File_Validation_Failed -a $TMP_DIR/Mail_Content.txt  delightsimmy@gmail.com
                                                                #archiving validation file in case of failure
                                                                mv "$FILE_NAME" "$FILE_RENAMED"
                                                                echo "$FILE_RENAMED $FILE $FEED_NAME $BATCH_DATE are values"
                                                                l_f_archive_files "$FILE_RENAMED" "$FILE" "$FEED_NAME" $BATCH_DATE
                                                
                                                                #archiving original file in case of failure
                                                                #l_f_archive_files $ORIG_FILE_NAME $FILE $FEED_NAME $BATCH_DATE
																l_f_update_step_audit $STEP_ID $STATUS "$FILE" "" "VALIDATION_FILE"
                                                                #start of function return check--l_f_update_step_audit
                                                                if [ $? -ne 0 ]
                                                                then
                                                                                echo "`PrErrD` : An error occurred in executing l_f_update_step_audit function." >> $LOG_FILE
																else
                                                                                echo "`PrInfD`:l_f_update_step_audit function for updating into Step Audit Table is complete." >> $LOG_FILE
                                                                fi 
																 
                                                                fi
                                                          
                                                              
                                                                
                                                              
                                                                #close of function return check--l_f_update_step_audit
                                                                #close of function call--l_f_update_step_audit
                                                
                                
else
exit 0
fi                                                               
done < $FILE_LIST
if [ $FILE_PROCESSED_FLAG -eq 0 ]
then 
exit 1
fi

 
done
#close of loop for step id



