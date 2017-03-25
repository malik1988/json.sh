#!/bin/sh -ex
# WIP JSON parser

JGROUPS=''
GROUPORVAR=0
NEWWORD=0

endword() {
    NEWWORD=0
    if [ $GROUPORVAR -eq 1 ]
    then 
        echo "${JGROUPS}/$LASTWORD = $CURWORD"
        GROUPORVAR=0
    else
        echo "${JGROUPS}/$CURWORD"
    fi
    LASTWORD=$CURWORD
    CURWORD=''
    TYPE=''
}

startword() {
    NEWWORD=1
}

addword() {
    CURWORD="${CURWORD}${1}"
}


json() {
for char in $(cat $1 | sed 's/\(.\)/\1 /g')
do
    case "$char" in
        ' ')
            if [ $NEWWORD -eq 1 ] && [ $TYPE == "string" ]
            then
                addword $char
            fi
            ;;
#   Works in bash, not in sh.
#       [[:alpha:]])
        [ABCDEFGHIJKLMNOPQRSTUVWXYZ])
            addword $char
        ;;
        [abcdefghijklmnopqrstuvwxyz])
            addword $char 
        ;;
#       [[:digit:]])
        [0123456789])
            if [ $NEWWORD -eq 1 ]
            then
                addword $char
            else
                TYPE="number"
                startword
                addword $char
            fi
        ;;
        [,])
            if [ $NEWWORD -eq 1 ] && [ $TYPE == "string" ]
            then
                addword $char
            elif [ $NEWWORD -eq 1 ] && [ $TYPE == "number" ]
            then
                endword
            fi
        ;;
        "\"")
            if [ $NEWWORD -eq 1 ]
            then
                endword
            else
                TYPE="string"
                startword
            fi
        ;;
        ':')
            GROUPORVAR=1
        ;;
        '{')
            if [ $GROUPORVAR -eq 1 ]
            then
                CURGROUP="${LASTWORD}"
                JGROUPS="${JGROUPS}/${CURGROUP}"
                GROUPORVAR=0
            fi
        ;;
        '}')
            if [ $NEWWORD -eq 1 ] && [ $TYPE == "number" ]
            then
                endword
            fi
            JGROUPS=$(echo $JGROUPS | sed 's@/'$CURGROUP'$@@')
            CURGROUP=$(echo $JGROUPS | grep -oE '[^/]+$')
            ;;
    esac
done < "$1"
}

varmatch=0
objmatch=0
silmatch=0
valmatch=0
match=''
arguments=''
na=0
for argument in $@
do
    case $argument in
        -v)
		na=1
		varmatch=1
		;;
        -V)
		na=1
		valmatch=1
		;;
	-s)
		na=1
		silmatch=1
		;;
	-o)
		na=1
		objmatch=1
		;;
	*)
		if [ $na -eq 1 ] && [ $objmatch -eq 1 ]
		then
			match="$argument\$"
		elif [ $na -eq 1 ] && [ $varmatch -eq 1 ]
		then
			match="$argument\ ="
		elif [ $na -eq 1 ] && [ $silmatch -eq 1 ]
		then
			match="$argument\ ="
		elif [ $na -eq 1 ] && [ $valmatch -eq 1 ]
		then
			match="=\ $argument\$"
		else
			file="$argument"
		fi
		na=0
		;;
esac
done

if [ $silmatch -eq 1 ]
then
    json $file | grep "$match" | sed 's/.*= //'
else
    json $file | grep "$match"
fi
