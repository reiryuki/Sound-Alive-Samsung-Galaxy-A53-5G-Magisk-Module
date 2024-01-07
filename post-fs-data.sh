mount -o rw,remount /data
MODPATH=${0%/*}

# log
exec 2>$MODPATH/debug-pfsd.log
set -x

# var
API=`getprop ro.build.version.sdk`
ABI=`getprop ro.product.cpu.abi`

# function
permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if ! setenforce 0; then
    echo 0 > /sys/fs/selinux/enforce
  fi
fi
}
magisk_permissive() {
if [ "$SELINUX" == Enforcing ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
	magiskpolicy --live "permissive *"
  else
	$MODPATH/$ABI/libmagiskpolicy.so --live "permissive *"
  fi
fi
}
sepolicy_sh() {
if [ -f $FILE ]; then
  if [ -x "`command -v magiskpolicy`" ]; then
    magiskpolicy --live --apply $FILE 2>/dev/null
  else
    $MODPATH/$ABI/libmagiskpolicy.so --live --apply $FILE 2>/dev/null
  fi
fi
}

# selinux
SELINUX=`getenforce`
chmod 0755 $MODPATH/*/libmagiskpolicy.so
#1permissive
#2magisk_permissive
#kFILE=$MODPATH/sepolicy.rule
#ksepolicy_sh
FILE=$MODPATH/sepolicy.pfsd
sepolicy_sh

# list
PKGS="`cat $MODPATH/package.txt`
       com.sec.android.app.soundalive:settingui"
for PKG in $PKGS; do
  magisk --denylist rm $PKG 2>/dev/null
  magisk --sulist add $PKG 2>/dev/null
done
if magisk magiskhide sulist; then
  for PKG in $PKGS; do
    magisk magiskhide add $PKG
  done
else
  for PKG in $PKGS; do
    magisk magiskhide rm $PKG
  done
fi

# conflict
DIR=/data/adb/modules/SoundAliveFXRemover
if [ -d $DIR ] && [ ! -f $DIR/disable ]; then
  touch $DIR/disable
fi

# run
. $MODPATH/copy.sh
. $MODPATH/.aml.sh

# directory
DIR=/data/snd
mkdir -p $DIR
chmod 0770 $DIR
chown 1041.1000 $DIR

# directory
DIR=/data/misc/audioserver
mkdir -p $DIR
chmod 0700 $DIR
chown 1041.1041 $DIR

# file
FILE=/vendor/etc/floating_feature.xml
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  MODFILE=$MODPATH$FILE
else
  MODFILE=$MODPATH/system$FILE
fi
NAME=SEC_FLOATING_FEATURE_MMFW_SUPPORT_DOLBY_AUDIO
NAME2=\<$NAME\>FALSE
NAME3=\<$NAME\>TRUE
NAME4=\<SEC_FLOATING_FEATURE_AUDIO_CONFIG_SOUNDALIVE_VERSION\>
rm -f $MODFILE
if [ -f $FILE ]; then
  cp -f $FILE $MODFILE
fi
if [ -f $MODFILE ]; then
  if ! grep $NAME $MODFILE; then
    sed -i '<SecFloatingFeatureSet>/a\
    <SEC_FLOATING_FEATURE_MMFW_SUPPORT_DOLBY_AUDIO>TRUE</SEC_FLOATING_FEATURE_MMFW_SUPPORT_DOLBY_AUDIO>' $MODFILE
  elif grep $NAME2 $MODFILE; then
    sed -i "s|$NAME2|$NAME3|g" $MODFILE
  fi
  if ! grep eq_custom $MODFILE; then
    sed -i "s|$NAME4|$NAME4\eq_custom,|g" $MODFILE
  fi
  if ! grep uhq_onoff $MODFILE; then
    sed -i "s|$NAME4|$NAME4\uhq_onoff,|g" $MODFILE
  fi
  if ! grep karaoke $MODFILE; then
    sed -i "s|$NAME4|$NAME4\karaoke,|g" $MODFILE
  fi
  if ! grep adapt $MODFILE; then
    sed -i "s|$NAME4|$NAME4\adapt,|g" $MODFILE
  fi
  if ! grep spk_stereo $MODFILE; then
    sed -i "s|$NAME4|$NAME4\spk_stereo,|g" $MODFILE
  fi
fi

# permission
if [ -L $MODPATH/system/vendor ]\
&& [ -d $MODPATH/vendor ]; then
  chmod 0751 $MODPATH/vendor/bin
  chmod 0751 $MODPATH/vendor/bin/hw
  FILES=`find $MODPATH/vendor/bin -type f`
  for FILE in $FILES; do
    chmod 0755 $FILE
  done
else
  chmod 0751 $MODPATH/system/vendor/bin
  chmod 0751 $MODPATH/system/vendor/bin/hw
  FILES=`find $MODPATH/system/vendor/bin -type f`
  for FILE in $FILES; do
    chmod 0755 $FILE
  done
fi
if [ "$API" -ge 26 ]; then
  DIRS=`find $MODPATH/vendor\
             $MODPATH/system/vendor -type d`
  for DIR in $DIRS; do
    chown 0.2000 $DIR
  done
  chcon -R u:object_r:system_lib_file:s0 $MODPATH/system/lib*
  chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/odm/etc
  if [ -L $MODPATH/system/vendor ]\
  && [ -d $MODPATH/vendor ]; then
    FILES=`find $MODPATH/vendor/bin -type f`
    for FILE in $FILES; do
      chown 0.2000 $FILE
    done
    chcon -R u:object_r:vendor_file:s0 $MODPATH/vendor
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/etc
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/vendor/odm/etc
    chcon u:object_r:vendor_firmware_file:s0 $MODPATH/vendor/firmware/*
    chcon u:object_r:mediacodec_exec:s0 $MODPATH/vendor/bin/hw/*
  else
    FILES=`find $MODPATH/system/vendor/bin -type f`
    for FILE in $FILES; do
      chown 0.2000 $FILE
    done
    chcon -R u:object_r:vendor_file:s0 $MODPATH/system/vendor
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/etc
    chcon -R u:object_r:vendor_configs_file:s0 $MODPATH/system/vendor/odm/etc
    chcon u:object_r:vendor_firmware_file:s0 $MODPATH/system/vendor/firmware/*
    chcon u:object_r:mediacodec_exec:s0 $MODPATH/system/vendor/bin/hw/*
  fi
fi

# function
mount_helper() {
if [ -d /odm ]\
&& [ "`realpath /odm/etc`" == /odm/etc ]; then
  DIR=$MODPATH/system/odm
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/odm`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
if [ -d /my_product ]; then
  DIR=$MODPATH/system/my_product
  FILES=`find $DIR -type f -name $AUD`
  for FILE in $FILES; do
    DES=/my_product`echo $FILE | sed "s|$DIR||g"`
    umount $DES
    mount -o bind $FILE $DES
  done
fi
}

# mount
if ! grep -E 'delta|Delta|kitsune' /data/adb/magisk/util_functions.sh; then
  mount_helper
fi

# function
mount_bind_file() {
if [ -f $MODFILE ]; then
  for FILE in $FILES; do
    umount $FILE
    mount -o bind $MODFILE $FILE
  done
fi
}
mount_bind_to_apex() {
for NAME in $NAMES; do
  MODFILE=$MODPATH/system/lib64/$NAME
  FILES=`find /apex /system/apex -type f -path *lib64/$NAME`
  mount_bind_file
  MODFILE=$MODPATH/system/lib/$NAME
  FILES=`find /apex /system/apex -type f -path *lib/$NAME`
  mount_bind_file
done
}

# mount
NAMES="libhidlbase.so libbase.so"
mount_bind_to_apex

# cleaning
FILE=$MODPATH/cleaner.sh
if [ -f $FILE ]; then
  . $FILE
  mv -f $FILE $FILE\.txt
fi









