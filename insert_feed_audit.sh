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
. /u02/Scripts/Configuration_File.cfg

script_name=$( basename $0 )
#creating log file
FEED_AUDIT_LOG_FILE=$LOG_DIR/Feed_Audit_`date +%Y-%m-%d-%H_%M_%S`.log
touch $FEED_AUDIT_LOG_FILE

echo "`PrInfD`:Feed Audit Process Started...." > $FEED_AUDIT_LOG_FILE
echo "`PrInfD`:SCRIPT NAME: $script_name" >> $FEED_AUDIT_LOG_FILE

if [ $# < 7 ]
then
echo "`PrErrD`:Wrong number of parameters are used to invoke the script. The script expects 7 or more parameters and the user has passed $# parameters. Script will exit now. " >> $FEED_AUDIT_LOG_FILE
exit 1
else  
echo "`PrInfD`:Feed Audit Process has been invoked with the following parameters:$1-$2-$3-$4-$5-$6-$7-$8" >> $FEED_AUDIT_LOG_FILE
fi

plsql_code_status=`sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
set feedback on
set serveroutput on
declare 
STEP_LOG_ID NUMBER := $1;
FEED_ID VARCHAR2(50) := '$2';
FILE_SIZE NUMBER := $3;
FILE_NAME VARCHAR2(100) := '$4';
BATCH_DATE VARCHAR2(10) := '$5';
FILE_ARRIVAL_DTTM VARCHAR2(50) := '$6' ;
AMOUNT_SUM_CHK NUMBER (20,2) := $7 ;
RUN_DATE VARCHAR2(50) := '$8' ;
ERR_CD NUMBER;
begin
 ODS_UTL.PKG_FWK_UTL.p_INSERT_FEED_AUDIT(STEP_LOG_ID,FEED_ID,FILE_SIZE,FILE_NAME,TO_DATE(BATCH_DATE,'YYYYMMDD'),TO_TIMESTAMP(FILE_ARRIVAL_DTTM,'YYYY-MM-DD HH24:MI:SS'),AMOUNT_SUM_CHK,TO_DATE(RUN_DATE,'YYYYMMDD'),ERR_CD);
 dbms_output.put_line('ERROR_CODE:'||ERR_CD||':');
end;
/
EOF`



status=`echo $plsql_code_status | awk -F':' '{print$2}'`
echo  "`PrInfD`:Value of the SQL Code is : $plsql_code_status"  >> $FEED_AUDIT_LOG_FILE




if [ $status != 0 ] 
then 
echo "`PrErrD`:An error occurred in executing the SQL Code. Status of execution of the SQL Code is $status  "  >> $FEED_AUDIT_LOG_FILE
exit 1
fi
