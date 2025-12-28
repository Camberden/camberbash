#! /bin/bash

flourish () {
	DATA[0]="     _/  _/    _/                            _/    "
	DATA[1]="  _/_/_/_/_/  _/_/_/      _/_/_/    _/_/_/  _/_/_/ "
	DATA[2]="   _/  _/    _/    _/  _/    _/  _/_/      _/    _/"
	DATA[3]="_/_/_/_/_/  _/    _/  _/    _/      _/_/  _/    _/ "
	DATA[4]=" _/  _/    _/_/_/      _/_/_/  _/_/_/    _/    _/  "

	# virtual coordinate system is X*Y ${#DATA} * 5

	REAL_OFFSET_X=0
	REAL_OFFSET_Y=0

	draw_char() {
	V_COORD_X=$1
	V_COORD_Y=$2

	tput cup $((REAL_OFFSET_Y + V_COORD_Y)) $((REAL_OFFSET_X + V_COORD_X))

	printf %c "${DATA[V_COORD_Y]:V_COORD_X:1}"
	}


	trap 'exit 1' INT TERM
	trap 'tput setaf 9; tput cvvis; clear' EXIT

	tput civis
	clear

	while :; do

	for ((c=1; c <= 7; c++)); do
	tput setaf $c
	for ((x=0; x<${#DATA[0]}; x++)); do
		for ((y=0; y<=4; y++)); do
		draw_char $x $y
		done
	done
	done

	done
}

echo "=====> [*] is to Stringify =====>"
echo "=====> [@] w/ QUOTES IS ITERABLE AND BEST! =====>"

printf '<%s>\n' "${yaml_params[@]}";

unset yaml_args
unset yaml_params

arr=(apple banana strawberry);

printf '<%s>\n' "${arr[*]}"
printf '<%s>\n' "${arr[@]}"

echo "=====> IFS =====>"
IFS=,
echo "${arr[@]}"
unset IFS

echo "=====> CAN REROUTE IFS TO PREVENT OVERWRITE =====>"
(IFS=,; echo "${arr[*]}"; echo $IFS)
unset arr

echo "=====> YOU FORGOT TO DECLARE! =====>";
declare -A arr
echo "=====> ASSOCIATIVE ARRAY: KEYS =====>";
arr[foo]=1
arr[bar]=2
# echo ${arr[foo]}

key=foo #establish the key

echo this is literal string called key "${arr[key]}";
echo actual key "${arr[$key]}"

echo "=====> ASSOCIATIVE ARRAY PRINTOUT =====>";
printf '<%s>\n' "${arr[@]}"; #<%s> represents an entire returned string

printf '<%s is a key>\n' "${!arr[@]}"; # the ! returns the key by default

echo "=====> FOR LOOP FOR GENUINE KEY-VALUE PAIRS =====>";

for key in "${!arr[@]}" ; do
	value=${arr[$key]}
	echo "$key"="$value";
done

unset arr

# [=====> HOLDOVER YAML OBJECT PARSING FROM CAMBERUNNER.SH =====>
	# declare -a meta_values ;
	# yaml_args="$( yq '.configuration.meta.[]' runner.yaml | tr '\n' ', ')" ;
	# meta_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
	# IFS=,; read -ra meta_values <<< "$meta_args" ; unset yaml_args ;
	# declare -a git_values ;
	# yaml_args="$( yq '.configuration.git-args[]' runner.yaml | tr '\n' ', ')" ;
	# git_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
	# IFS=,; read -ra git_values <<< "$git_args" ; unset yaml_args ;
	# declare -a rsync_values ;
	# yaml_args="$( yq '.configuration.rsync-args[]' runner.yaml | tr '\n' ', ')" ;
	# rsync_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
	# IFS=,; read -ra rsync_values <<< "$rsync_args" ; unset yaml_args ;
	# declare -a exclusion_values ;
	# yaml_args="$( yq '.configuration.rsync-args.rsync-exclusions.[]' runner.yaml | tr '\n' ', ' )" ;
	# exclusion_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
	# IFS=,; read -ra exclusion_values <<< "$exclusion_args" ; unset yaml_args ;
	# cyan-echo "=====> TESTING YAML VALUES IFS =====>" ;
	# (IFS=,; echo "${meta_values[*]}"; ) ;
	# (IFS=,; echo "${git_values[*]}"; ) ;
	# (IFS=,; echo "${rsync_values[*]}"; ) ;
	# (IFS=,; echo "${exclusion_values[*]}"; ) ;
	# unset IFS;
# <=====]