# Camberbash
_A dual git & rsync utility in three files._
_For use when testing pushes and pulls through git and a configured remote ssh server._
1. `runner.yaml`
2. `runner.sh`
3. `.gitignore`

## Features
>Instructions are prompted upon running the following command:
```
bash runner.sh
```
- Toggle git add, commit, push, and **dry run** (for testing)
- Toggle rsync push, pull, and **dry run** (for testing)
- Colorized displays for all notices
- Prompts are available to cancel

## Files

### `runner.yaml`
_Your user data is only needed in this file to run_ `runner.sh`.
> The default setting enables a git add, commit, and push; no rsync:
```
configuration:
  meta:
    site: yourwebsite.com
    latest-commit: your latest commit will be written
  local:
    user: localuser
    dir: /Users/user/local/repository
  remote:
    user: remoteuser
    host: 123.45.678.901
    dir: public_html/yourwebsite
    ssh-port: 1234
  git:
    enabled: true
    dry-run: false
  rsync:
    enabled: false
    dry-run: false
    pull: false
```

### `runner.sh`

_The_ `runner.yaml` _configuration file is read through_ `yq` _in all instances of this executable._
> The below shows leveraged `yq` in reading local user data from `runner.yaml`:
```
local_user="$( yq '.configuration.local.user' runner.yaml)" ;
```

### `.gitignore`

_Specifies which files not to push to remove server through rsync._
> As in `runner.sh` below:
```
rsync -havzun -e "ssh -p $ssh_port" --exclude-from=.gitignore ./* "$remote_path" ;
```