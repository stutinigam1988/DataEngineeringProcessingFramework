#!/bin/sh

PrInf="INFO"
PrErr="ERROR"
export PrInf
export PrErr
alias DATE='echo `date +%Y-%m-%d_%H:%M:%S`'
alias PrInfD='echo $PrInf : `DATE` : `basename $0`'
alias PrErrD='echo $PrErr : `DATE` : `basename $0`'
export PrInfD
export PrErrD

#################################################################################################
#Function :	DateTime
# 
#Description:	Function is used perform validations  and verifications on Date and Time string 
#		passed as a argument. 
#		e.g. Check if the format of the Date time is valid etc
################################################################################################
DateTime()
{
    echo "In Datetime" 
	function CheckLeapYear
	#
	# Set LEAP_YEAR to indicate whether the current year is a leap-year
	# or not (1/0), and to set the number of days within the year as well.
	#
	# Rules for a leap-year:
	#
	#  It is a leap-year if the year is a completely divisible by 4 with
	#  no remainder, except for the last year of a century (i.e. completely
	#  divisible by 100), unless the century itself is completely
	#  divisible by 4 (i.e. the year is completely divisible by 400) - for 
	#  example 2000 is a leap-year, but 1900 and 2100 are not.
	#
	{
	 LEAP_YEAR=0
	
	 # Check if completely divisible by 4
	 (( TEST_LEAP_YEAR = REP_YYYY % 4 ))
	 if [ "$TEST_LEAP_YEAR" -eq 0 ]
	 then
	  # Exclude end of century years
	  (( TEST_LEAP_YEAR = REP_YYYY % 100 ))
	  if [ "$TEST_LEAP_YEAR" -ne 0 ]
	  then
	   LEAP_YEAR=1
	  else
	   # Except for where the century is divisible by 4
	   (( TEST_LEAP_YEAR = REP_YYYY % 400 ))
	   if [ "$TEST_LEAP_YEAR" -eq 0 ]
	   then
	    LEAP_YEAR=1
	   fi
	  fi
	 fi
	
	 if [ $LEAP_YEAR -eq 1 ]
	 then
	  DAYS_IN_YEAR=366
	 else
	  DAYS_IN_YEAR=365
	 fi
	}
	
	function DoDayOfYear
	{
	 LOOPER=1
	 DAY_OF_YEAR=$REP_DD
	
	 # Add together the days in all the preceding months
	 while [ $LOOPER -lt $REP_MM ]
	 do 
	  case $LOOPER in
	   1|3|5|7|8|10|12) ((DAY_OF_YEAR=DAY_OF_YEAR+31)) ;;
	   4|6|9|11)        ((DAY_OF_YEAR=DAY_OF_YEAR+30)) ;;
	   2) if [ "$LEAP_YEAR" -eq 1 ]
	      then
	       ((DAY_OF_YEAR=DAY_OF_YEAR+29))
	      else
	       ((DAY_OF_YEAR=DAY_OF_YEAR+28))
	      fi ;;
	  esac
	  ((LOOPER=LOOPER+1))
	 done
	}
	
	function UndoDayOfYear
	{
	 DAYS_IN_MONTH=31
	 REP_MM=1
	 REP_DD="$DAY_OF_YEAR"
	
	 # Subtract months until we reach the correct one
	 while [ $REP_DD -gt $DAYS_IN_MONTH ]
	 do 
	  ((REP_DD=REP_DD-DAYS_IN_MONTH))
	  ((REP_MM=REP_MM+1))
	  case $REP_MM in
	   1|3|5|7|8|10|12) DAYS_IN_MONTH=31 ;;
	   4|6|9|11)        DAYS_IN_MONTH=30 ;;
	   2) if [ "$LEAP_YEAR" -eq 1 ]
	      then
	       DAYS_IN_MONTH=29
	      else
	       DAYS_IN_MONTH=28
	      fi ;;
	  esac
	 done
	}
	
	function BreakFormat {
	
	   CC_STRT_POS=`echo $FORMAT_STR | grep CC`
	   YYYY_STRT_POS=`echo $FORMAT_STR | grep YYYY`
	   YY_STRT_POS=`echo $FORMAT_STR | grep YY`
	   MM_STRT_POS=`echo $FORMAT_STR | grep MM`
	   MON_STRT_POS=`echo $FORMAT_STR | grep MON`
	   DD_STRT_POS=`echo $FORMAT_STR | grep DD`
	   HH_STRT_POS=`echo $FORMAT_STR | grep HH` 
	   MI_STRT_POS=`echo $FORMAT_STR | grep MI`
	   SS_STRT_POS=`echo $FORMAT_STR | grep SS`
	
	}
	
	
	function DoFormatString
	# Compound the result date from the various parts
	# Defaults to "yyyymmdd" if the format is not recognised
	#
	# And yes, this should be made into an intelligent routine
	# which will interpret the string rather than all the cases...
	{
	 REP_YY=$(echo $REP_YYYY | cut -c3-4)
	 case "$FORMAT_STR" in
	  "YYYYMMDD")   REP_DATE="$REP_YYYY""$REP_MM""$REP_DD"   ;;
	  "YYYY/MM/DD") REP_DATE="$REP_YYYY"/"$REP_MM"/"$REP_DD" ;;
	  "YYMMDD")     REP_DATE="$REP_YY""$REP_MM""$REP_DD"     ;;
	  "YY/MM/DD")   REP_DATE="$REP_YY"/"$REP_MM"/"$REP_DD"   ;;
	
	  "DDMMYYYY")   REP_DATE="$REP_DD""$REP_MM""$REP_YYYY"   ;;
	  "DD/MM/YYYY") REP_DATE="$REP_DD"/"$REP_MM"/"$REP_YYYY" ;;
	  "DDMMYY")     REP_DATE="$REP_DD""$REP_MM""$REP_YY"     ;;
	  "DD/MM/YY")   REP_DATE="$REP_DD"/"$REP_MM"/"$REP_YY"   ;;
	
	  "MMDDYYYY")   REP_DATE="$REP_MM""$REP_DD""$REP_YYYY"   ;;
	  "MM/DD/YYYY") REP_DATE="$REP_MM"/"$REP_DD"/"$REP_YYYY" ;;
	  "MMDDYY")     REP_DATE="$REP_MM""$REP_DD""$REP_YY"     ;;
	  "MM/DD/YY")   REP_DATE="$REP_MM"/"$REP_DD"/"$REP_YY"   ;;
	
	  "DDMM")       REP_DATE="$REP_DD""$REP_MM"              ;;
	  "DD/MM")      REP_DATE="$REP_DD"/"$REP_MM"             ;;
	  "MMDD")       REP_DATE="$REP_MM""$REP_DD"              ;;
	  "MM/DD")      REP_DATE="$REP_MM"/"$REP_DD"             ;;
	
	  "MMYY")       REP_DATE="$REP_MM""$REP_YY"              ;;
	  "MM/YY")      REP_DATE="$REP_MM"/"$REP_YY"             ;;
	  "MMYYYY")     REP_DATE="$REP_MM""$REP_YYYY"            ;;
	  "MM/YYYY")    REP_DATE="$REP_MM"/"$REP_YYYY"           ;;
	
	  "YYMM")       REP_DATE="$REP_YY""$REP_MM"              ;;
	  "YY/MM")      REP_DATE="$REP_YY"/"$REP_MM"             ;;
	  "YYYYMM")     REP_DATE="$REP_YYYY""$REP_MM"            ;;
	  "YYYY/MM")    REP_DATE="$REP_YYYY"/"$REP_MM"           ;;
	
	  *)            REP_DATE="$REP_YYYY""$REP_MM""$REP_DD"   ;;
	 esac
	}
	
	function CheckFormat 
	{
	#
	# 1. The function only validates the number in the date format with the format specified.
	# 2. The ERRMSG variable should be exported from the calling progam. The variable will  
	#    have the error message if any.
	# 3. The return value is 1 if any error occurs else the return value is 0 
	# 4. Following values are validated:
	#    a. The length of the date string and format string should be same
	#    b. Hours, Minutes, Seconds should be greater than 0 and less than 23,59,59 resp.
	#    c. The YYYY and CC should not exist in the same format
	#    d. The MM and MON should not exist in the same format
	#    e. If CC is present in format and YY is absent, then default is 00 as year.
	#    f. If YY is present in format and CC is absent, then default is 20th century.
	#    g. DD is validated based on the month and year. You should have MM and YYYY/CCYY to 
	#       to validate the DD.
	#    h. MON is validated against JAN,FEB ..... DEC 
	#    i. The validation are case insensitive
	#    j. The comparison takes care of the CC/YY/CCYY/YYYY/MM/MON/DD/HH/MI/SS only. No other 
	#       formats are supported.
	#
	#
	#
	
	#
	# Validate the length 
	#
	
	echo "In check format"
	LENGTH_OF_DATE=`echo $DATE_TO_VALID | awk '{print length($0)}'`
	LENGTH_OF_FRMT=`echo $FORMAT_STR | awk '{print length($0)}'`
	
	if [ $LENGTH_OF_DATE -ne $LENGTH_OF_FRMT ];then
	   ERRMSG='Length of Format String Does not Match Date String'
	   return 1
	fi
	
	#
	# Finished Validation of the length
	#
	
	
	REP_YYYY=2004   #  Defined only for validation of time factor. There is call to CheckLeapYear
	
	#
	# As stated in the 4.i description of the function, the validation is case insensitive.
	#
	
	FORMAT_STR=`echo $FORMAT_STR | awk '{print toupper($0)}'`
	MONTH_STR='JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC' 
	
	CC_STRT_POS=`echo $FORMAT_STR | grep CC`
	YYYY_STRT_POS=`echo $FORMAT_STR | grep YYYY`
	YY_STRT_POS=`echo $FORMAT_STR | grep YY`
	MM_STRT_POS=`echo $FORMAT_STR | grep MM`
	MON_STRT_POS=`echo $FORMAT_STR | grep MON`
	DD_STRT_POS=`echo $FORMAT_STR | grep DD`
	HH_STRT_POS=`echo $FORMAT_STR | grep HH` 
	MI_STRT_POS=`echo $FORMAT_STR | grep MI`
	SS_STRT_POS=`echo $FORMAT_STR | grep SS`
	
	if [ "$CC_STRT_POS" != "" -a "$YYYY_STRT_POS" != "" ];then
	   ERRMSG='CC and YYYY cannot exist together'
	   return  1
	fi
	
	if [ "$MM_STRT_POS" != "" -a "$MON_STRT_POS" != "" ];then
	   ERRMSG='MM and MON cannot exist together'
	   return 1
	fi
	
	if [ "$CC_STRT_POS" != "" ];then
	   CC_STRT_POS=`echo $FORMAT_STR | awk '{print match($0, "CC")}'`
	   CC=`echo $DATE_TO_VALID $CC_STRT_POS | awk '{print substr($1,$2, 2)}'`
	fi
	
	if [ "$YY_STRT_POS" != "" ];then
	   YY_STRT_POS=`echo $FORMAT_STR | awk '{print match($1,"YY")}'`
	   YY=`echo $DATE_TO_VALID $YY_STRT_POS  | awk '{print substr($1, $2, 2)}'`
	fi
	
	if [ "$CC_STRT_POS" != "" -a "$YY_STRT_POS" != "" ];then
	   REP_YYYY=$CC$YY 
	elif [ "$CC_STRT_POS" != "" ];then
	   REP_YY=${CC}00
	elif [ "$YY_STRT_POS" != "" ];then
	   REP_YY=20$YY
	fi
	
	if [ "$YYYY_STRT_POS" != "" ];then
	   YYYY_STRT_POS=`echo $FORMAT_STR | awk '{print match($0,"YYYY")}'`
	   YYYY=`echo $DATE_TO_VALID $YYYY_STRT_POS | awk '{print substr($1, $2, 4)}'`
	   REP_YYYY=$YYYY 
	fi
	if [ "$MM_STRT_POS" != "" ];then
	   MM_STRT_POS=`echo $FORMAT_STR | awk '{print match($1, "[MM]")}'`
	   MM=`echo $DATE_TO_VALID $MM_STRT_POS | awk '{print substr($1, $2, 2)}'`
	   REP_MM=$MM
	fi
	
	if [ "$MON_STRT_POS" != "" ];then
	   MON_STRT_POS=`echo $FORMAT_STR | awk '{print match($0,"[mM][oO][nN]")}'`
	   MON=`echo $DATE_TO_VALID $MON_STRT_POS | awk '{print substr($1, $2,  3)}'`
	fi
	if [ "$DD_STRT_POS" != "" ];then
	   DD_STRT_POS=`echo $FORMAT_STR | awk '{print match($0,"DD")}'`
	   DD=`echo $DATE_TO_VALID  $DD_STRT_POS | awk '{print substr($1, $2, 2)}'`
	fi
	if [ "$HH_STRT_POS" != "" ];then
	   HH_STRT_POS=`echo $FORMAT_STR | awk '{print match($0,"HH")}'`
	   HH=`echo $DATE_TO_VALID $HH_STRT_POS  | awk '{print substr($1, $2,   2)}'`
	   if [ $HH -lt 0 -o $HH -gt 23 ];then
	      ERRMSG='Hours should be between 0 and 23'
	      return 1
	   fi
	fi
	if [ "$MI_STRT_POS" != "" ];then
	   MI_STRT_POS=`echo $FORMAT_STR | awk '{print match($0,"MI")}'`
	   MI=`echo $DATE_TO_VALID $MI_STRT_POS  | awk '{print substr($1, $2,   2)}'`
	   if [ $MI -lt 0 -o $MI -gt 59 ];then
	      ERRMSG='Minutes should be between 0 and 59'
	      return 1
	   fi
	fi
	if [ "$SS_STRT_POS" != "" ];then
	   SS_STRT_POS=`echo $FORMAT_STR | awk '{print match($0,"SS")}'`
	   SS=`echo $DATE_TO_VALID $SS_STRT_POS  | awk '{print substr($1, $2,   2)}'`
	   if [ $SS -lt 0 -o $SS -gt 59 ];then
	      ERRMSG='Seconds should be between 0 and 59'
	      return 1
	   fi
	fi
	
	if [ "$MON" != "" ];then
	   MON=`echo $MON | awk '{print toupper($0)}'`
	   MM=`echo $MONTH_STR $MON | awk '{print match($1,$2)}'`
	   if [ $MM -eq 0 ];then
	      ERRMSG="Invalid Month is passed"
	      return 1
	   else
	       MM=`expr $MM / 4 + 1`
	       REP_MM=$MM
	   fi
	fi
	if [ "$MM" != "" ];then
	    if [ "$MM" -lt 1 -o "$MM" -gt 12 ];then
	        ERRMSG="Month should be between 1 and 12"
	        return 1
	    fi
	fi
	if [ "$MM" = "" -a "$DD" != "" ];then
	     ERRMSG="MM should be present to validate DD."
	     return 1
	fi 
	
	if [ "$REP_YYYY" = "" -a "$DD" != "" ];then
	     ERRMSG="YYYY should be present to validate DD."
	     return 1
	fi 
	
	CheckLeapYear
	
	case $REP_MM in
	     01|1|03|3|05|5|07|7|08|8|10|12) DAYS_IN_MONTH=31 ;;
	     04|4|06|6|09|9|11)        DAYS_IN_MONTH=30 ;;
	     2|02) if [ "$LEAP_YEAR" -eq 1 ]; then
	       DAYS_IN_MONTH=29
	      else
	       DAYS_IN_MONTH=28
	      fi ;;
	esac
	
	if [ "$DD" != "" ];then
	   if [ $DD -lt 1 -o $DD -gt $DAYS_IN_MONTH ];then
	      ERRMSG="Days Should be between 1 and $DAYS_IN_MONTH"
	      return 1
	   fi
	fi
	return 0
	
	}
	
	
	#######################################################
	###                  MAIN SCRIPT                    ###
	#######################################################
	
	# Parse parameters
	
	# Defaults
	ALTERATION=0
	FORMAT_STR="DDMMYYYY"
	VERIFY=""
	REP_YYYY=""
	REP_YY=""
	REP_MM=""
	REP_DD=""
	REP_MON=""
	REP_HH=""
	REP_MI=""
	REP_SS=""
	DATE_TO_VALID=""
	DD=""
	
	# Parse the parameters
	while [ $# -gt 0 ]
	do
	
	  case $1 in
	    [0-9]*|[-+][0-9]*) ALTERATION=$1 ;;
	    [a-z,A-Z]*) FORMAT_STR=$1 ;;
	    -[fF]*) FORMAT_STR=$(echo $1 | cut -c3-) ;;
	    -[rR]*) REVERSE_STR="Y"
	            case $CENTURY_STR in
	              N) FORMAT_STR="YYMMDD"   ;;
	              *) FORMAT_STR="YYYYMMDD" ;;
	            esac
	            ;;
	    -[cC]*) CENTURY_STR="N"
	            case $REVERSE_STR in
	              Y) FORMAT_STR="YYMMDD" ;;
	              *) FORMAT_STR="DDMMYY" ;;
	            esac
	            ;;
	    -[vV]*) DATE_TO_VALID=$2
	            FORMAT_STR=$3
		    VERIFY=Y
		break
	            ;;
	  esac
	  shift
	done
	
	# Get todays date
	REP_YYYY=$(date +%Y)
	REP_YY=$(date +%y)
	REP_MM=$(date +%m)
	REP_DD=$(date +%d)
	REP_MON=$(date +%h)
	REP_HH=$(date +%H)
	REP_MI=$(date +%M)
	REP_SS=$(date +%S)
	
	
	if [ "$VERIFY" = "Y" ]
	then
		if [ "$FORMAT_STR" = "" ];then
			echo "Either Date or Format not specified"
			return 1
		fi
		CheckFormat
		return $? 
	
	fi
	
	# If no alteration is required, skip the next bit
	if [ $ALTERATION -ne 0 ]
	then
	  CheckLeapYear
	  DoDayOfYear
	
	  # Different rules for back/forwards in time
	  if [ $ALTERATION -lt 0 ]
	  then
	
	   ((ALTERATION=ALTERATION*-1))
	   while [ $ALTERATION -ge $DAY_OF_YEAR ]
	   do
	    ((ALTERATION=ALTERATION-DAY_OF_YEAR))
	    ((REP_YYYY=REP_YYYY-1))
	    # After changing year we need to check for leap-years
	    CheckLeapYear
	    DAY_OF_YEAR=$DAYS_IN_YEAR
	   done
	   ((DAY_OF_YEAR=DAY_OF_YEAR-ALTERATION))
	
	  else
	
	   ((DAYS_LEFT=DAYS_IN_YEAR-DAY_OF_YEAR))
	   while [ $ALTERATION -gt $DAYS_LEFT ]
	   do
	    ((ALTERATION=ALTERATION-DAYS_LEFT))
	    ((REP_YYYY=REP_YYYY+1))
	    # After changing year we need to check for leap-years
	    CheckLeapYear
	    DAY_OF_YEAR=0
	    DAYS_LEFT=$DAYS_IN_YEAR
	   done
	   ((DAY_OF_YEAR=DAY_OF_YEAR+ALTERATION))
	
	  fi
	
	  # Convert the result to day-month
	  UndoDayOfYear
	
	fi # end of any alteration
	
	# Pad out the dates with leading zeros
	REP_YYYY=`echo -e $REP_YYYY | awk '{printf("%04d\n",$0)}'`
	REP_MM=`echo -e $REP_MM | awk '{printf("%02d\n",$0)}'`
	REP_DD=`echo -e $REP_DD | awk '{printf("%02d\n",$0)}'`

	#typeset -Z4 REP_YYYY
	#typeset -Z2 REP_MM
	#typeset -Z2 REP_DD
	
	# Convert the string into upper case
	typeset -u FORMAT_STR
	
	# Format the output string
	DoFormatString
	
	# And output the final result...
	echo "$REP_DATE"
	
	return 0
}

#########################################################################
#Function : is_null
#          Function is used to validate if the passed argument
#          is null or not
#
#          usage: is_null $ARG1
#
#########################################################################


is_null()
{
	column_name=$1
        eval inp_val=\$$column_name
        if [ $inp_val ]
        then
                #echo "the input string is not null and is $inp_val"
                return 1
        fi
                echo "input string empty"
                return 0
}

DateTime -v $1 $2
