#!/bin/bash
#################################################################################################################
#NAME:                  : ETL_Indirect_File_list.sh                                                             #
#DESCRIPTION:           : This script will create file List for Indirect Loading used in Informatica            #
#OUTPUT File Name       : <<Feed Pattern>>_lst.txt                                                              #
#Script Author          : stuti nigam                                                                 #
#Create Date            : 09-Jan-2021                                                                           #
#Aruguments             : 1 (FEED_NAME_PATTERN)                                                                 #
#Modification Log       : None                                                                                  #
#################################################################################################################
script_name=$( basename $0 )
# Check for the number of arguments
args=$#
PROCESS_DATE=`date "+%Y-%m-%d"`
PROCESS_TS=`date "+%Y-%m-%d %H:%M:%S"`
FEED_NAME_PATTERN=$1
OUTPUT_FILE_NAME=$FEED_NAME_PATTERN"_lst.lst"
#Calling configuration file
. /u02/cifs/informatica/INT_INFA_TEST/CDD_DEV/Scripts/ETL_Indirect_File_list_CFG.cfg

LOG_FILE="$LOG_DIR/Log_ETL_Indirect_File_list"_"$FEED_NAME_PATTERN.log"
touch $LOG_FILE

echo "*****Start of the script*****" >> $LOG_FILE
echo "script_name : $script_name" >> $LOG_FILE
echo "PROCESS_DATE = $PROCESS_TS" >> $LOG_FILE
echo "No of Parameters : $args" >> $LOG_FILE
echo "Indirect File list name: $OUTPUT_FILE_NAME" >>$LOG_FILE

count=`ls -lrt $SRC_FILE_PATH | grep -i '.txt' | grep -i "$FEED_NAME_PATTERN" | wc -l` 

if [[ $args != 1 ]]
then
        echo "Error.  Invalid number of arguments" >> $LOG_FILE
		exit 1
elif  [[ $count = 0 ]] 
then
 echo " No File received for this Feed on $PROCESS_DATE" >> $LOG_FILE
    exit 2
    
fi
# write feed name in Indirect file list
if [[ $count > 0 ]] 
then 
ls -lrt $SRC_FILE_PATH | grep -i '.txt' |awk -F ' ' '{print $9}' | grep -i "$FEED_NAME_PATTERN" >  $SRC_FILE_PATH/$OUTPUT_FILE_NAME
echo " Below files added to Indirect list for processing.." >>$LOG_FILE
ls -lrt $SRC_FILE_PATH | grep -i '.txt'|awk -F ' ' '{print $9}' | grep -i "$FEED_NAME_PATTERN" >> $LOG_FILE
echo "*****End of the script***** ">> $LOG_FILE
exit 0
fi