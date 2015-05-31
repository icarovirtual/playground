#!/bin/bash
if [ $# -eq "0" ] || [ $1 == "-h" ]; then
  echo \
"script2path (script to PATH) version 1.0 by iraupph
  include scripts in the system PATH, enabling them to be used from anywhere in the system.
  this creates a symbolic link to your script in a default location ($HOME/bin) and gives the execution permission.
  any modifications you make in the original file are reflected in the linked file.
  moving the original file will probably break everything.

usage: script2path [-h] script
where:
  -h      print this help menu
  script  location of the script that will be moved to the system PATH

complete example:
  script2path /Users/me/scripts/my_bash.sh"
else
  SCRIPTS_LOCATION=$HOME/bin/

  # If it's non existent, create the scripts location
  mkdir -p "$HOME/bin"

  ORIGINAL=$1
  # This splits in the last `/`, AFAIK, I actually forgot to document this
  FILE_NAME="${ORIGINAL##*/}"

  # Tip to my future self that will reuse this:
  # Original path is the actual folder (e.g. /local/project/documents/)
  # Destination path is the parent folder (e.g. /Dropbox/project/)
  sudo ln -s "${ORIGINAL}" "${SCRIPTS_LOCATION}"
  sudo chmod +x "${FILE_NAME}"

  sh $HOME/.bash_profile
fi
