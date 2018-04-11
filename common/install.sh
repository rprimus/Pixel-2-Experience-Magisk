# GET RPL/MPL/NPL/GPL FROM ZIP NAME
case $(basename $ZIP) in
  *mpl*|*Mpl*|*MPL*) LAUNCHER=mpl;;
  *rpl*|*Rpl*|*RPL*) LAUNCHER=rpl;;
  *npl*|*Npl*|*NPL*) LAUNCHER=npl;;
  *gpl*|*Gpl*|*GPL*) LAUNCHER=gpl;;
esac

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
chmod 755 $INSTALLER/common/keycheck

keytest() {
  ui_print "- Vol Key Test -"
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
    ui_print "- Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi

  ui_print " "
  ui_print "- Do you want to install Launcher?"
  ui_print "   Vol Up = Install launcher"
  ui_print "   Vol Down = Do NOT install launcher"
  if $FUNCTION; then
    ui_print " "
    ui_print "- Select Launcher -"
    ui_print "   Choose which Pixel Launcher you want installed:"
    ui_print "   Vol Up = Google Stock Launcher, Vol Down = Custom Launcher"
    if $FUNCTION; then 
      ui_print " "
      ui_print "Installing Google stock launcher.."
      LAUNCHER=gpl
    else 
      ui_print " "
      ui_print "- Select Custom Launcher -"
      ui_print "   Choose which Pixel Launcher you want installed:"
      ui_print "   Vol Up = Shubbyy's Ruthless, Vol Down = more options"
      if $FUNCTION; then
        ui_print " "
        ui_print "Installing Shubbyy's Ruthless Launcher.."
        LAUNCHER=rpl
      else
        ui_print " "
        ui_print "- Select More Custom Launcher -"
        ui_print "   Choose which Pixel Launcher you want installed:"
        ui_print "   Vol Up = paphonb's Modded, Vol Down = New Pixel 2 Launcher Mod"
        if $FUNCTION; then
          ui_print " "
          ui_print "Installing Shubbyy's Ruthless Launcher.."
          LAUNCHER=rpl
	else
          ui_print " "
          ui_print "Installing New Pixel 2 Launcher Mod.."
          LAUNCHER=npl
	fi
      fi     
    fi
  else
    ui_print "Not installing launcher.."
    LAUNCHER=none
    # this is stupid way to fix this script
    # using if [ -z $var ] on last cp_ch just breaks this script..?
    # now it just tries to copy nothing..
  fi

else
  ui_print "   Pixel Launcher specified in zipname!"
fi

cp_ch $INSTALLER/custom/$LAUNCHER/PixelLauncher.apk $INSTALLER/system/priv-app/Pixel2Launcher/Pixel2Launcher.apk
