#! /bin/bash
timerunner () {
	rt=$(tput sgr0); r=$(tput setaf 1); g=$(tput setaf 2); y=$(tput setaf 3); c=$(tput setaf 6); b=$(tput bold); start="$(date +%s)" ;
	echo "${b}${r}[${rt}${b}${y}$(date +"%m-%d-%Y %H:%M:%S")${b}${r}]${rt}" ;
	echo "${g}Working from${rt} ${b}${c}${PWD}${rt}" ; 
	echo "${c}as${rt} ${b}${g}${USER} with Bash Version ${BASH_VERSION}${rt}" "${b}${y}...${rt}" ;
	sleep 1 ;  
	echo "$start" ;
}

cyan-echo () {
	tput setaf 6 ; echo "$1" ; tput sgr0 ;
}
yellow-echo () {
	tput setaf 3 ; echo "$1" ; tput sgr0 ;
}
green-echo () {
	tput setaf 2 ; echo "$1" ; tput sgr0 ;
}
pink-echo () {
	tput setaf 5 ; echo "$1" ; tput sgr0 
}

closeout () {
	rt=$(tput sgr0) ; 
	r=$(tput setaf 1); 
	g=$(tput setaf 2); 
	y=$(tput setaf 3); 
	c=$(tput setaf 6); 
	b=$(tput bold) ;
	echo "${b}${r}[${rt}${b}${y}Closing out${b}${r}]${rt}${b}${c}=====> ${rt}" ; 
	echo "${b}${r}[====> Ended =====> ${rt} ${b}${y}...${rt}" ;
	unset IFS ;
	if $1 ; then
	exit 0;
fi

}

IFS=,;
local_user=$USER \
yq -i '.configuration.meta.local-user = env(local_user)' runner.yaml ; 
local_dir=$(pwd)/ \
yq -i '.configuration.meta.local-dir = env(local_dir)' runner.yaml ;

local_user="$( yq '.configuration.meta.local-user' runner.yaml)" ;
local_dir="$( yq '.configuration.meta.local-dir' runner.yaml)" ;
remote_user="$( yq '.configuration.meta.remote-user' runner.yaml)" ;
remote_host="$( yq '.configuration.meta.remote-host' runner.yaml)"
remote_dir="$( yq '.configuration.meta.remote-dir' runner.yaml)"
dry_run="$( yq '.configuration.meta.dry-run' runner.yaml)" ;
remote_path="$remote_user$remote_host:$remote_dir" ;

declare -a meta_values ;
yaml_args="$( yq '.configuration.meta.[]' runner.yaml | tr '\n' ', ')" ;
meta_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra meta_values <<< "$meta_args" ; unset yaml_args ;
declare -a git_values ;
yaml_args="$( yq '.configuration.git-args[]' runner.yaml | tr '\n' ', ')" ;
git_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra git_values <<< "$git_args" ; unset yaml_args ;
declare -a rsync_values ;
yaml_args="$( yq '.configuration.rsync-args[]' runner.yaml | tr '\n' ', ')" ;
rsync_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra rsync_values <<< "$rsync_args" ; unset yaml_args ;
declare -a exclusion_values ;
yaml_args="$( yq '.configuration.rsync-args.rsync-exclusions.[]' runner.yaml | tr '\n' ', ' )" ;
exclusion_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra exclusion_values <<< "$exclusion_args" ; unset yaml_args ;

# cyan-echo "=====> TESTING YAML VALUES IFS =====>" ;
# (IFS=,; echo "${meta_values[*]}"; unset $IFS) ;
# (IFS=,; echo "${git_values[*]}"; unset $IFS) ;
# (IFS=,; echo "${rsync_values[*]}"; unset $IFS) ;
# (IFS=,; echo "${exclusion_values[*]}"; unset $IFS) ;

git_add () {
	if $1 ; then
		cyan-echo "=====> [DRY RUN (SAFE MODE) ENABLED] =====>" ;
		git status ;
		git add . --dry-run ;
	else
		yellow-echo "=====> [WET RUN (OVERWRITE MODE) ENABLED] =====>" ;
		git status ;
		git add . ;
	fi
}

git_commit () {
	if $1 ; then
		git commit -m "$2" --dry-run ;
	else
		git commit -m "$2" ;
	fi
}

rsync_push () {

	if $1 ; then
		
		cyan-echo "=====> DRY GIT PUSHED THE FOLLOWING: =====>" ;
		git push --dry-run ;
		cyan-echo "=====> DRY RSYNCED TO SERVER: =====>" #-havzun
		rsync -havzune 'ssh -p 6543' --exclude={'*.yaml','*.git','*.sh','*.gitignore','.DS_Store'} ./* "$remote_path" ;
		# rsync -chavznP -e "ssh -p 6543" camberde@130.51.180.241:ncco.us/ /Users/chrispy/Documents/ncco/ncco.us/
		cyan-echo "=====> DRY COMMIT, PUSH, & RSYNC COMPLETE =====>/" ;
		closeout ;
	else
		cyan-echo "=====> GIT PUSHED THE FOLLOWING: =====> "
		git push ;
		cyan-echo "=====> DRY RSYNCED TO SERVER: =====>" #-havzun
		rsync -havzun 'ssh -p 6543' --exclude={'*.yaml','*.git','*.sh','*.gitignore','.DS_Store'} ./* "$remote_path" ;
		yellow-echo "=====> COMMIT, PUSH, & RSYNC COMPLETE =====>" ;
		closeout ;
	fi
}

yellow-echo "SOURCE DIRECTORY =====> $local_dir" ;
yellow-echo "TARGET DIRECTORY =====> $remote_path" ;
for X in bash git yq
do
	echo -n "$X =====> "; which $X ;
done

git_add "$dry_run" ;
cyan-echo "=====> Enter your commit message, " "$local_user." ;
cyan-echo "[Cancels under 3 characters.] =====>" ;

if [ "$dry_run" ]; then
pink-echo "[Press w to enable wet run (overwrite mode)] =====>" ;
else 
pink-echo "[Press d to enable dry run (safe mode)] =====>" ;
fi
printf '%s' "..."; read -r message ;

message="$(printf '%s' "$message")" ;

if [ "$dry_run" ] && [ "$message" == "w" ] ; then
	yellow-echo "=====> [WET RUN (OVERWRITE MODE) ENABLED] =====>" ;
	git reset ;
	pink-echo "=====> Rerun enabled utility. Exiting..." ;
	yq -i .configuration.meta.dry-run=false runner.yaml ;
	closeout true ;
fi

if [ "$dry_run" == false ] && [ "$message" == "d" ] ; then
	green-echo "=====> [DRY RUN (SAFE MODE) ENABLED] =====>";
	git reset ;
	pink-echo "=====> Rerun utility for safe testing. Exiting..." ;
	yq -i .configuration.meta.dry-run=true runner.yaml ;
	closeout true ;
fi 

if [ ${#message} -gt 2 ] ; then
	green-echo "[SUCCESS] =====>"
	commit=$message \
	yq -i '.configuration.meta.latest-commit = env(commit)' runner.yaml ;

git_commit "$dry_run" "$message" ;

else
	git reset ;
	echo "=====> Too few characters (# < 3) Exiting..."
	echo "=====> Commit cancelled..." ; closeout true;
fi

cyan-echo "=====> Push data?"
cyan-echo "[Press p to confirm] =====>"
read -r pushed

if [ "$pushed" == "p" ] ; then
echo "Data pushing: " ; pink-echo "$message" ;
rsync_push "$dry_run" ;
else
git reset ;
cyan-echo "=====> Push cancelled..." ; closeout ;
fi
#! /bin/bash
timerunner () {
	rt=$(tput sgr0); r=$(tput setaf 1); g=$(tput setaf 2); y=$(tput setaf 3); c=$(tput setaf 6); b=$(tput bold);
	start="$(date +%s)"
	echo "${b}${r}[${rt}${b}${y}$(date +"%m-%d-%Y %H:%M:%S")${b}${r}]${rt}" ;
	echo "${g}Working from${rt} ${b}${c}${PWD}${rt}" ; 
	echo "${c}as${rt} ${b}${g}${USER} with Bash Version ${BASH_VERSION}${rt}" "${b}${y}...${rt}";
	sleep 1; 
	echo "$start" ;
}
timerunner
cyan-echo () {
	tput setaf 6 ; echo "$1" ; tput sgr0 ;
}
yellow-echo () {
	tput setaf 3 ; echo "$1" ; tput sgr0 ;
}
green-echo () {
	tput setaf 2 ; echo "$1" ; tput sgr0 ;
}
pink-echo () {
	tput setaf 5 ; echo "$1" ; tput sgr0 
}
closeout () {
	rt=$(tput sgr0) ; 
	r=$(tput setaf 1); 
	g=$(tput setaf 2); 
	y=$(tput setaf 3); 
	c=$(tput setaf 6); 
	b=$(tput bold) ;
	echo "${b}${r}[${rt}${b}${y}Closing out${b}${r}]${rt}${b}${c}=====> ${rt}" ; 
	echo "${b}${r}[====> Ended =====> ${rt} ${b}${y}...${rt}" ;
	unset IFS ;

	if $1 ; then
	exit 0;
	fi
}

IFS=,;
local_user=$USER \
yq -i '.configuration.meta.local-user = env(local_user)' runner.yaml ; 
local_dir=$(pwd)/ \
yq -i '.configuration.meta.local-dir = env(local_dir)' runner.yaml ;

local_user="$( yq '.configuration.meta.local-user' runner.yaml)" ;
local_dir="$( yq '.configuration.meta.local-dir' runner.yaml)" ;
remote_user="$( yq '.configuration.meta.remote-user' runner.yaml)" ;
remote_host="$( yq '.configuration.meta.remote-host' runner.yaml)"
remote_dir="$( yq '.configuration.meta.remote-dir' runner.yaml)"
dry_run="$( yq '.configuration.meta.dry-run' runner.yaml)" ;
remote_path="$remote_user$remote_host:$remote_dir" ;

declare -a meta_values ;
yaml_args="$( yq '.configuration.meta.[]' runner.yaml | tr '\n' ', ')" ;
meta_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra meta_values <<< "$meta_args" ; unset yaml_args ;
declare -a git_values ;
yaml_args="$( yq '.configuration.git-args[]' runner.yaml | tr '\n' ', ')" ;
git_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra git_values <<< "$git_args" ; unset yaml_args ;
declare -a rsync_values ;
yaml_args="$( yq '.configuration.rsync-args[]' runner.yaml | tr '\n' ', ')" ;
rsync_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra rsync_values <<< "$rsync_args" ; unset yaml_args ;
declare -a exclusion_values ;
yaml_args="$( yq '.configuration.rsync-args.rsync-exclusions.[]' runner.yaml | tr '\n' ', ' )" ;
exclusion_args="$(printf '%s,' "${yaml_args[@]}" | tr '\n' ', ' )" ;
IFS=,; read -ra exclusion_values <<< "$exclusion_args" ; unset yaml_args ;

cyan-echo "=====> TESTING YAML VALUES IFS =====>" ;
(IFS=,; echo "${meta_values[*]}"; unset $IFS) ;
(IFS=,; echo "${git_values[*]}"; unset $IFS) ;
(IFS=,; echo "${rsync_values[*]}"; unset $IFS) ;
(IFS=,; echo "${exclusion_values[*]}"; unset $IFS) ;

git_add () {
	if $1 ; then
		cyan-echo "=====> [DRY RUN (SAFE MODE) ENABLED] =====>" ;
		git status ;
		git add . --dry-run ;
	else
		yellow-echo "=====> [WET RUN (OVERWRITE MODE) ENABLED] =====>" ;
		git status ;
		git add . ;
	fi
}

git_commit () {
	if $1 ; then
		git commit -m "$2" --dry-run ;
	else
		git commit -m "$2" ;
	fi
}

rsync_push () {

	if $1 ; then
		
		cyan-echo "=====> DRY GIT PUSHED THE FOLLOWING: =====>" ;
		git push --dry-run ;
		cyan-echo "=====> DRY RSYNCED TO SERVER: =====>" #-havzun
		rsync -havzune 'ssh -p 6543' --exclude={'*.yaml','*.git','*.sh','*.gitignore','.DS_Store'} ./* "$remote_path" ;
		# rsync -chavznP -e "ssh -p 6543" camberde@130.51.180.241:ncco.us/ /Users/chrispy/Documents/ncco/ncco.us/
		cyan-echo "=====> DRY COMMIT, PUSH, & RSYNC COMPLETE =====>/" ;
		closeout ;
	else
		cyan-echo "=====> GIT PUSHED THE FOLLOWING: =====> "
		git push ;
		cyan-echo "=====> DRY RSYNCED TO SERVER: =====>" #-havzun
		rsync -havzun 'ssh -p 6543' --exclude={'*.yaml','*.git','*.sh','*.gitignore','.DS_Store'} ./* "$remote_path" ;
		yellow-echo "=====> COMMIT, PUSH, & RSYNC COMPLETE =====>" ;
		closeout ;
	fi
}

yellow-echo "SOURCE DIRECTORY =====> $local_dir" ;
yellow-echo "TARGET DIRECTORY =====> $remote_path" ;
for X in bash git yq
do
	echo -n "$X =====> "; which $X ;
done

git_add "$dry_run" ;
cyan-echo "=====> Enter your commit message, " "$local_user." ;
cyan-echo "[Cancels under 3 characters.] =====>" ;

if "$dry_run" ; then
pink-echo "[Press w to enable wet run (overwrite mode)] =====>" ;
else 
pink-echo "[Press d to enable dry run (safe mode)] =====>" ;
fi
printf '%s' "..."; read -r message ;

message="$(printf '%s' "$message")" ;

if [ "$dry_run" ] && [ "$message" == "w" ] ; then
	yellow-echo "=====> [WET RUN (OVERWRITE MODE) ENABLED] =====>";
	git reset ;
	pink-echo "=====> Rerun enabled utility. Exiting..." ;
	yq -i .configuration.meta.dry-run=false runner.yaml
	closeout true ;
fi

if [ "$dry_run" == false ] && [ "$message" == "d" ] ; then
	green-echo "=====> [DRY RUN (SAFE MODE) ENABLED] =====>";
	git reset ;
	pink-echo "=====> Rerun utility for safe testing. Exiting..." ;
	yq -i .configuration.meta.dry-run=true runner.yaml
	closeout true ;
fi 

if [ ${#message} -gt 2 ] ; then
	echo "[SUCCESS] =====>"
	commit=$message \
	yq -i '.configuration.meta.latest-commit = env(commit)' runner.yaml ;

git_commit "$dry_run" "$message" ;

else
	git reset ;
	echo "=====> Too few characters (# < 3) Exiting..."
	echo "=====> Commit cancelled..." ; closeout true;
fi

cyan-echo "=====> Push data?"
cyan-echo "[Press p to confirm] =====>"
read -r pushed

if [ "$pushed" == "p" ] ; then
echo "Data pushing: " ; pink-echo "$message" ;
rsync_push "$dry_run" ;
else
git reset ;
cyan-echo "=====> Push cancelled..." ; closeout ;
fi
