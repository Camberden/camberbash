#! /bin/bash

echo "=====> TESTA.SH =====>"
current_directory=$(pwd)
echo "=====> Current Directory: $current_directory" ;
name=$(yq '.name' file.yaml)
echo "=====> Hello, $name. Change Name?"
echo "[Press y for yes, n for no, other to cancel] =====>"
read -r resp
if [ "$resp" == "n" ]; then
echo "=====> Ending..." ; exit 1;
elif [ "$resp" == "y" ] && [ "$name" == "Fido" ]; then
yq -i '.name = "Woofer"' file.yaml
elif [ "$resp" == "y" ] && [ "$name" == "Woofer" ]; then
yq -i '.name = "Fido"' file.yaml
else
echo "=====> Ending..." ; exit 1;
fi
name=$(yq '.name' file.yaml)
echo "=====> BEGIN YAML =====>"
yq 'to_entries' file.yaml
echo "=====> END YAML =====>"

declare -p dd_args
dd_args=()
dd_args=('echo' 'dying and dumping like PHP')

"${dd_args[@]}"

echo "=====> Ending..." ; exit 1;
