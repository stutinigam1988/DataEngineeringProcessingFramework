#!/bin/sh
script_name=$( basename $0 )
#Calling configuration file
. /u02/Scripts/Configuration_File.cfg
set_batch_date_of_steps=$LOG_DIR/set_batch_date_of_steps_`date +%Y-%m-%d-%H_%M_%S`.log

echo " in set_batch_date_of_steps "
touch $set_batch_date_of_steps

echo "set_batch_date_of_steps Process Started...." > $set_batch_date_of_steps

echo "SCRIPT NAME: $script_name" >> $set_batch_date_of_steps

# if [ $# != 2 ]
# then
 # echo "wrong nos of parameters expected 2 and actual ::"$# 
 # exit 1
# fi 


plsql_code_status=` sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
     WHENEVER SQLERROR EXIT FAILURE
     WHENEVER OSERROR EXIT FAILURE
	 set feedback on
     set serveroutput on
     declare 
            LIST_OF_STEP_ID VARCHAR2(50):= '$1';
            BATCH_DATE      VARCHAR2(20) := '$2' ;
			SET_LAST_DATE_AS_NULL VARCHAR2(1) := '$3';
            ERR_CD NUMBER;
     begin
            PKG_FWK_UTL.p_set_batch_date(LIST_OF_STEP_ID,TO_DATE(BATCH_DATE,'YYYYMMDD'),ERR_CD, SET_LAST_DATE_AS_NULL);
			dbms_output.put_line('ERROR_CODE:'||ERR_CD||':');
     end;
    /
EOF`

echo "$plsql_code_status"

status=`echo $plsql_code_status | awk -F':' '{print$2}'`

echo $plsql_code_status #| awk -F':' '{print$3}'

echo " status ::"$status 

if [ $status != 0 ] 
then 

echo " status ::$status " 
exit 1

fi


