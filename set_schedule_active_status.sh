#!/bin/sh
script_name=$( basename $0 )
#Calling configuration file
. /u02/Scripts/Configuration_File.cfg
set_schedule_active_status=$LOG_DIR/set_schedule_active_status_`date +%Y-%m-%d-%H_%M_%S`.log

echo " in set_batch_date_of_steps "
touch $set_schedule_active_status

echo "set_schedule_active_status Process Started...." > $set_schedule_active_status

echo "SCRIPT NAME: $script_name" >> $set_schedule_active_status

if [ $# != 3 ]
then
   
   if [ "$1" == "" ]
   then
     
	 echo "step id list is null "
	 exit 1
	 
   elif [ "$2" == "" ]
   then
     
	 echo "step id list is null "
	 exit 1	
	 
   elif [ "$3" == "" ]
   then
 
	 echo "batch date is null, this is an optional parameter "
	 
   fi	 

fi 

plsql_code_status=` sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
     WHENEVER SQLERROR EXIT FAILURE
     WHENEVER OSERROR EXIT FAILURE
	 set feedback on
     set serveroutput on
     declare 
            LIST_OF_STEP_ID VARCHAR2(50) := '$1';
			SCHEDULE_ACTIVE VARCHAR2(1)  := '$2';  
            BATCH_DATE      VARCHAR2(20) := '$3' ;
            ERR_CD NUMBER;
     begin
            PKG_FWK_UTL.p_set_schedule_active_status(LIST_OF_STEP_ID, SCHEDULE_ACTIVE, TO_DATE(BATCH_DATE,'YYYYMMDD'),ERR_CD);
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


