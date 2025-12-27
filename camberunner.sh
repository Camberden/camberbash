#! /bin/bash
timerunner () {
	rt=$(tput sgr0); r=$(tput setaf 1); g=$(tput setaf 2); y=$(tput setaf 3); c=$(tput setaf 6); b=$(tput bold);
	start="$(date +%s)"
	echo "${b}${r}[${rt}${b}${y}$(date +"%m-%d-%Y %H:%M:%S")${b}${r}]${rt} 
	${b}${g}Working from:${rt} ${b}${c}${PWD}${rt} ${b}${y}...${rt}"; 
	echo "${c}Success${rt}, ${b}${g}${USER} with ${BASH_VERSION}${rt}"
	sleep 1; echo "$start"
}
timerunner
closeout () {
	rt=$(tput sgr0); r=$(tput setaf 1); g=$(tput setaf 2); y=$(tput setaf 3); c=$(tput setaf 6); b=$(tput bold);
	echo "${b}${r}[${rt}${b}${y} Closing out${b}${r}]${rt}
	${b}${c} =====> ${rt} ${b}${y}...${rt}"; 
	echo "${b}${r}=====> Ended =====> ${rt}";
}

IFS=,;
declare -a yaml_values;
declare -a yaml_keys;
declare -A yaml_params

echo "=====> resource.shell =====>"

yaml_specs="$( yq '.configuration.meta' runner.yaml | tr ': ' ', ')";
yaml_args="$( yq '.configuration.meta.[]' runner.yaml | tr '\n' ', ')" ;

yaml_specs="$(printf '%s' "${yaml_specs[@]}" | tr '\n' ',  ' )" ;
yaml_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;

echo YAML SPECS: "$yaml_specs" ;
echo YAML ARGS: "$yaml_args" ;

IFS=,; read -ra yaml_keys <<< "$yaml_specs" ; 
IFS=,; read -ra yaml_values <<< "$yaml_args" ; 

echo "=====> TESTING YAML KEYS IFS =====>";
(IFS=,; echo "${yaml_keys[*]}"; unset $IFS) ;
echo "=====> TESTING YAML VALUES IFS =====>" ;
(IFS=,; echo "${yaml_values[*]}"; unset $IFS) ;

echo "=====> TESTING YAML PARAMS LOOP =====>";
for index in "${!yaml_values[@]}" ; do
	echo "${yaml_keys[$index]} =====> a yaml_key at index $index" ;
	echo "${yaml_values[$index]} =====> a yaml_value at index $index" ;
	yyy="${yaml_keys[$index]}" ;
	vvv="${yaml_values[$index]}" ;
	yaml_params[$yyy]=$vvv ;
done

echo "=====> TESTING YAML PARAMS IFS =====>";
(IFS=,; echo "${!yaml_params[*]}"; unset $IFS) ;

closeout
