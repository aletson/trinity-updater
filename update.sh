#!/bin/bash
# update.sh
# Author: Andrew Letson
# Purpose: CI for TrinityCore deployment.
# Call this script as follows:
# (Directly/Cron): ./update.sh --maps true|false
# (Jenkins): bash -xa update.sh --maps true|false

# Init variables
while [[ $# -gt 1 ]]; do
	key="$1"
	case $key in
		--maps)
			REBUILD_MAPS="$2"
			shift
			;;
		*)
			echo "Unknown parameter passed in $1. Please review the accepted parameters, currently as follows:"
			echo "--maps"
			exit 1
			;;
	esac
	shift
done

# These are required parameters.
# BUILDDIR should be set to the root directory of the cloned TrinityCore repository.
BUILDDIR="/home/trinity/TrinityCore/"
# SERVERDIR should be set to the root directory where you would like the server to install.
SERVERDIR="/home/trinity/server"
# BACKUPDIR should be set to the directory where you would like to make a backup of the previous server version.
BACKUPDIR="/home/trinity/server_backup"
# WOWDIR should be set to the directory with a WoW client install so that maps may be extracted.
WOWDIR="/home/trinity/WoW335"

# This script can be configured to send alerts to an email address. If you use this, make sure you configure SPF records for your domain to allow your TrinityCore server to send email.
USE_EMAIL="true"
EMAIL_ADDR_TO="my-email@my-domain.com"
SERVER_DOMAIN="my-domain.com"

# This script can be configured to send alerts to an IFTTT Maker web hook.
USE_IFTTT="true"
IFTTT_KEY="my-ifttt-maker-key"

if [[ $USE_IFTTT == "true" ]]; then
curl -X POST https://maker.ifttt.com/trigger/maintenance_alert_start/with/key/${IFTTT_KEY}
fi

# shut down existing server
screen -S world -X stuff 'announce Server is shutting down in 1 minute for scheduled maintenance.'`echo -ne '\015'`
screen -S world -X stuff 'server shutdown 60'`echo -ne '\015'`
sleep 1m
screen -S auth -X quit

#Pull new revision and build it
cd $BUILDDIR || exit 1
git pull
rm -rf $BACKUPDIR
mv $SERVERDIR $BACKUPDIR
cd build || exit 1
if [[ $REBUILD_MAPS == "true" ]]; then
  cmake ../ -DCMAKE_INSTALL_PREFIX=$SERVERDIR -DLIBSDIR=$SERVERDIR/lib -DTOOLS=1
else
	cmake ../ -DCMAKE_INSTALL_PREFIX=$SERVERDIR -DLIBSDIR=$SERVERDIR/lib
fi
make && make install

#Move old configs back in
cp $BACKUPDIR/etc/worldserver.conf $SERVERDIR/etc/worldserver.conf
cp $BACKUPDIR/etc/authserver.conf $SERVERDIR/etc/authserver.conf
cd $SERVERDIR/bin || exit 1
# Move maps in, either build new or use backup
if [[ $REBUILD_MAPS == "true" ]]; then
	\cp mapextractor $WOWDIR
	\cp mmaps_generator $WOWDIR
	\cp vmap4assembler $WOWDIR
	\cp vmap4extractor $WOWDIR
	cd $WOWDIR || exit 1
	rm -rf dbc maps mmaps vmaps Buildings
	./mapextractor
	./vmap4extractor
	mkdir vmaps
	./vmap4assembler Buildings vmaps
	mkdir mmaps
	./mmaps_generator
	mkdir $SERVERDIR/data
	\cp -r dbc maps mmaps vmaps $SERVERDIR/data
	cd $SERVERDIR/bin
else
	\cp -r $BACKUPDIR/data $SERVERDIR
fi

# Start updated server
screen -AdmS world ./worldserver
# Worldserver automatically updates the database, so we can ignore DB updates.
screen -AdmS auth ./authserver


# Notify.

if [[ $USE_EMAIL == "true" ]]; then
  sendmail -F "TrinityCore Update Script" -f "azeroth@$DOMAIN" -t <<EOF
Subject: Server Updated Successfully
To: ${EMAIL_ADDR_TO}

Hello,

The TrinityCore server has been automatically updated. Please check your configuration files for any changes that need to be made.

To debug, you may connect with "screen -r world" and "screen -r auth".

Respectfully,

TrinityCore Update Script
EOF
fi
if [[ $USE_IFTTT == "true" ]]; then
  curl -X POST https://maker.ifttt.com/trigger/maintenance_alert_stop/with/key/${IFTTT_KEY}
fi
exit 0

