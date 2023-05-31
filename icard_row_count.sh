#!/bin/sh
script_name=$( basename $0 )
#Calling configuration file
. /u02/Scripts/Configuration_File.cfg
icard_row_count=$LOG_DIR/icard_row_count_`date +%Y-%m-%d-%H_%M_%S`.log

echo " in icard_row_count "
touch $icard_row_count

echo "icard_row_count Process Started...." > $icard_row_count

echo "SCRIPT NAME: $script_name" >> $icard_row_count

if [ $# != 3 ]
then
 echo "wrong nos of parameters expected 3 and actual ::"$# 
 exit 1
fi 

plsql_code_status=` sqlplus -s ${CONNECT_STRING} <<EOF | grep -v 'Connected.' | grep -v '^$'
     WHENEVER SQLERROR EXIT FAILURE
     WHENEVER OSERROR EXIT FAILURE
	 set feedback on
     set serveroutput on
     declare 
          v_batch_date varchar2(20);
		  v_step_id number := $2;
     begin

          select to_char(next_batch_date,'YYYYMMDD')
		  into v_batch_date 
          from fwk_step_config where step_id=v_step_id;
		  
		  DBMS_OUTPUT.PUT_LINE('~'||v_batch_date||'~');

	end;
    /
EOF`

echo "$plsql_code_status"

BATCH_DATE=`echo $plsql_code_status | awk -F'~' '{print$2}'`

plsql_code_status=` sqlplus -s $CONNECT_STRING_ICARD <<EOF | grep -v 'Connected.' | grep -v '^$'
     WHENEVER SQLERROR EXIT FAILURE
     WHENEVER OSERROR EXIT FAILURE
	 set feedback on
     set serveroutput on
     declare 
          v_source_table_name varchar2(50) :='$1';
		  v_batch_date varchar2(20) :='$BATCH_DATE';
		  v_rowcnt number;
     begin

			select substr(v_source_table_name,INSTR(v_source_table_name,'.',1)+1,length(v_source_table_name)) into v_source_table_name from dual;
			
          select ROWCNT 
			into v_rowcnt
			from KORT.ODS_LOG_VIEW 
			where to_char(ETL_BATCHDATE,'YYYYMMDD')=v_batch_date and UPPER(OUTPUT_TABLE)=UPPER(v_source_table_name);
			
			
			DBMS_OUTPUT.PUT_LINE('~'||v_rowcnt||'~');
	end;
    /
EOF`

echo "$v_rowcnt"

echo "$plsql_code_status"

ROWCNT=`echo $plsql_code_status | awk -F'~' '{print$2}'`

echo $plsql_code_status 

echo " ROWCNT in icard_row_cnt ::"$ROWCNT 

export ROWCNT

if [ $ROWCNT != 0 ] 
then 
echo " ROWCNT ::$ROWCNT " 
fi



