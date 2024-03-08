#!/bin/bash

function min(){
	if test $1 -le $2; then
		echo $1
	else
		echo $2
	fi
}

function max(){
	if test $1 -ge $2; then
		echo $1
	else
		echo $2
	fi
}

function in_array(){
	declare -n array_name=$1
	value="$2"
	for element in ${array_name[@]}; do
		if test "$element" = "$value"; then
			return 0
		fi
	done
	return 1
}

function in_map(){
	declare -n map_name="$1"
	value="$2"
	for element in "${!map_name[@]}"; do
		if test "$element" = "$value"; then
			return 0
		fi
	done
	return 1
}

function argparse(){
	declare -g -a argv
	declare -a expected_flags
	declare -A flags_given

	current_opt=$1
	i=0

	# Get the expected flags
	while test "$current_opt" != "--" -a -n "$current_opt"; do
		current_opt=$1
		if test "$current_opt" = "--" -o -z "$current_opt"; then
			shift
			argv=("$@")
			break
		fi
		
		expected_flags[$i]=$current_opt
		i=$((i+1))
		shift
	done

	# Look for any of the expected flags in argv
	# flags_given keys are initialized with the flags given, and the values are
	# true or false depending on whether the flag expects a value or not
	for flag in "${expected_flags[@]}"; do
		short_form=$(echo $flag|cut -f1 -d/)
		long_form=$(echo $flag|cut -f2 -d/)
		regex='=$'
		if test -n "$long_form"; then
			if [[ "$long_form" =~ $regex ]] ; then
				long_form=$(echo $long_form|cut -f1 -d=)
				if in_array argv "--$long_form"; then
					eval 'declare -g _flag_'"$long_form"
					flags_given[--$long_form]="true"
				fi
			else
				if in_array argv "--$long_form" ; then
					eval 'declare -g _flag_'"$long_form"
					flags_given[--$long_form]="false"
				fi
			fi
		elif test -n "$short_form"; then
			if [[ "$short_form" =~ $regex ]] ; then
				short_form=$(echo $short_form|cut -f1 -d=)
				if in_array argv "-$short_form"; then
					eval 'declare -g _flag_'"$short_form"
					flags_given[-$short_form]="true"
				fi
			else
				if in_array argv "-$short_form"; then
					eval 'declare -g _flag_'"$short_form"
					flags_given[-$short_form]="false"
				fi
			fi
		else
			echo "Error:argparse: invalid format for option $flag"
			return 1
		fi
	done

	# Parse argv to put the correct values for the given flags
	is_arg_value="false"
	arg_name=""
	declare -a positionals
	i=${#positionals[@]}
	for arg in "${argv[@]}"; do
		if test $is_arg_value = "true"; then
			eval "_flag_$arg_name=\"\$arg\""
			is_arg_value="false"
			arg_name=""
			continue
		fi

		if in_map flags_given "$arg"; then
			if test ${flags_given["$arg"]} = "true"; then
				is_arg_value="true"
				arg_name="${arg##-}"
				arg_name="${arg_name##-}"
			else
				arg_name="${arg##-}"
				arg_name="${arg_name##-}"
				eval "_flag_$arg_name=true"
				arg_name=""
			fi
			continue
		fi
		positionals[$i]="$arg"
		i=$((i+1))
	done

	unset argv
	declare -g argv=("${positionals[@]}")
	unset positionals
}
