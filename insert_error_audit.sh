#!/bin/sh
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

script_name=$( basename $0 )
#Calling configuration file
. /u02/cifs/informatica/INT_INFA_TEST/CDD_DEV/Scripts/Configuration_File.cfg

#creating log file
ERROR_AUDIT_LOG_FILE=$LOG_DIR/Error_Audit_`date +%Y-%m-%d-%H_%M_%S`.log
touch $ERROR_AUDIT_LOG_FILE

echo "`PrInfD`:Error Audit Process Started...." > $ERROR_AUDIT_LOG_FILE

echo "`PrInfD`:SCRIPT NAME: $script_name" >> $ERROR_AUDIT_LOG_FILE
plsql_code_status=`sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
set feedback on
set serveroutput on
declare 
STEP_LOG_ID NUMBER := $1;
ERR_CD VARCHAR2(10) := '$2';
ERR_CAT_CD VARCHAR2(20) := '$3';
SRC_TABLE_NAME VARCHAR2(100) := '$4';
BATCH_DATE VARCHAR2(10) := '$5';
O_ERR_CD NUMBER;
begin
 ODS_UTL.PKG_FWK_UTL.p_INSERT_ERROR_AUDIT(STEP_LOG_ID,ERR_CD,ERR_CAT_CD,CURRENT_TIMESTAMP,SRC_TABLE_NAME,TO_DATE(BATCH_DATE,'YYYYMMDD'),O_ERR_CD);
 dbms_output.put_line('ERROR_CODE:'||O_ERR_CD||':');
end;
/
EOF`

echo "`PrInfD`:Value of the SQL Code is : $plsql_code_status" >> $ERROR_AUDIT_LOG_FILE

status=`echo $plsql_code_status | awk -F':' '{print$2}'`

if [ $status != 0 ] 
then 

echo "`PrErrD`:An error occurred in executing the SQL Code. Status of execution of the SQL Code is $status  "  >> $ERROR_AUDIT_LOG_FILE
 exit 1
 
fi
