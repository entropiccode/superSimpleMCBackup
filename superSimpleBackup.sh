#!/bin/bash

# Super Simple World Backup Script.
# Written by: _envyUK

# Checks to see if the script is being run as the root user, and exits if you are.
# Running a backup script as the root user can cause permissions issues when restoring
#   from backup, thus should be avoided.
if [ "$EUID" -eq 0 ]; then
    echo "Please run this as a normal user, not as root."
    exit 1
fi

# If the script is run without arguments, it runs normally.
#
# Use the argument "-d" when calling the script to run in dry mode.
# Dry mode will print the commands being run, but will not run the actual backup.
# Good for checking that directories are correct.
#
# Script exits if an argument that is not "-d" is given.
if [ $# -eq 0 ]; then
    dry=0
else
    case $1 in
        "-d")
            dry=1
            ;;
        *)
            echo "Usage: $0 [-d]"
            exit 1
            ;;
    esac
fi

# This sets the server directory and backup directory.
#
# It will use the directory this script is run from as the server directory by default.
# The backup directory is a folder named "backup" in the server directory by default.
#
# Change serverDir to your minecraft server directory if not running from that directory.
# Change backupDir to your desired backup directory if not the default.
serverDir=$PWD
backupDir=$serverDir/backup

# This creates the above described backup directory if it does not exist.
# Set to verbose, so it will print if the directory is created.
if [ ! -d $backupDir ]; then
    mkdir -pv $backupDir
fi

# Saves the name of the world to a variable for later use.
#
# If the script detects the presence of a server.properties folder, it will
#   pull the world name from that file.
#
# If no server.properties folder is found, it will use the defined world name.
#
# Configure the worldName to your world folder if not running the script in your
#   minecraft server directory.
worldName="asdf"
if [ -f "server.properties" ]; then
    worldName=$(grep level-name server.properties | cut -d= -f2)
    echo "Getting world name from server.properties: $worldName"
fi

# Creates a variable with the backup filename, which is the formatted as follows:
# <worldname>_backup-YYYYMMDD-HHMM.tar.gz
# World name is pulled from the "worldName" variable, and the hours and minutes in the name are
#   24 hour format.
filename="${worldName}_backup-"`eval date +%Y%m%d-%H%M`".tar.gz"
worldDir="$serverDir/$worldName/"

# The actual backup process.
#
# If run normally, the script will "move" into the configured backup directory.
# The actual script file is not moved in this process.
#
# Once in the backup directory, it will run the tar process with the following flags:
#   c: Creates a new archive
#   z: Filter the archive through gzip, creating a .tar.gz file
#   f: Creates the file with the given filename variable, configured above.
# This will create a .tar.gz archive containing a copy of your world folder.
#
# The contents of this folder can be viewed (not extracted) with the following command:
# tar -ztvf <archive file>
#   z: Filter the archive through gzip
#   t: List the contents of the archive
#   v: Verbosely list files processed
#   f: Archive file to list contents of
#
# To extract the contents of the tar file, run the following command:
# tar -xf <archive file> -C <extract target directory>
#   x: Extracts the archive
#   f: Archive file to be extracted
#   C: Target directory the files should be extracted to
#
# If run in dry mode, no backup will be made.
# Instead, commands used will be printed to the console.
echo "Backing up world..."
if [ $dry -eq -0 ]; then
    cd "$backupDir"
    tar czf "$filename" "$worldDir"
    echo "Created $filename"
elif [ $dry -eq 1 ]; then
    echo "DRY RUN: cd "$backupDir""
    echo "DRY RUN: tar czf "$filename" "$worldDir""
    echo "DRY RUN: Created $filename"
fi
