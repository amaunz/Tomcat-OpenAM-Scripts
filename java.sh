#!/bin/bash
#
# Sets Java defaults for general java apps
#
export USER="am"
export HOME="/home/$USER"

load_config () 
{
if source $HOME/bin/config.cfg; then
  echo -n ""
else
  echo "Config file not found! Aborting..."
  exit 1
fi
}


# Ensure binaries and all scripts are found (Java 6 Update 12 does not have a bug found in Update 24)
export PATH="$HOME/jdk1.6.0_12:$HOME/bin:/usr/local/bin:$PATH"

# Java specific env variables
export JAVA_HOME="$HOME/jdk1.6.0_12" # find the jdk
