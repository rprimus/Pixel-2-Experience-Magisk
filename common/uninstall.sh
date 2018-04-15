if [ -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db ]; then
  ui_print " "
  ui_print "   Backing up home screens before uninstall.."
  cp -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db /data/media/0/.launcher.db.backup
fi
