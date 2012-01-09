# GLORKSYNC
# Synchronizes a "client" glork folder with a "server" (master) glork folder.
# - Uploads this user's personal glork files to the master repo.
# - Downloads other user's personal glork files, along with glork libs, from the master repo.

# FUNCTIONS
# ---------------------------------
# Functions for checking that files exist.
function file_exist_or_die()
{
if [ -f $1 -o -d $1 ]
then
    echo "	[OK]	$1 found"
else
    echo "	[ERROR]	$1 not found"
    echo
    echo "	Script stopped due to missing files"
    echo
    exit 0;
fi
}
function file_exist_or_move_app()
{
if [ $1 != "$0" ]
then
	echo
	echo "	[ERROR] Please move GlorkSync to the Applications folder."
	echo
	exit 0;
fi
}
function file_exist_or_die_mount_warning ()
{
if [ -f $1 -o -d $1 ]
then
    echo "	[OK]	$1 found"
else
    echo "	[ERROR]	$1 not found"
    echo
    echo "	Make sure you double-clicked on Glork_Shared to connect to the server."
    echo
    exit 0;
fi
}
function dir_exist_or_create()
{
if [ -d $1 ]
then
    echo "	[OK]	$1 found"
else
	mkdir $1
    echo "	[OK]	$1 not found, created"
    echo
fi

}



# Print out Locations
echo
echo "Glork File Sync 1.0"
echo "---------------------"
echo "Configuration:"
echo
echo "Local Glork Folder: $GLORK_LOCAL"
file_exist_or_die $GLORK_LOCAL

echo "Config File: $CONFIG_FILE"
file_exist_or_die $CONFIG_FILE
echo "Your Glork Username: $USERNAME"

echo "Local Copy of Glork Libraries: $LOCAL_LIBS"
dir_exist_or_create $LOCAL_LIBS

echo "Folder For Your Glork Patches: $MY_LOCAL_PATCHES"
dir_exist_or_create $MY_LOCAL_PATCHES

echo "Folder For Group Glork Patches: $GROUP_LOCAL_PATCHES"
dir_exist_or_create $GROUP_LOCAL_PATCHES

echo "Glork Master Folder: $GLORK_MASTER"
file_exist_or_die_mount_warning $GLORK_MASTER

echo "Glork Master Patches Folder: $GLORK_MASTER_PATCHES"
file_exist_or_die $GLORK_MASTER_PATCHES


echo
echo "	All File Paths Located"
echo

# echo "---------------------"
# echo "Creating a Backup of Your Folder:"
# echo
#
# BFILE=$GLORK_LOCAL/backup_`date +%H%M%S`.zip
# tar -cvf $BFILE $MY_LOCAL_PATCHES
# echo "Backup created and stored as $BFILE"
# echo "Use the backup file if this script overwrites any of your work"
# echo


echo "---------------------"
echo "Pulling Changes from Master Folder:"
echo

for i in $GLORK_MASTER_PATCHES/*
do
	if [ -d "$i" ] #if dictionary
	then
		base_name=`basename $i/`
		if [ $base_name = $USERNAME ]
		then
			echo "Skipping copy of $i (since this is your own patches folder)"
		else
			# If the directory does not exist locally, create it before syncing
			if [ ! -d $GROUP_LOCAL_PATCHES/$base_name ]
			then
				echo "Creating directory $GROUP_LOCAL_PATCHES/$base_name"
				mkdir $GROUP_LOCAL_PATCHES/$base_name
			fi
			echo "Copying $i to $GROUP_LOCAL_PATCHES/$base_name"
			rsync -avz --exclude=.git/ --exclude=.DS_Store --delete-after $i/ $GROUP_LOCAL_PATCHES/$base_name
			echo
		fi
	fi
done

echo
echo "	All changes pulled"
echo


echo "---------------------"
echo "Copying Your Changes to the Master Folder:"
echo

if [ ! -d $GLORK_MASTER_PATCHES/$USERNAME ]
then
	echo "Creating your patch folder in the Master Patches Folder"
	mkdir $GLORK_MASTER_PATCHES/$USERNAME
	echo "$GLORK_MASTER_PATCHES/$USERNAME created"
	echo
fi

echo "Synchronizing..."
rsync -avz --exclude=.git/ --exclude=.DS_Store --delete-after $MY_LOCAL_PATCHES/ $GLORK_MASTER_PATCHES/$USERNAME
echo

echo
echo "	All changes pushed"
echo


echo "---------------------"
echo "Copying Shared Libraries to Your Library Folder:"
echo

rsync -avz --exclude=.git/ --exclude=.DS_Store --delete-after $GLORK_MASTER_LIBS/ $GLORK_LOCAL_LIBS
echo

echo
echo "	All libraries updated"
echo