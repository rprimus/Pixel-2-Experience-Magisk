#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
# More info in the main Magisk thread

# restoring database

if [ -f /data/media/0/.launcher.restore ]; then
  if [ -f /data/media/0/.launcher.db.backup ] && [ -d /data/data/com.google.android.apps.nexuslauncher/databases ]; then 
    cp -f /data/media/0/.launcher.db.backup /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db
  fi
  rm -f /data/media/0/.launcher.restore
  killall com.google.android.apps.nexuslauncher
fi
