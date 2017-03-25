#!/bin/sh

# OK, this is going to be a convoluted state machine based on the following states:
imov=0    # in middle of variable     [ "variable" = "..." ]
imosv=0   # in middle of string value [ "..." = "value" ]
imoo=0    # in middle of object       [ "object" {...} ]
imoas=0   # in middle of ambiguous string 
# And using the following vars:
cv=''     # current variable
lv=''     # last variable
csv=''    # current string value
lsv=''    # last string value
co=''     # current object
lo=''     # last object
aco=''    # all current objects
cas=''    # current abiguous string


get_co() {
	aco="$aco/$cas"
	co=$(echo "$aco" | sed 's^.*/^^')
}

get_lo() {
	lo=$co
	aco=$(echo "$aco" | sed 's^/'"$lo"'^^')
}

for char in $(cat $1 | sed 's/\(.\)/\1 /g')
do
	case $char in
		"{")
			imoas=0
			imoo=1
			get_co
			;;
		"}")
			imoo=0
			get_lo
			;;
		"\"")
			if [ $imosv -eq 1 ]
			then
				imosv=0
				echo "$cv: $csv"
			elif [ $imoas -eq 1 ]
			then
				imoas=0
				imosv=1
				cv="$cas"
			else
				imoas=1
			fi
			;;
		":")
			echo "Ignore" > /dev/null
			;;
		",")
			echo "Ignore" > /dev/null
			;;
		*)
			if [ $imoas -eq 1 ]
			then
				cas="${cas}${char}"
			elif [ $imosv -eq 1 ]
			then
				csv="${csv}${char}"
			else
				echo "Ignored: $char"
			fi
			;;
	esac
	echo "$char     | $imov $imosv $imoo $imoas"
done
