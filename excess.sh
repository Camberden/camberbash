#! /bin/bash

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