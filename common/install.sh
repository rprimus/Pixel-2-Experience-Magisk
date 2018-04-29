# GET APL/CPL/MPL/RPL FROM ZIP NAME
case $(basename $ZIP) in
  *apl*|*Apl*|*APL*) LAUNCHER=apl;;
  *cpl*|*Cpl*|*CPL*) LAUNCHER=cpl;;
  *mpl*|*Mpl*|*MPL*) LAUNCHER=mpl;;
  *rpl*|*Rpl*|*RPL*) LAUNCHER=rpl;;
esac

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
chmod 755 $INSTALLER/common/keycheck

# remove /data/resource-cache/overlays.list
OVERLAY='/data/resource-cache/overlays.list'
ui_print "   Removing $OVERLAY"
if [ -f "$OVERLAY" ] ;then
  rm -f "$OVERLAY"
fi

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press Vol Up:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $INSTALLER/common/keycheck
  $INSTALLER/common/keycheck
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

ui_print " "
if [ -z $LAUNCHER ]; then
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "   ! Legacy device detected! Using old keycheck method"
    ui_print " "
    ui_print " - Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi
  ui_print " "
  ui_print "- Do you want to install a Launcher?"
  ui_print "   Vol+ = Install Launcher"
  ui_print "   Vol- = Do NOT install a Launcher"
  if $FUNCTION; then
    ui_print " "
    ui_print " - Select Launcher -"
    ui_print "   Choose which Pixel Launcher you want installed:"
    ui_print "   Vol+ = Stock, Vol- = Custom Launcher choices"
    if $FUNCTION; then
      ui_print " "
      ui_print "   Installing paphonb's Modded Pixel 2 Launcher..."
      LAUNCHER=mpl
    else
      ui_print " "
      ui_print " - Select Custom Launcher -"
      ui_print "   Choose which custom Pixel Launcher you want installed:"
      ui_print "   Vol+ = Shubbyy's Ruthless Pixel Launcher, Vol- = More options"
      if $FUNCTION; then
        ui_print " "
        ui_print "   Installing Shubbyy's Ruthless Pixel Launcher..."
        LAUNCHER=rpl
      else
        ui_print " "
        ui_print " - Select Custom Launcher -"
        ui_print "   Choose which custom Pixel Launcher you want installed:"
        ui_print "   Vol+ = Amir's Rootless Pixel 2 Launcher, Vol- = Customized Pixel Launcher"
        if $FUNCTION; then
          ui_print " "
          ui_print "   Installing Amir's Rootless Pixel 2 Launcher..."
          LAUNCHER=apl
        else
          ui_print " "
          ui_print "   Installing Customized Pixel Launcher..."
          LAUNCHER=cpl
        fi
      fi
    fi
  else
    ui_print "   Skip installing launchers..."
  fi
else
  ui_print "   Pixel Launcher specified in zipname!"
fi

if [ ! -z $LAUNCHER ]; then
  mkdir -p $INSTALLER/system/priv-app/NexusLauncherPrebuilt
  cp -f $INSTALLER/custom/$LAUNCHER/PixelLauncher.apk $INSTALLER/system/priv-app/NexusLauncherPrebuilt/NexusLauncherPrebuilt.apk
fi

# backup
if [ -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db ]; then
  ui_print " "
  ui_print " - Select Backup -"
  ui_print "   Found previous home screens, do you want to backup?"
  ui_print "   Vol+ = Create backup, Vol- = Do NOT create backup"
  if $FUNCTION; then
    ui_print " "
    ui_print "   Backing up home screens.."
    cp -f /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db /data/media/0/.launcher.db.backup
    NORESTORE=1
  else
    ui_print " "
    ui_print "   Did not backup!"
  fi
fi

# restore
if [ -f /data/media/0/.launcher.db.backup ] && [ -z $NORESTORE ]; then
  ui_print " "
  ui_print " - Select Restore -"
  ui_print "   Found backup of home screens, do you want to restore?"
  ui_print "   Vol+ = Restore backup, Vol- = Do NOT restore"
  if $FUNCTION; then
    ui_print " "
    ui_print "   Restoring home screens.."
    if [ ! -d /data/data/com.google.android.apps.nexuslauncher/databases ]; then
      touch /data/media/0/.launcher.restore
    else
      cp -f /data/media/0/.launcher.db.backup /data/data/com.google.android.apps.nexuslauncher/databases/launcher.db
    fi
  else
    ui_print " "
    ui_print "   Did not restore!"
  fi
fi

