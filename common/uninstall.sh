if [ -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db ]; then
  ui_print " "
  ui_print "   Backing up home screens before uninstall.."
  if [ -f /data/media/0/.launcher.db.backup ]; then
    ui_print "   Fround previous backup, backing it up.."
    cp -f /data/media/0/.launcher.db.backup /data/media/0/.launcher.db.backup.2
    cp -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db /data/media/0/.launcher.db.backup
  else
    ui_print "   No previous backup found.."
    cp -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db /data/media/0/.launcher.db.backup
  fi
fi
