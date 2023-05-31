#!/bin/sh
script_name=$( basename $0 )
#Calling configuration file
. /u02/cifs/Scripts/Configuration_File.cfg
END_BATCH_LOG_FILE=$LOG_DIR/END_BATCH_Audit_`date +%Y-%m-%d-%H_%M_%S`.log

echo " in update step audit "

touch $END_BATCH_LOG_FILE

echo " Batch start Process ...." > $END_BATCH_LOG_FILE

echo "SCRIPT NAME: $script_name" >> $END_BATCH_LOG_FILE

plsql_code_status=` sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
     WHENEVER SQLERROR EXIT FAILURE
     WHENEVER OSERROR EXIT FAILURE
	 set feedback on
     set serveroutput on
     declare 
            STEP_ID VARCHAR2(50):= '$1';
            o_batch_id fwk_batch_audit.batch_id%type;
            o_err_code pls_integer;
     begin
            pkg_fwk_utl.p_end_batch_id (STEP_ID, o_batch_id, o_err_code);
			dbms_output.put_line('BATCH_ID.. '||o_batch_id||'....');
			dbms_output.put_line('ERROR_CODE:'||o_err_code||':');
			
     end;
    /
EOF`

echo "value of plsql_code_status ::$plsql_code_status"

status=`echo $plsql_code_status | awk -F':' '{print$2}'`

echo $plsql_code_status #| awk -F':' '{print$3}'

echo " status ::"$status 

#|| [ $wc_staus != 0 ] 

if [ "$status" != 0 ] 
then 

echo " status ::$status " 

exit 1

fi


