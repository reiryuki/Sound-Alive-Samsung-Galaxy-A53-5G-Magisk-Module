MODPATH=${0%/*}
API=`getprop ro.build.version.sdk`
AML=/data/adb/modules/aml

# debug
exec 2>$MODPATH/debug.log
set -x

# property
resetprop ro.samsung.board exynos2100
resetprop ro.samsung.model SM-G996B
resetprop ro.samsung.name t2sxxx
resetprop ro.build.version.oneui 40000

# restart
if [ "$API" -ge 24 ]; then
  SVC=audioserver
else
  SVC=mediaserver
fi
PID=`pidof $SVC`
if [ "$PID" ]; then
  killall $SVC
fi

# restart
VIBRATOR=`realpath /*/bin/hw/vendor.qti.hardware.vibrator.service*`
[ "$VIBRATOR" ] && killall $VIBRATOR
POWER=`realpath /*/bin/hw/vendor.mediatek.hardware.mtkpower@*-service`
[ "$POWER" ] && killall $POWER
killall android.hardware.usb@1.0-service
killall android.hardware.usb@1.0-service.basic
killall android.hardware.sensors@1.0-service
killall android.hardware.sensors@2.0-service-mediatek
killall android.hardware.light-service.mt6768
killall android.hardware.lights-service.xiaomi_mithorium
CAMERA=`realpath /*/bin/hw/android.hardware.camera.provider@*-service_64`
[ "$CAMERA" ] && killall $CAMERA

# wait
sleep 20

# aml fix
DIR=$AML/system/vendor/odm/etc
if [ "$API" -ge 26 ]\
&& [ -d $DIR ] && [ ! -f $AML/disable ]; then
  chcon -R u:object_r:vendor_configs_file:s0 $DIR
fi

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`realpath /dev/*/.magisk`
fi

# path
MIRROR=$MAGISKTMP/mirror
SYSTEM=`realpath $MIRROR/system`
VENDOR=`realpath $MIRROR/vendor`
ODM=`realpath $MIRROR/odm`
MY_PRODUCT=`realpath $MIRROR/my_product`

# mount
NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
if [ -d $AML ] && [ ! -f $AML/disable ]\
&& find $AML/system/vendor -type f -name $NAME; then
  NAME="*audio*effects*.conf -o -name *audio*effects*.xml"
#p  NAME="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
  DIR=$AML/system/vendor
else
  DIR=$MODPATH/system/vendor
fi
FILE=`find $DIR/etc -maxdepth 1 -type f -name $NAME`
if [ ! -d $ODM ] && [ "`realpath /odm/etc`" == /odm/etc ]\
&& [ "$FILE" ]; then
  for i in $FILE; do
    j="/odm$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi
if [ ! -d $MY_PRODUCT ] && [ -d /my_product/etc ]\
&& [ "$FILE" ]; then
  for i in $FILE; do
    j="/my_product$(echo $i | sed "s|$DIR||")"
    if [ -f $j ]; then
      umount $j
      mount -o bind $i $j
    fi
  done
fi

# wait
sleep 40

# settings
#DES=secure
#NAME=display_density_forced
#SET=`settings get $DES $NAME`
#VAL=`getprop ro.sf.lcd_density`
#settings put $DES $NAME $VAL

# function
grant_permission() {
UID=`pm list packages -U | grep $PKG | sed -n -e "s/package:$PKG uid://p"`
pm grant $PKG android.permission.READ_EXTERNAL_STORAGE
appops set $PKG READ_EXTERNAL_STORAGE allow
pm grant $PKG android.permission.WRITE_EXTERNAL_STORAGE
appops set $PKG WRITE_EXTERNAL_STORAGE allow
pm grant $PKG android.permission.ACCESS_MEDIA_LOCATION 2>/dev/null
appops set $PKG ACCESS_MEDIA_LOCATION allow
appops set --uid $UID ACCESS_MEDIA_LOCATION allow
appops set $PKG WRITE_SETTINGS allow
if [ "$API" -ge 33 ]; then
  pm grant $PKG android.permission.READ_MEDIA_AUDIO
  pm grant $PKG android.permission.READ_MEDIA_VIDEO
  pm grant $PKG android.permission.READ_MEDIA_IMAGES
  pm grant $PKG android.permission.POST_NOTIFICATIONS
fi
appops set --uid $UID LEGACY_STORAGE allow
appops set $PKG LEGACY_STORAGE allow
appops set $PKG READ_MEDIA_AUDIO allow
appops set $PKG READ_MEDIA_VIDEO allow
appops set $PKG READ_MEDIA_IMAGES allow
appops set $PKG WRITE_MEDIA_AUDIO allow
appops set $PKG WRITE_MEDIA_VIDEO allow
appops set $PKG WRITE_MEDIA_IMAGES allow
if [ "$API" -ge 30 ]; then
  appops set $PKG MANAGE_EXTERNAL_STORAGE allow
  appops set $PKG NO_ISOLATED_STORAGE allow
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi
if [ "$API" -ge 31 ]; then
  appops set $PKG MANAGE_MEDIA allow
fi
}

# grant
PKG=com.sec.hearingadjust
pm grant $PKG android.permission.READ_PHONE_STATE
appops set $PKG WRITE_SETTINGS allow
if [ "$API" -ge 33 ]; then
  pm grant $PKG android.permission.POST_NOTIFICATIONS
fi
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# grant
PKG=com.samsung.android.soundassistant
grant_permission
pm grant $PKG android.permission.RECORD_AUDIO
if [ "$API" -ge 31 ]; then
  pm grant $PKG android.permission.BLUETOOTH_CONNECT
fi

# grant
PKG=com.samsung.android.setting.multisound
appops set $PKG WRITE_SETTINGS allow
if [ "$API" -ge 31 ]; then
  pm grant $PKG android.permission.BLUETOOTH_CONNECT
fi
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# grant
PKG=com.sec.android.app.soundalive
appops set $PKG WRITE_SETTINGS allow
if [ "$API" -ge 31 ]; then
  pm grant $PKG android.permission.BLUETOOTH_CONNECT
fi
if [ "$API" -ge 33 ]; then
  pm grant $PKG android.permission.POST_NOTIFICATIONS
  appops set $PKG ACCESS_RESTRICTED_SETTINGS allow
fi
if [ "$API" -ge 30 ]; then
  appops set $PKG AUTO_REVOKE_PERMISSIONS_IF_UNUSED ignore
fi

# grant
PKG=com.reiryuki.soundalivehelper
if pm list packages | grep $PKG; then
  grant_permission
  appops set $PKG GET_USAGE_STATS allow
  appops set $PKG ACCESS_RESTRICTED_SETTINGS allow
  appops set $PKG SYSTEM_ALERT_WINDOW allow
  dumpsys deviceidle whitelist +$PKG
fi

# function
wait_audioserver() {
PID=`pidof $SVC`
sleep 180
NEXTPID=`pidof $SVC`
}

# wait
if [ "$API" -ge 24 ]; then
  SVC=audioserver
else
  SVC=mediaserver
fi
if [ "`getprop init.svc.$SVC`" == running ]; then
  until [ "$PID" ] && [ "$NEXTPID" ]\
  && [ "$PID" == "$NEXTPID" ]; do
    wait_audioserver
  done
else
  start $SVC
fi

# restart
killall com.sec.android.app.soundalive













