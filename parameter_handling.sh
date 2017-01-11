#!/bin/bash

parameters=$*

nextArgIsValue=false
vp1=
vp2=
vp3=
v=
w=

for i in $parameters
do
	if $nextArgIsValue; then
		eval "$name=\$i"
		nextArgIsValue=false
		continue
	fi

	case $i in
		--*)name=$(echo $i|sed -e s/"--"//);
			case $name in
				*=*)value=$(echo $name|cut -f2 -d'='); 
					name=$(echo $name|cut -f1 -d'=');
					
					eval "$name=\$value"
				;;
				*) 
					case $name in
						vp1|vp2|vp3) nextArgIsValue=true;;
						*) echo "handle non valued long parameter $name";;
					esac
				;;
			esac
		;;
		-*)	name=$(echo $i|sed -e s/"-"//);
			for l in $(seq 1 ${#name})
			do
				p=$(echo $name|cut -c$l)
				case $p in
					a|b) echo "handle non valued short parameter $p";;
					v|w) 
							if [ $l -lt ${#name} ]; then
								value=$(echo $name|cut -c$((l+1))-)
								eval "$p=\$value"
								break
							else
								nextArgIsValue=true
								name=$p
							fi
				esac
			done
		;;
		*) argList="${argList} $i";
		;;
	esac
done

echo "#### Testing ####"
echo vp1:$vp1
echo vp2:$vp2
echo vp3:$vp3
echo v:$v
echo w:$w
echo "arg list = $(echo;for _a in $argList; do echo $_a; done)"


# Bash arguments:
# if begins with "--":
# 	handle_double-dash_option()
# else if begins with "-":
#	handle_one-dash_options()
# else:
#	handle_argument()
#
#
# def handle_double_dash_option():
# 	if not begins_with_supported_parameter_name():
#		exit()
#	else:
#		separate_parameter_name_and_value()
#
# def handle_one-dash_options():
#	for letter in param:
#		if not valued_option(letter):
#			handle_non_valued_option()
#		else
#			letter=value //value goes on until next whitespace

