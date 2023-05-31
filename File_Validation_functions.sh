##############################################################################################
# Function      :  l_f_run_ora_query                                                                             		
#                                                                                                               		
# Description   :  This function is to run an oracle query				                        
#                                                                                                               		
# Parameters    :  NONE                                                                                             		
##############################################################################################

#Calling configuration file
. /u02/Scripts/Configuration_File.cfg

l_f_run_ora_query ()
{
	unset l_query_ret
	
	l_query="$1"
	
	echo "$l_query is query"
	query_file=$(echo ${l_query} | awk '{print $1}')
   	
	echo "$query_file is query file"
l_query_ret=`sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
	SET LINESIZE 4000 PAGESIZE 1000 FEEDBACK OFF HEADING OFF ECHO OFF VERIFY OFF
	WHENEVER SQLERROR EXIT FAILURE
	WHENEVER OSERROR EXIT FAILURE
	SET SERVEROUTPUT ON
	@${l_query}
EOF`
	v_ora_err_cnt=$(echo ${l_query_ret} | egrep -ic 'SP2-|ORA-')
	if [ ${v_ora_err_cnt} -ne 0 ]
	then
		echo "`PrErrD` : There was an ORA error while executing /u02/cifs/informatica/INT_INFA_TEST/Scripts/File_Validation/SQL \n$(cat ${query_file})\nEncountered error \n$(echo ${v_ora_err})\n\nExiting the script..." >> $LOG_FILE
		return 1
	else
	    echo "l_f_run_ora_query executed successfully." >> $LOG_FILE
	
		export l_query_ret
	    return 0
	fi
}


##############################################################################################
#Function :	l_f_insert_step_audit
# 
#Description:	To insert into Step Audit Table
#
##############################################################################################
l_f_insert_step_audit ()
{
  l_STEP_ID=$1
  l_STATUS=$2


    #echo " at 105 ARC_SRC_LOCATION:"$ARC_SRC_LOCATION >> $LOG_FILE
  . $SCRIPT_DIR/insert_step_audit.sh $l_STEP_ID $l_STATUS
  echo "at 107 ARC_SRC_LOCATION:"$ARC_SRC_LOCATION >> $LOG_FILE
  if [ $? -ne 0 ]
  then
        echo "`PrErrD` : An error occurred in executing insert_step_audit Script." >> $LOG_FILE
        return 1
  fi
}
##############################################################################################
#Function   :l_f_extract_step_log_id
# 
#Description:To extract step log id 	
#
##############################################################################################
l_f_extract_step_log_id ()
{
 l_STEP_ID=$1
 l_BATCH_DATE=$2
 l_STATUS=$3
 

 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/select_step_log_id.sql $l_STEP_ID $l_BATCH_DATE $l_STATUS"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function :	l_f_update_step_audit
# 
#Description:	To update into Step Audit Table
#
##############################################################################################
l_f_update_step_audit ()
{
  l_STEP_ID=$1
  l_STATUS=$2
  l_FILE_NAME_TO_PASS=$3
  l_TARGET_NAME=$4
  l_FILE_TYPE=$5
  #echo "$1--$2--$3--$4--$5 values for up audit"
  echo "`PrInfD`  : Calling the script update step audit." >> $LOG_FILE
  . $SCRIPT_DIR/update_step_audit.sh $l_STEP_ID $l_STATUS "$l_FILE_NAME_TO_PASS" "$l_TARGET_NAME" "$l_FILE_TYPE"  >> $LOG_FILE
  if [ $? -ne 0 ]
  then
        echo "`PrErrD` : An error occurred in executing update_step_audit Script." >> $LOG_FILE
        return 1
  fi
}

##############################################################################################
#Function :	l_f_insert_error_audit
# 
#Description:	To insert into Error Audit Table
#
##############################################################################################
l_f_insert_error_audit ()
{
  l_ERR_FILE_NAME=$1
  while read line 
  do
  unset l_STEP_LOG_ID
  unset l_ERR_CD
  unset l_ERR_CAT_CD
  unset l_SRC_TABLE_NAME
  unset l_BATCH_DATE
  
  l_STEP_LOG_ID=`echo $line | cut -d'|' -f1`
  l_ERR_CD=`echo $line | cut -d'|' -f2`
  l_ERR_CAT_CD=`echo $line | cut -d'|' -f3`
  l_SRC_TABLE_NAME=`echo $line | cut -d'|' -f4`
  l_BATCH_DATE=`echo $line | cut -d'|' -f5`
  
  echo "
  $STEP_LOG_ID is step log 
  $ERR_CD is err cd
  $ERR_CAT_CD is err cat cd
  $SRC_TABLE_NAME is src name
  $loc_BATCH_DATE is bdate" >> $LOG_FILE
   
  echo "`PrInfD`  : Calling the script insert_error_audit." >> $LOG_FILE
  . $SCRIPT_DIR/insert_error_audit.sh $l_STEP_LOG_ID $l_ERR_CD $l_ERR_CAT_CD "$l_SRC_TABLE_NAME" $l_BATCH_DATE >> $LOG_FILE
  if [ $? -ne 0 ]
  then
        echo "`PrErrD` : An error occurred in executing insert_error_audit Script." >> $LOG_FILE
        return 1
  fi
  done < $l_ERR_FILE_NAME
}

##############################################################################################
#Function :	l_f_insert_feed_audit
# 
#Description:	To insert into Feed Audit Table
#
##############################################################################################
l_f_insert_feed_audit ()
{
  l_STEP_LOG_ID=$1
  l_FEED_ID=$2
  l_FILE_SIZE=$3
  l_ORIGINAL_FILE_NAME=$4
  l_BATCH_DATE=$5
  l_file_arrival_dttm=$6
  l_AMOUNT_SUM_CHK=$7
  l_RUN_DATE=$8
#echo "$1----$2-----$3----$4-----$5----$6----$7----$8 are values to invoke feed audit"
  . $SCRIPT_DIR/insert_feed_audit.sh $l_STEP_LOG_ID $l_FEED_ID "$l_FILE_SIZE" "$l_ORIGINAL_FILE_NAME" $l_BATCH_DATE "$l_file_arrival_dttm" "$l_AMOUNT_SUM_CHK" "$l_RUN_DATE"
  if [ $? -ne 0 ]
  then
        echo "`PrErrD` : An error occurred in executing insert_feed_audit Script." >> $LOG_FILE
        return 1
  fi
}

##############################################################################################
#Function   :l_f_extract_file_names
# 
#Description:To extract file names 	
#
##############################################################################################
l_f_extract_file_names ()
{
	BATCH_ID=$1
	echo $BATCH_ID
	echo "`PrInfD`  : Calling the function l_f_run_ora_query." >>  $LOG_FILE
 
 l_f_run_ora_query "$SQL_DIR/CreateSrcFiles.sql $BATCH_ID"	
 
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

 }

##############################################################################################
#Function   :l_f_extract_batch_date
# 
#Description:To extract batch date 	
#
##############################################################################################
l_f_extract_batch_date ()
{
 #BATCH_ID=$1
 #echo $BATCH_ID
  #echo $SQL_DIR
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >>  $LOG_FILE
 
 l_f_run_ora_query "$SQL_DIR/select_batch_date.sql"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_DATE_PATTERN_POS
# 
#Description:To extract the date pattern position in the file name.
#
##############################################################################################
l_f_DATE_PATTERN_POS ()
{
 l_FILE_NAME_PATTERN=$1
 l_DATE_PATTERN=$2
 l_TIME_PATTERN=$3
 l_FILE_NM_DLIM=$4
 l_DATE_PATTERN_POS=0
 l_TIME_PATTERN_POS=0
 
 i=1
 j=1
 echo "$l_FILE_NAME_PATTERN" | tr "$l_FILE_NM_DLIM" '\n' > $TMP_DIR/splitted_value.txt
 while read line
 do
	CHKDATE=`echo $line | grep "$l_DATE_PATTERN"`
	CHKTIME=`echo $line | grep "$l_TIME_PATTERN"`
	if [ ! -z $CHKDATE ]
	then
		  l_DATE_PATTERN_POS=$i
		  echo $l_DATE_PATTERN_POS
		 
	else
		i=`expr $i + 1`
	fi
	if [ ! -z $CHKTIME ]
	then
		  l_TIME_PATTERN_POS=$j
		  echo $l_TIME_PATTERN_POS
		 
	else
		j=`expr $j + 1`
	fi
 done < $TMP_DIR/splitted_value.txt
 unset i
 unset j
}

##############################################################################################
#Function   :l_f_file_nm_dt_ptrn_chk
# 
#Description:Function l_f_file_nm_dt_ptrn_chk to check the date pattern in file name
#
##############################################################################################
l_f_file_nm_dt_ptrn_chk ()
{
l_FILE_NAME_CHECK=$1
l_DATE_PATTERN_POS=$2
l_TIME_PATTERN_POS=$3
l_FILE_NM_DLIM=$4
l_DATE_PATTERN=$5
l_TIME_PATTERN=$6
l_FEED_SUB_TYPE=$7

if [ $l_FEED_SUB_TYPE = 'ENTRA' ]
then

#echo "here is new requirement now"
l_DATE_EXTRACT=`basename "$l_FILE_NAME_CHECK" | cut -d"$l_FILE_NM_DLIM" -f"$l_DATE_PATTERN_POS" | tr -cd [1234567890]`
echo "$FILE_NAME" >> $LOG_FILE
l_DT_EXTRACT=$l_DATE_EXTRACT
l_DATE_PATTERN=$l_DATE_PATTERN


. $SCRIPT_DIR/GENERIC_FUNCTIONS.sh $l_DT_EXTRACT $l_DATE_PATTERN >> $LOG_FILE
if [ $? -ne 0 ]
then
	echo "`PrInfD`  : For file  $FILE_NAME,$DTTM_EXTRACT  is not in DATE_PATTERN : $DATE_PATTERN valid format." >> $LOG_FILE
	export FILE_NAME_DATE_PATTERN_VALID=N
else
	echo "`PrInfD`  : For file $FILE_NAME,$DTTM_EXTRACT is in DATE_PATTERN : $DATE_PATTERN valid format." >> $LOG_FILE
	export FILE_NAME_DATE_PATTERN_VALID=Y
fi	

else


l_DATE_EXTRACT=`basename "$l_FILE_NAME_CHECK" | cut -d"$l_FILE_NM_DLIM" -f"$l_DATE_PATTERN_POS" | tr -cd [1234567890]`
l_TIME_EXTRACT=`basename "$l_FILE_NAME_CHECK" | cut -d"$l_FILE_NM_DLIM" -f"$l_TIME_PATTERN_POS" | tr -cd [1234567890]`
echo "$FILE_NAME" >> $LOG_FILE
l_DTTM_EXTRACT=$l_DATE_EXTRACT$l_FILE_NM_DLIM$l_TIME_EXTRACT
l_DATETIME_PATTERN=$l_DATE_PATTERN$l_FILE_NM_DLIM$l_TIME_PATTERN


. $SCRIPT_DIR/GENERIC_FUNCTIONS.sh $l_DTTM_EXTRACT $l_DATETIME_PATTERN >> $LOG_FILE
if [ $? -ne 0 ]
then
	echo "`PrInfD`  : For file  $FILE_NAME,$DTTM_EXTRACT  is not in DATE_PATTERN : $DATE_PATTERN valid format." >> $LOG_FILE
	export FILE_NAME_DATE_PATTERN_VALID=N
else
	echo "`PrInfD`  : For file $FILE_NAME,$DTTM_EXTRACT is in DATE_PATTERN : $DATE_PATTERN valid format." >> $LOG_FILE
	export FILE_NAME_DATE_PATTERN_VALID=Y
fi	

fi


return 0

}
##############################################################################################
#Function   :	l_f_trailer_date_pattern_chk
# 
#Description:	Function l_f_trailer_date_pattern_chk to check the date format of trailer record
#
##############################################################################################
l_f_trailer_date_pattern_chk ()
{
l_TRAILER_BATCH_DATE=$1
l_TRAILER_DATE_PATTERN=YYYYMMDD


. $SCRIPT_DIR/GENERIC_FUNCTIONS.sh $l_TRAILER_BATCH_DATE $l_TRAILER_DATE_PATTERN
if [ $? -ne 0 ]
then
	echo "`PrInfD`  : For file $FILE_NAME,$TRAILER_BATCH_DATE  is not in DATE_PATTERN : $DATE_PATTERN valid format." >> $LOG_FILE
	#echo "$FEED_NUM : $BATCH_ID :$FILE_NAME : COB_DATE IDENTIFICATION CHK : NOT VALIDATED" >> $OUTPUT_FILE
	export TRAILER_DATE_PATTERN_VALID=N
	
else
	echo "`PrInfD`  : For file $FILE_NAME,$TRAILER_BATCH_DATE is in DATE_PATTERN : $DATE_PATTERN valid format." >> $LOG_FILE
	#echo "$FEED_NUM : $BATCH_ID :$FILE_NAME : COB_DATE IDENTIFICATION CHK : VALIDATED" >> $OUTPUT_FILE
	export TRAILER_DATE_PATTERN_VALID=Y
	
fi	


return 0

}
##############################################################################################
#Function   :l_f_trailer_record_sum_chk
# 
#Description:Function l_f_trailer_record_sum_chk to check the record Sum 
#		     over the record sum in trailer of file
#
##############################################################################################
l_f_trailer_record_sum_chk ()
{
l_FILE_NAME=$1
l_TRAILER_RECORD_SUM_COLUMN=$2

echo "2:::$2" >> $LOG_FILE
echo "1::$1"  >> $LOG_FILE
echo "FILE_SIZE::$FILE_SIZE"  >> $LOG_FILE

l_TRAILER_SUM_CHK=`cat $l_FILE_NAME | tail -1 | awk -F'~\\\\|' '{print $'$l_TRAILER_RECORD_SUM_COLUMN'}'`

echo "l_TRAILER_SUM_CHK::$l_TRAILER_SUM_CHK"  >> $LOG_FILE

if [ $FILE_SIZE == $l_TRAILER_SUM_CHK ]
then

	echo "`PrInfD` :The trailer record sum check is validated." >> $LOG_FILE
	#echo "$FEED_NUM : $BATCH_ID :$FILE_NAME : TRAILER RECORD SUM CHK : NOT VALIDATED" >> $OUTPUT_FILE
	export TRAILER_RECORD_SUM_VALID=Y
	
else
	echo "`PrInfD` :The trailer record sum check is not validated." >> $LOG_FILE
	#echo "$FEED_NUM : $BATCH_ID :$FILE_NAME : TRAILER RECORD SUM CHK : VALIDATED" >> $OUTPUT_FILE
	export TRAILER_RECORD_SUM_VALID=N	

fi

return 0

}

##############################################################################################
#Function   :l_f_trailer_amount_sum_chk
# 
#Description:Function l_f_trailer_amount_sum_chk to check the amount Sum 
#		     over the amount sum in trailer of file
#
##############################################################################################
l_f_trailer_amount_sum_chk ()
{
FILE_NAME=$1
TRAILER_AMOUNT_SUM_COLUMN=$2
AMT_SUM_COL_POS=$3

#TRAILER_AMOUNT_SUM_CHK=`cat $FILE_NAME | tail -1 | cut -d"$DLIM" -f$TRAILER_AMOUNT_SUM_COLUMN`
#TRAILER_AMOUNT_SUM_CHK=`cat $FILE_NAME | tail -1 | sed 's/,/./' | awk -F'~\\\\|' '{print $'$TRAILER_AMOUNT_SUM_COLUMN'}'`
TRAILER_AMOUNT_SUM_CHK=`cat $FILE_NAME | tail -1 | sed 's/,/./' | awk -F'~\\\\|' '{print $'$TRAILER_AMOUNT_SUM_COLUMN'}'|awk '{sum = sprintf("%f",$1)} END {printf "%.2f\n",sum}'`
echo "`PrInfD` : Trailer Amount Sum Check: $TRAILER_AMOUNT_SUM_CHK"  >> $LOG_FILE
echo "FILE_NAME: $FILE_NAME" >> $LOG_FILE
echo "TRAILER_AMOUNT_SUM_COLUMN: $TRAILER_AMOUNT_SUM_COLUMN" >> $LOG_FILE
echo "AMT_SUM_COL_POS: $AMT_SUM_COL_POS" >> $LOG_FILE
#AMOUNT_SUM_VAR=`cat $FILE_NAME | sed '2,$!d' | sed '$d' | awk -F'~\\\\|' '{print $'$AMT_SUM_COL_POS'}'`
#AMOUNT_SUM_CHK=`cat $FILE_NAME | awk -F'~\\\\|' '{print $'$AMT_SUM_COL_POS'}' | sed 's/,/./' | awk '{sum += $1} END {print sum}'`
AMOUNT_SUM_CHK=`awk -F'~\\\\|' '{print $'$AMT_SUM_COL_POS'}' $FILE_NAME | sed 's/,/./' | awk '{sum += sprintf("%f",$1)} END {printf "%.2f\n",sum}'`
echo "`PrInfD` : Amount Sum Check :$AMOUNT_SUM_CHK"  >> $LOG_FILE

if [ $AMOUNT_SUM_CHK == $TRAILER_AMOUNT_SUM_CHK ]
then
	echo "`PrInfD` :The trailer amount sum check is validated."  >> $LOG_FILE
	export TRAILER_AMOUNT_SUM_VALID=Y
	export AMOUNT_SUM_CHK
else
	echo "`PrInfD` :The trailer amount sum check is not validated." >> $LOG_FILE
	export TRAILER_AMOUNT_SUM_VALID=N	
	export AMOUNT_SUM_CHK
fi

return 0
}

##############################################################################################
#Function   : l_f_header_format_chk
# 
#Description: Function l_f_header_format_chk to check the format of header record
#
##############################################################################################
l_f_header_format_chk ()
{
FILE_NAME_CHK=$1
HDR_IDENTIFIER=$2

HEADER_CHK=`cat $FILE_NAME_CHK | head -1`

echo "\n Header Check : $HEADER_CHK" >> $LOG_FILE
echo "\n Header Identifier : $HDR_IDENTIFIER" >> $LOG_FILE

if [ "$HEADER_CHK" == "$HDR_IDENTIFIER" ]
then
	echo "`PrInfD` :The file $FILE_NAME contains the header record in proper format." >> $LOG_FILE
	export HEADER_FORMAT_VALID=Y
else
	echo "`PrInfD` :The file $FILE_NAME does not contains the header record in proper format." >> $LOG_FILE
	export HEADER_FORMAT_VALID=N
fi

return 0
}

##############################################################################################
#Function   : l_f_compare_previous_day_data
# 
#Description: Function l_f_compare_previous_day_data to check the previous batch date
#
##############################################################################################

l_f_compare_previous_day_data()
{ 
ARCHIVAL_DIR=$1
FILE_NAME_PATTERN=$2
LAST_BATCH_DATE=$3
ORIGNL_FILE_NAME=$4
			
echo "`PrInfD` :For file $ORIG_FILE_NAME :Checking for Previous Batch Date file."  >> $LOG_FILE
ARCHIVAL_FOLDER="$ARCHIVAL_DIR"/"$LAST_BATCH_DATE"
echo "Archival Folder is : $ARCHIVAL_FOLDER" >> $LOG_FILE
if [ ! -d "$ARCHIVAL_FOLDER" ]
then
	echo "Previous Batch Date : $LAST_BATCH_DATE Archival Folder does not exist" >> $LOG_FILE
	PREVIOUS_DATE_COMPARISON=Y
else
	cd $ARCHIVAL_FOLDER
	ARCHIVAL_FILE_NAME=`ls Org_"$FILE_NAME_PATTERN"*`
	echo "Archival File is : $ARCHIVAL_FILE_NAME" >> $LOG_FILE
	if [ ! -f "$ARCHIVAL_FILE_NAME" ]
	then
		echo "Archival File for Previous Batch Date : $LAST_BATCH_DATE does not exist" >> $LOG_FILE
		PREVIOUS_DATE_COMPARISON=Y
	else                    
		cp $ARCHIVAL_FILE_NAME $TMP_DIR
		cd $ARC_SRC_LOCATION
		UNZIPPED_FILE_NAME=`unzip -Z -1 $TMP_DIR/$ARCHIVAL_FILE_NAME`
		unzip $TMP_DIR/$ARCHIVAL_FILE_NAME
		CURR_FILE=Org_$ORIGNL_FILE_NAME
		diff $CURR_FILE $TMP_DIR/$UNZIPPED_FILE_NAME > $TMP_DIR/difference.txt
		if [ ! -s $TMP_DIR/difference.txt ]
		then
			echo "$FILE_NAME is same as Previous Batch Date File $UNZIPPED_FILE_NAME" >> $LOG_FILE
			export PREVIOUS_DATE_COMPARISON=N
		else
			echo "$FILE_NAME is different from Previous Batch Date File $UNZIPPED_FILE_NAME" >> $LOG_FILE
			export PREVIOUS_DATE_COMPARISON=Y
			echo "$PREVIOUS_DATE_COMPARISON is the flag for previous date check"
		fi
	fi                                                                        
					 
fi

}

##############################################################################################
#Function   : l_f_archive_files
# 
#Description: Function l_f_archive_files to archive source files
#
##############################################################################################

l_f_archive_files()
{

FILE_NAME_C=$1
ORIGN_FILE_NAME=$2
FEED_NAME=$3
BATCH_DATE=$4
FILE_NAME_DELIM=_
FILE_NAME_EXT=`echo "$FILE_NAME_C" | cut -d'.' -f2`
ARCH_TIME=`date +%Y%m%d_%H%M%S`

echo "`PrInfD` :For file $FILE_NAME_C :Checking for Batch Date file."	>> $LOG_FILE

ARCHIVAL_FOLDER="$ARCHIVAL_DIR"/"$BATCH_DATE"
echo "Archival Folder is : $ARCHIVAL_FOLDER" >> $LOG_FILE
if [ -d "$ARCHIVAL_FOLDER" ]
then
	echo "Batch Date : $BATCH_DATE Archival Folder exists" >> $LOG_FILE
else
    echo "Creating the $BATCH_DATE archival folder" >> $LOG_FILE
	mkdir $ARCHIVAL_FOLDER
	#echo "$ARCHIVAL_FOLDER is archival folder"
fi
	echo "ARC_SRC_LOCATION::$ARC_SRC_LOCATION" >> $LOG_FILE
	cd $ARC_SRC_LOCATION
	PROC_FIL_NAME=Org$FILE_NAME_DELIM"$FEED_NAME"$FILE_NM_DLIM$ARCH_TIME.$FILE_NAME_EXT
	mv Org_"$ORIGN_FILE_NAME" "$PROC_FIL_NAME"
	gzip  "$PROC_FIL_NAME"
	gzip "$FILE_NAME_C"
	mv *.gz $ARCHIVAL_FOLDER
	echo "Above mentioned files are archived successfully." >> $LOG_FILE
}

######################################################################################
#Function Name:l_f_create_framework_info
#Arguments:STEP_ID
#Description: Extract feed info from feed config and step config table based on step id
#######################################################################################
l_f_create_framework_info() 
{
l_STEP_ID=$1
 echo "$PrInfD  : Calling the function l_f_run_ora_query to create supply_info_file ." >> $LOG_FILE

 l_f_run_ora_query "$SQL_DIR/select_framework_info.sql $l_STEP_ID"		
 if [ $? -ne 0 ]
then
        echo "$PrErrD : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
fi

}

########################################################################
#Function Name:l_f_trailer_rec_cnt_chk_nonUDX
#Arguments: 
#FILE_NAME=$1
#HEADER_IDENTIFIER=$2
#TRAILER_IDENTIFIER=$3
#TRAILER_START_POS=$4
#TRAILER_END_POS=$5
#Description: Check the  record count in trailer
########################################################################
l_f_trailer_rec_cnt_chk_nonUDX ()
{
FILE_NAME_TR=$1
FILE_SIZE=$2
TRAILER_IDENTIFIER=$3
TRAILER_START_POS=$4
TRAILER_END_POS=$5


VAR_COUNT_RECORD=`cat "$FILE_NAME_TR" | grep -n "$TRL_IDENTIFIER" | awk -F':' '{print $2}' | cut -c $TRAILER_START_POS-$TRAILER_END_POS`
VAR_TRIM_LDNG_ZEROS=`echo $VAR_COUNT_RECORD | awk '{print $1 + 0}'`
VAR_WDOUT_HDR_TRLR=`expr $FILE_SIZE + 2`

if [ $VAR_WDOUT_HDR_TRLR != $VAR_TRIM_LDNG_ZEROS ]
then
       echo "`PrInfD`: Record Count Check failed for the file $FILE_NAME " >> $LOG_FILE
	   export TRAILER_RECORD_SUM_VALID=N
else
 echo "`PrInfD`: Record Count Check successful for the file $FILE_NAME " >> $LOG_FILE
	   export TRAILER_RECORD_SUM_VALID=Y
	   echo "$TRAILER_RECORD_SUM_VALID"
fi

return 0
}

########################################################################
#Function Name:l_f_header_format_chk_nonUDX
#Arguments: 
#FILE_NAME=$1
#HDR_IDENTIFIER=$2
#Description: Check the  header format  in file 
########################################################################
l_f_header_format_chk_nonUdX ()
{
FILE_NAME_HR=$1
HDR_IDENTIFIER=$2
FEED_SUB_TYPE=$3

HDR_EXIST=`cat "$FILE_NAME_HR" | grep -n "$HDR_IDENTIFIER" |  awk -F':' '{print $1}'`
if [ $HDR_EXIST -ne 0 ]
then
export HEADER_FORMAT_VALID=Y
else
export HEADER_FORMAT_VALID=N
fi
return 0
}

########################################################################
#Function Name:l_f_footer_format_chk_nonUDX
#Arguments: 
#FILE_NAME=$1
#TRL_IDENTIFIER=$2
#Description: Check the  footer format  in file 
########################################################################
l_f_footer_format_chk_nonUdX ()
{
FILE_NAME_FF=$1
TRL_IDENTIFIER=$2
FEED_SUB_TYPE=$3

TRL_EXIST=`cat "$FILE_NAME_FF" | grep -n "$TRL_IDENTIFIER" |  awk -F':' '{print $1}'`
if [ $TRL_EXIST -ne 0 ]
then
export TRAILER_FORMAT_VALID=Y
else
export TRAILER_FORMAT_VALID=N
fi
return 0
}

#######################################################################
#Function Name:l_f_compare_previous_day_data
#Arguments: 
#ARCHIVAL_DIR=$1
#FILE_NAME_PATTERN=$2
#LAST_BATCH_DATE=$3
#ORIG_FILE_NAME=$4
#Description: Check the archival folder to check for previous day file data
########################################################################
l_f_compare_previous_day_data_nonUDX()
{ 
ARCHIVAL_DIR=$1
l_FILE_NAME_PATTERN=$2
l_LAST_BATCH_DATE=$3
l_ORIGL_FILE_NAME=$4

echo "`PrInfD` :For file $FILE :Checking for Previous Batch Date file."  >> $LOG_FILE
                ARCHIVAL_FOLDER="$ARCHIVAL_DIR"/"$l_LAST_BATCH_DATE"
                echo "Archival Folder is : $ARCHIVAL_FOLDER" >> $LOG_FILE
                if [ ! -d "$ARCHIVAL_FOLDER" ]
                then
					echo "Previous Batch Date : $LAST_BATCH_DATE Archival Folder does not exist" >> $LOG_FILE
                    export PREVIOUS_DATE_COMPARISON=Y
                else
                    cd $ARCHIVAL_FOLDER
					
                    ARCHIVAL_FILE_NAME=`ls Org"$FEED_NAME"*`
                    echo "Archival File is : $ARCHIVAL_FILE_NAME" >> $LOG_FILE
                    if [ ! -f "$ARCHIVAL_FILE_NAME" ]
                    then
                        echo "Archival File for Previous Batch Date : $LAST_BATCH_DATE does not exist" >> $LOG_FILE
                        export PREVIOUS_DATE_COMPARISON=Y
                    else                    
                        cp "$ARCHIVAL_FILE_NAME" $TMP_DIR
                        cd $SCRIPT_HOME
                        UNZIPPED_FILE_NAME=`unzip -Z -1 $TMP_DIR/"$ARCHIVAL_FILE_NAME"`
                        unzip $TMP_DIR/"$ARCHIVAL_FILE_NAME"
                        diff "$ORIGL_FILE_NAME" $TMP_DIR/"$UNZIPPED_FILE_NAME" > $TMP_DIR/difference.txt
                        if [ ! -s $TMP_DIR/difference.txt ]
                        then
                            echo "$FILE_NAME is same as Previous Batch Date File $UNZIPPED_FILE_NAME" >> $LOG_FILE
                            export PREVIOUS_DATE_COMPARISON=N
                        else
							echo "$FILE_NAME is different from Previous Batch Date File $UNZIPPED_FILE_NAME" >> $LOG_FILE
                            export PREVIOUS_DATE_COMPARISON=Y
						
					    fi
					fi                                                                        
                                     
				fi
			
		
}

#######################################################################
#Function Name:l_f_xls_to_text
#Arguments: 
#ARCHIVAL_DIR=$1
#FILE_NAME_PATTERN=$2
#LAST_BATCH_DATE=$3
#ORIG_FILE_NAME=$4
#Description: Function to convert .xls file to text file
########################################################################

l_f_xls_to_text() 
{

l_FILE_NAME_TO_CONVERT="$1"
l_FILE_XL="$2"
l_TAB_NAME="$3"
l_OUTPUT_FILE=`echo "$l_FILE_XL" | cut -d'.' -f1`
echo "$1==$2==$3 new function"
cd $SCRIPT_DIR


(scl enable python27 "python xls2textfile_utf8.py -i $ARC_SRC_LOCATION/$l_FILE_NAME_TO_CONVERT -s \"$l_TAB_NAME\" -o $l_OUTPUT_FILE.txt -d \"~|\" ") >> $LOG_FILE
if [ $? -ne 0 ] 
then
echo "An error occurred in executing the python script for conversion">>$LOG_FILE

return 1
else
echo "File converted successfully">>$LOG_FILE
cat $l_OUTPUT_FILE.txt | sed 's/"~|"/~|/g' | sed 's/"~|/~|/g' | sed 's/^.//'  |  sed '/^ *$/d' > $SOURCE_DIR/$l_OUTPUT_FILE.txt


return 0
fi
}



########################################################################
#Function Name:l_f_footer_format_chk_nonUDX
#Arguments: 
#FILE_NAME=$1
#TRL_IDENTIFIER=$2
#Description: Check the  footer format  in file 
########################################################################
l_f_pick_files()
{

l_SEARCH_FILE_NAME=$1
echo "inside fnc" >> $LOG_FILE
echo "$1" >> $LOG_FILE

cd $ACTUAL_LOC


l_FILE_TO_PICK=`ls "$l_SEARCH_FILE_NAME"*`
echo "$l_FILE_TO_PICK" >> $LOG_FILE
 if [ -n "$l_FILE_TO_PICK" ]
 then 
 export FILE_NAME_TO_COPY="$l_FILE_TO_PICK" 
  export FILE_PRESENT=Y
  echo "$FILE_PRESENT" >> $LOG_FILE
 else
 export FILE_PRESENT=N
  echo "$FILE_PRESENT " >> $LOG_FILE

fi


}


######################################################################################
#Function Name:l_f_select_feed_id
#Arguments:STEP_ID
#Description: Extract feed info from feed config and step config table based on step id
#######################################################################################
l_f_select_extract_feed_info() 
{
l_STEP_ID=$1
 echo "$PrInfD  : Calling the function l_f_run_ora_query to create supply_info_file ." >> $LOG_FILE

 l_f_run_ora_query "$SQL_DIR/select_extract_feed_info.sql $l_STEP_ID"		
 if [ $? -ne 0 ]
then
        echo "$PrErrD : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
fi

}

l_f_select_feed_name()
{
l_FEED_ID=$1
 echo "$PrInfD  : Calling the function l_f_run_ora_query to create supply_info_file ." >> $LOG_FILE

 l_f_run_ora_query "$SQL_DIR/select_feed_name.sql $l_FEED_ID"		
 if [ $? -ne 0 ]
then
        echo "$PrErrD : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
fi

}

##############################################################################################
#Function   :l_f_extract_detica_feed_name
# 
#Description:To extract step log id 	
#
##############################################################################################
l_f_extract_detica_feed_name ()
{

 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/select_detica_feedname.sql"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_extract_Historic_batch_dates
# 
#Description:To extract historic date 	
#
##############################################################################################
l_f_extract_historic_batch_dates ()
{
 l_start_dt=$1
 l_end_dt=$2
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/select_history_date.sql $l_start_dt $l_end_dt "	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_extract_historic_step_upd
# 
#Description:To extract historic step date 	
#
##############################################################################################
l_f_extract_historic_step_upd ()
{
 l_batch_dt=$1
 l_step_id=$2
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/update_step_histroric_load.sql $l_batch_dt $l_step_id"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_extract_historic_batch_upd
# 
#Description:To update historic batch date 	
#
##############################################################################################
l_f_extract_historic_batch_upd ()
{
 l_batch_dt=$1
 l_batch_id=$2
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/update_batch_for_histroric_load.sql $l_batch_dt $l_batch_id"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_extract_Historic_batch_dates
# 
#Description:To extract historic date 	
#
##############################################################################################
l_f_extract_historic_batch_dates ()
{
 l_start_dt=$1
 l_end_dt=$2
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/select_history_date.sql $l_start_dt $l_end_dt "	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_extract_historic_step_upd
# 
#Description:To extract historic step date 	
#
##############################################################################################
l_f_extract_historic_step_upd ()
{
 l_batch_dt=$1
 l_step_id=$2
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/update_step_histroric_load.sql $l_batch_dt $l_step_id"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_extract_historic_batch_upd
# 
#Description:To update historic batch date 	
#
##############################################################################################
l_f_extract_historic_batch_upd ()
{
 l_batch_dt=$1
 l_batch_id=$2
 echo "`PrInfD`  : Calling the function l_f_run_ora_query." >> $LOG_FILE
 echo $SQL_DIR >> $LOG_FILE
 l_f_run_ora_query "$SQL_DIR/update_batch_for_histroric_load.sql $l_batch_dt $l_batch_id"	
 if [ $? -ne 0 ]
 then
        echo "`PrErrD` : An error occurred in executing l_f_run_ora_query function." >> $LOG_FILE
        return 1
 fi

}

##############################################################################################
#Function   :l_f_archive_detica_extracts
# 
#Description:To update historic batch date 	
#
##############################################################################################

l_f_archive_detica_extracts()
{

FILE_NAME_C=$1
BATCH_DATE=$2
FILE_NAME_EXT=`echo "$FILE_NAME_C" | cut -d'.' -f2`
ARCH_TIME=`date +%Y%m%d_%H%M%S`

echo "`PrInfD` :For file $FILE_NAME_C :Checking for Batch Date file."	>> $LOG_FILE

ARCHIVAL_FOLDER="$TGT_FILE_LOCATION"/"$BATCH_DATE"
echo "Archival Folder is : $ARCHIVAL_FOLDER" >> $LOG_FILE
if [ -d "$ARCHIVAL_FOLDER" ]
then
	echo "Batch Date : $BATCH_DATE Archival Folder exists" >> $LOG_FILE
else
    echo "Creating the $BATCH_DATE archival folder" >> $LOG_FILE
	mkdir $ARCHIVAL_FOLDER
	#echo "$ARCHIVAL_FOLDER is archival folder"
fi
	echo "ARC_SRC_LOCATION::$ARC_SRC_LOCATION" >> $LOG_FILE
	cd $TGT_FILE_LOCATION
	gzip $FILE_NAME_C
	mv *.gz $ARCHIVAL_FOLDER
	echo "Above mentioned files are archived successfully." >> $LOG_FILE
}


##############################################################################################
#Function   :l_f_failed_session_name
# 
#Description:To extract failed session names 	
#
##############################################################################################
l_f_failed_session_name ()
{
	l_WORKFLOW_NAME=$1
	l_BATCH_ID=$2
	echo "Batch_id: $l_BATCH_ID"
	echo "l_WORKFLOW_NAME::$l_WORKFLOW_NAME"
	echo "`PrInfD`  : Calling the function l_f_run_ora_query." >>  $LOG_FILE
 echo "$SQL_DIR/select_failed_session_name.sql $l_WORKFLOW_NAME $l_BATCH_ID"
 l_f_run_ora_query "$SQL_DIR/select_failed_session_name.sql $l_WORKFLOW_NAME $l_BATCH_ID"	

 }