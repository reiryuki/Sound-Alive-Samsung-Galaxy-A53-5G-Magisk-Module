# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0
FIRARCH=`grep_get_prop ro.bionic.arch`
SECARCH=`grep_get_prop ro.bionic.2nd_arch`
ABILIST=`grep_get_prop ro.product.cpu.abilist`
if [ ! "$ABILIST" ]; then
  ABILIST=`grep_get_prop ro.system.product.cpu.abilist`
fi
if [ "$FIRARCH" == arm64 ]\
&& ! echo "$ABILIST" | grep -q arm64-v8a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,arm64-v8a"
  else
    ABILIST=arm64-v8a
  fi
fi
if [ "$FIRARCH" == x64 ]\
&& ! echo "$ABILIST" | grep -q x86_64; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86_64"
  else
    ABILIST=x86_64
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi"
  else
    ABILIST=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi-v7a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi-v7a"
  else
    ABILIST=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST" | grep -q x86; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86"
  else
    ABILIST=x86
  fi
fi
ABILIST32=`grep_get_prop ro.product.cpu.abilist32`
if [ ! "$ABILIST32" ]; then
  ABILIST32=`grep_get_prop ro.system.product.cpu.abilist32`
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi"
  else
    ABILIST32=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi-v7a; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi-v7a"
  else
    ABILIST32=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST32" | grep -q x86; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,x86"
  else
    ABILIST32=x86
  fi
fi
if [ ! "$ABILIST32" ]; then
  [ -f /system/lib/libandroid.so ] && ABILIST32=true
fi

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# architecture
if [ "$ABILIST" ]; then
  ui_print "- $ABILIST architecture"
  ui_print " "
fi
NAME=arm64-v8a
NAME2=armeabi-v7a
if ! echo "$ABILIST" | grep -q $NAME; then
  if echo "$ABILIST" | grep -q $NAME2; then
    rm -rf `find $MODPATH/system -type d -name *64*`
  else
    if [ "$BOOTMODE" == true ]; then
      ui_print "! This ROM doesn't support $NAME nor $NAME2 architecture"
    else
      ui_print "! This Recovery doesn't support $NAME nor $NAME2 architecture"
      ui_print "  Try to install via Magisk app instead"
    fi
    abort
  fi
fi
if ! echo "$ABILIST" | grep -q $NAME2; then
  rm -rf $MODPATH/system*/lib\
   $MODPATH/system*/vendor/lib
  if [ "$BOOTMODE" != true ]; then
    ui_print "! This Recovery doesn't support $NAME2 architecture"
    ui_print "  Try to install via Magisk app instead"
    ui_print " "
  fi
fi

# sdk
NUM=21
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API. You have to upgrade your"
  ui_print "  Android version at least SDK $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# one ui core
if [ ! -d /data/adb/modules/OneUICore ]; then
  ui_print "- This module requires One UI Core Magisk Module installed"
  ui_print "  except you are in One UI/TouchWiz ROM."
  ui_print "  Please read the installation guide!"
  ui_print " "
else
  rm -f /data/adb/modules/OneUICore/remove
  rm -f /data/adb/modules/OneUICore/disable
fi

# recovery
mount_partitions_in_recovery

# magisk
magisk_setup

# path
SYSTEM=`realpath $MIRROR/system`
VENDOR=`realpath $MIRROR/vendor`
PRODUCT=`realpath $MIRROR/product`
SYSTEM_EXT=`realpath $MIRROR/system_ext`
ODM=`realpath $MIRROR/odm`
MY_PRODUCT=`realpath $MIRROR/my_product`

# check
if [ "`grep_prop dolby.mod $OPTIONALS`" == 0 ]; then
  ui_print "- Checking in-built Dolby apps..."
  FILE=`find /system/app /system/priv-app /product/app\
        /product/priv-app /product/preinstall /system_ext/app\
        /system_ext/priv-app /vendor/app /vendor/euclid/product/app\
        -type f -name XiaomyDolby.apk -o -name DolbyManager.apk`
  if [ "$FILE" ]; then
    ui_print "  Detected"
    ui_print "$FILE"
    ui_print "  You need to remove dolby.mod=0 to use the Dolby Atmos,"
    ui_print "  otherwise the Dolby Atmos will not work."
  fi
  ui_print " "
fi

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# .aml.sh
mv -f $MODPATH/aml.sh $MODPATH/.aml.sh

# mod ui
if [ "`grep_prop mod.ui $OPTIONALS`" == 1 ]; then
  APP=SoundAlive_T
  FILE=/data/media/"$UID"/$APP.apk
  DIR=`find $MODPATH/system -type d -name $APP`
  ui_print "- Using modified UI apk..."
  if [ -f $FILE ]; then
    cp -f $FILE $DIR
    chmod 0644 $DIR/$APP.apk
    ui_print "  Applied"
  else
    ui_print "  ! There is no $FILE file."
    ui_print "    Please place the apk to your internal storage first"
    ui_print "    and reflash!"
  fi
  ui_print " "
fi

# cleaning
ui_print "- Cleaning..."
PKGS=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    FILE=`find /data/app -name *$PKG*`
    if [ "$FILE" ]; then
      RES=`pm uninstall $PKG 2>/dev/null`
    fi
  done
fi
rm -rf $MODPATH/unused
remove_sepolicy_rule
ui_print " "

# function
conflict() {
for NAME in $NAMES; do
  DIR=/data/adb/modules_update/$NAME
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAME
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAME/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAME\
   /mnt/vendor/persist/magisk/$NAME\
   /persist/magisk/$NAME\
   /data/unencrypted/magisk/$NAME\
   /cache/magisk/$NAME\
   /cust/magisk/$NAME
done
}
conflict_disable() {
for NAME in $NAMES; do
  DIR=/data/adb/modules_update/$NAME
  touch $DIR/disable
  DIR=/data/adb/modules/$NAME
  touch $DIR/disable
done
}

# conflict
NAMES=SoundAliveFXRemover
conflict_disable

# function
cleanup() {
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
DIR=/data/adb/modules_update/$MODID
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
}

# cleanup
DIR=/data/adb/modules/$MODID
FILE=$DIR/module.prop
PREVMODNAME=`grep_prop name $FILE`
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's|^data.cleanup=1|data.cleanup=0|g' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
elif [ -d $DIR ]\
&& [ "$PREVMODNAME" != "$MODNAME" ]; then
  ui_print "- Different module name is detected"
  ui_print "  Cleaning-up $MODID data..."
  cleanup
  ui_print " "
fi

# function
permissive_2() {
sed -i 's|#2||g' $MODPATH/post-fs-data.sh
}
permissive() {
FILE=/sys/fs/selinux/enforce
FILE2=/sys/fs/selinux/policy
if [ "`toybox cat $FILE`" = 1 ]; then
  chmod 640 $FILE
  chmod 440 $FILE2
  echo 0 > $FILE
  if [ "`toybox cat $FILE`" = 1 ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    echo 1 > $FILE
    sed -i 's|#1||g' $MODPATH/post-fs-data.sh
  fi
else
  sed -i 's|#1||g' $MODPATH/post-fs-data.sh
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# function
extract_lib() {
for APP in $APPS; do
  FILE=`find $MODPATH/system -type f -name $APP.apk`
  if [ -f `dirname $FILE`/extract ]; then
    ui_print "- Extracting..."
    DIR=`dirname $FILE`/lib/"$ARCHLIB"
    mkdir -p $DIR
    rm -rf $TMPDIR/*
    DES=lib/"$ABILIB"/*
    unzip -d $TMPDIR -o $FILE $DES
    cp -f $TMPDIR/$DES $DIR
    ui_print " "
  fi
done
}
hide_oat() {
for APP in $APPS; do
  REPLACE="$REPLACE
  `find $MODPATH/system -type d -name $APP | sed "s|$MODPATH||g"`/oat"
done
}
replace_dir() {
if [ -d $DIR ] && [ ! -d $MODPATH$MODDIR ]; then
  REPLACE="$REPLACE $MODDIR"
fi
}
hide_app() {
for APP in $APPS; do
  DIR=$SYSTEM/app/$APP
  MODDIR=/system/app/$APP
  replace_dir
  DIR=$SYSTEM/priv-app/$APP
  MODDIR=/system/priv-app/$APP
  replace_dir
  DIR=$PRODUCT/app/$APP
  MODDIR=/system/product/app/$APP
  replace_dir
  DIR=$PRODUCT/priv-app/$APP
  MODDIR=/system/product/priv-app/$APP
  replace_dir
  DIR=$MY_PRODUCT/app/$APP
  MODDIR=/system/product/app/$APP
  replace_dir
  DIR=$MY_PRODUCT/priv-app/$APP
  MODDIR=/system/product/priv-app/$APP
  replace_dir
  DIR=$PRODUCT/preinstall/$APP
  MODDIR=/system/product/preinstall/$APP
  replace_dir
  DIR=$SYSTEM_EXT/app/$APP
  MODDIR=/system/system_ext/app/$APP
  replace_dir
  DIR=$SYSTEM_EXT/priv-app/$APP
  MODDIR=/system/system_ext/priv-app/$APP
  replace_dir
  DIR=$VENDOR/app/$APP
  MODDIR=/system/vendor/app/$APP
  replace_dir
  DIR=$VENDOR/euclid/product/app/$APP
  MODDIR=/system/vendor/euclid/product/app/$APP
  replace_dir
done
}

# extract
APPS="`ls $MODPATH/system/priv-app`
      `ls $MODPATH/system/app`"
ARCHLIB=arm64
ABILIB=arm64-v8a
extract_lib
ARCHLIB=arm
if echo "$ABILIST" | grep -q armeabi-v7a; then
  ABILIB=armeabi-v7a
  extract_lib
elif echo "$ABILIST" | grep -q armeabi; then
  ABILIB=armeabi
  extract_lib
else
  ABILIB=armeabi-v7a
  extract_lib
fi
ARCHLIB=x64
ABILIB=x86_64
extract_lib
ARCHLIB=x86
ABILIB=x86
extract_lib
rm -f `find $MODPATH/system -type f -name extract`
# hide
hide_oat
APPS="$APPS MusicFX AudioFX"
hide_app

# settings
FILE=$MODPATH/system/vendor/etc/dolby/dax-default.xml
PROP=`grep_prop dolby.bass $OPTIONALS`
if [ "$PROP" == true ]; then
  ui_print "- Changing all bass-enhancer-enable value to true"
  sed -i 's|bass-enhancer-enable value="false"|bass-enhancer-enable value="true"|g' $FILE
elif [ "$PROP" == false ]; then
  ui_print "- Changing all bass-enhancer-enable value to false"
  sed -i 's|bass-enhancer-enable value="true"|bass-enhancer-enable value="false"|g' $FILE
elif [ "$PROP" ] && [ "$PROP" != def ] && [ "$PROP" -gt 0 ]; then
  ui_print "- Changing all bass-enhancer-enable value to true"
  sed -i 's|bass-enhancer-enable value="false"|bass-enhancer-enable value="true"|g' $FILE
  ROWS=`grep bass-enhancer-boost $FILE | sed -e 's|<bass-enhancer-boost value="||g' -e 's|"/>||g' -e 's|" />||g'`
  if [ "$ROWS" ]; then
    ui_print "- Default bass-enhancer-boost value:"
    ui_print "$ROWS"
    ui_print "- Changing all bass-enhancer-boost value to $PROP"
    for ROW in $ROWS; do
      sed -i "s|bass-enhancer-boost value=\"$ROW\"|bass-enhancer-boost value=\"$PROP\"|g" $FILE
    done
  else
    ui_print "- This version does not support bass-enhancer-boost"
  fi
fi
if [ "`grep_prop dolby.virtualizer $OPTIONALS`" == 1 ]; then
  ui_print "- Changing all virtualizer-enable value to true"
  sed -i 's|virtualizer-enable value="false"|virtualizer-enable value="true"|g' $FILE
elif [ "`grep_prop dolby.virtualizer $OPTIONALS`" == 0 ]; then
  ui_print "- Changing all virtualizer-enable value to false"
  sed -i 's|virtualizer-enable value="true"|virtualizer-enable value="false"|g' $FILE
fi
if [ "`grep_prop dolby.volumeleveler $OPTIONALS`" == def ]; then
  ui_print "- Using default settings of volume-leveler"
elif [ "`grep_prop dolby.volumeleveler $OPTIONALS`" == 1 ]; then
  ui_print "- Changing all volume-leveler-enable value to true"
  sed -i 's|volume-leveler-enable value="false"|volume-leveler-enable value="true"|g' $FILE
else
  ui_print "- Changing all volume-leveler-enable value to false"
  sed -i 's|volume-leveler-enable value="true"|volume-leveler-enable value="false"|g' $FILE
fi
if [ "`grep_prop dolby.deepbass $OPTIONALS`" == 1 ]; then
  ui_print "- Using deeper bass GEQ frequency"
  sed -i 's|frequency="47"|frequency="0"|g' $FILE
  sed -i 's|frequency="141"|frequency="47"|g' $FILE
  sed -i 's|frequency="234"|frequency="141"|g' $FILE
  sed -i 's|frequency="328"|frequency="234"|g' $FILE
  sed -i 's|frequency="469"|frequency="328"|g' $FILE
  sed -i 's|frequency="656"|frequency="469"|g' $FILE
  sed -i 's|frequency="844"|frequency="656"|g' $FILE
  sed -i 's|frequency="1031"|frequency="844"|g' $FILE
  sed -i 's|frequency="1313"|frequency="1031"|g' $FILE
  sed -i 's|frequency="1688"|frequency="1313"|g' $FILE
  sed -i 's|frequency="2250"|frequency="1688"|g' $FILE
  sed -i 's|frequency="3000"|frequency="2250"|g' $FILE
  sed -i 's|frequency="3750"|frequency="3000"|g' $FILE
  sed -i 's|frequency="4688"|frequency="3750"|g' $FILE
  sed -i 's|frequency="5813"|frequency="4688"|g' $FILE
  sed -i 's|frequency="7125"|frequency="5813"|g' $FILE
  sed -i 's|frequency="9000"|frequency="7125"|g' $FILE
  sed -i 's|frequency="11250"|frequency="9000"|g' $FILE
  sed -i 's|frequency="13875"|frequency="11250"|g' $FILE
  sed -i 's|frequency="19688"|frequency="13875"|g' $FILE
fi
ui_print " "

# function
rename_file() {
if [ -f $FILE ]; then
  ui_print "- Renaming"
  ui_print "$FILE"
  ui_print "  to"
  ui_print "$MODFILE"
  mv -f $FILE $MODFILE
  ui_print " "
fi
}
change_name() {
ui_print "- Changing $NAME to $NAME2 at"
ui_print "$FILE"
ui_print "  Please wait..."
sed -i "s|$NAME|$NAME2|g" $FILE
ui_print " "
}

# mod
NAME=libcorefx.so
if [ -f $SYSTEM/lib64/$NAME ]; then
  COREFX64=true
else
  COREFX64=false
fi
if [ -f $SYSTEM/lib/$NAME ]; then
  COREFX=true
else
  COREFX=false
fi
if [ "`grep_prop dolby.mod $OPTIONALS`" != 0 ]\
&& [ "$COREFX" == false ] && [ "$COREFX64" == false ]; then
  NAME=dax-default.xml
  NAME2=dsa-default.xml
  FILE=$MODPATH/system/vendor/etc/dolby/$NAME
  MODFILE=$MODPATH/system/vendor/etc/dolby/$NAME2
  rename_file
  FILE=$MODPATH/system/vendor/lib*/libprofileparamstorage.so
  change_name
  NAME=libswdap.so
  NAME2=libswdsa.so
  if [ "$IS64BIT" == true ]; then
    FILE=$MODPATH/system/vendor/lib64/soundfx/$NAME
    MODFILE=$MODPATH/system/vendor/lib64/soundfx/$NAME2
    rename_file
  fi
  if [ "$ABILIST32" ]; then
    FILE=$MODPATH/system/vendor/lib/soundfx/$NAME
    MODFILE=$MODPATH/system/vendor/lib/soundfx/$NAME2
    rename_file
  fi
  FILE="$MODPATH/system/vendor/lib*/soundfx/$NAME2
$MODPATH/.aml.sh
$MODPATH/acdb5.conf"
  change_name
  sed -i 's|ro.samsung.dolby.mod_uuid false|ro.samsung.dolby.mod_uuid true|g' $MODPATH/service.sh
  NAME=$'\xef\x93\x7f\x67\x55\x87'
  NAME2=$'\x36\x86\xda\xf3\x76\x49'
  FILE="$MODPATH/system/vendor/lib*/soundfx/libaudioeffectoffload.so
$MODPATH/system/vendor/lib*/soundfx/libeffectproxy.so
$MODPATH/system/vendor/lib*/soundfx/libswdsa.so"
  change_name
  NAME=$'\x45\x27\x99\x21\x85\x39'
  FILE="$MODPATH/system/vendor/lib*/soundfx/libswdsa.so"
  change_name
  NAME=$'\xd5\x3e\x26\xda\x02\x53'
  FILE=$MODPATH/system/vendor/lib*/soundfx/libaudioeffectoffload.so
  change_name
  NAME=$'\x39\x53\x7a\x04\xbc\xaa'
  FILE="$MODPATH/system/vendor/lib*/soundfx/libeffectproxy.so"
  change_name
  NAME=452799218539
  NAME2=3686daf37649
  FILE="$MODPATH/.aml.sh
$MODPATH/acdb5.conf"
  change_name
  NAME=d53e26da0253
  change_name
  NAME=39537a04bcaa
  change_name
fi

# soundfx
FILE=$MODPATH/.aml.sh
if [ "`grep_prop sa.proxy $OPTIONALS`" == 0 ]; then
  ui_print "- Does not use proxy sound effect"
  sed -i 's|#w||g' $FILE
  ui_print " "
else
  sed -i 's|#x||g' $FILE
fi
if [ "`grep_prop sa.proxy $OPTIONALS`" == 0 ]\
&& [ "`grep_prop sa.volumemonitor $OPTIONALS`" == 0 ]; then
  ui_print "- Does not use VolumeMonitor sound effect"
  ui_print " "
  rm -f $MODPATH/acdb2.conf
else
  sed -i 's|#2||g' $FILE
fi
if [ "`grep_prop sa.myspace $OPTIONALS`" == 0 ]; then
  ui_print "- Does not use MySpace sound effect"
  ui_print " "
  rm -f $MODPATH/acdb3.conf
else
  sed -i 's|#3||g' $FILE
fi
if [ "`grep_prop sa.mysound $OPTIONALS`" == 0 ]; then
  ui_print "- Does not use MySound effect"
  ui_print " "
  rm -f $MODPATH/acdb4.conf
else
  sed -i 's|#4||g' $FILE
fi
if [ "`grep_prop sa.dolby $OPTIONALS`" == 0 ]; then
  ui_print "- Does not use Dolby sound effect"
  ui_print " "
  rm -f $MODPATH/acdb5.conf
else
  sed -i 's|#5||g' $FILE
fi
if [ "`grep_prop sa.soundbooster $OPTIONALS`" == 0 ]; then
  ui_print "- Does not use SoundBooster effect"
  ui_print " "
  rm -f $MODPATH/acdb6.conf
else
  sed -i 's|#6||g' $FILE
fi
if [ "`grep_prop sa.spatial $OPTIONALS`" == 1 ]; then
  # ccd4cf09-a79d-46c2-9aae-06a1698d6c8f
  DES=/vendor/lib*/hw/*audio*.so
  UUIDTYPE=$'\x09\xcf\xd4\xcc\x9d\xa7\xc2\x46\xae\x9a\x06\xa1\x69\x8d\x6c\x8f'
  ui_print "- Checking $UUIDTYPE"
  ui_print "  at $DES"
  ui_print "  Please wait..."
  if [ "`grep $UUIDTYPE $DES`" ]; then
    ui_print "  Uses Spatializer sound effect"
    ui_print "  It will cause problems if this ROM already has"
    ui_print "  a built-in Spatializer sound effect"
    sed -i 's|#7||g' $FILE
  else
    ui_print "  ! This ROM doesn't support Spatializer"
    rm -f $MODPATH/acdb7.conf\
     `find $MODPATH/system/vendor -type f -name\
     libswspatializer.so -o -name spatializer-aidl-cpp.so`
  fi
  ui_print " "
else
  rm -f $MODPATH/acdb7.conf\
   `find $MODPATH/system/vendor -type f -name\
   libswspatializer.so -o -name spatializer-aidl-cpp.so`
fi

# stream mode
FILE=$MODPATH/.aml.sh
FILE2="$MODPATH/acdb3.conf $MODPATH/acdb4.conf
       $MODPATH/acdb6.conf"
PROP=`grep_prop stream.mode $OPTIONALS`
if echo "$PROP" | grep -q m; then
  ui_print "- Activating music stream..."
  sed -i 's|#m||g' $FILE
  sed -i 's|musicstream=|musicstream=true|g' $FILE2
  ui_print " "
fi
if echo "$PROP" | grep -q r; then
  ui_print "- Activating ring stream..."
  sed -i 's|#r||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q a; then
  ui_print "- Activating alarm stream..."
  sed -i 's|#a||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q s; then
  ui_print "- Activating system stream..."
  sed -i 's|#s||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q v; then
  ui_print "- Activating voice_call stream..."
  sed -i 's|#v||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q n; then
  ui_print "- Activating notification stream..."
  sed -i 's|#n||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q b; then
  ui_print "- Activating bluetooth_sco stream..."
  sed -i 's|#b||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q f; then
  ui_print "- Activating dtmf stream..."
  sed -i 's|#f||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q e; then
  ui_print "- Activating enforced_audible stream..."
  sed -i 's|#e||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q y; then
  ui_print "- Activating accessibility stream..."
  sed -i 's|#y||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q t; then
  ui_print "- Activating tts stream..."
  sed -i 's|#t||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q i; then
  ui_print "- Activating assistant stream..."
  sed -i 's|#i||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q c; then
  ui_print "- Activating call_assistant stream..."
  sed -i 's|#c||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q p; then
  ui_print "- Activating patch stream..."
  sed -i 's|#p||g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q g; then
  ui_print "- Activating rerouting stream..."
  sed -i 's|#g||g' $FILE
  ui_print " "
fi

# directory
if [ "$API" -le 25 ]; then
  ui_print "- /vendor/lib*/soundfx is not supported in SDK 25 and bellow"
  ui_print "  Using /system/lib*/soundfx instead"
  cp -rf $MODPATH/system/vendor/lib* $MODPATH/system
  rm -rf $MODPATH/system/vendor/lib*
  ui_print " "
fi

# audio rotation
FILE=$MODPATH/service.sh
if [ "`grep_prop audio.rotation $OPTIONALS`" == 1 ]; then
  ui_print "- Enables ro.audio.monitorRotation=true"
  sed -i '1i\
resetprop -n ro.audio.monitorRotation true\
resetprop -n ro.audio.monitorWindowRotation true' $FILE
  ui_print " "
fi

# raw
FILE=$MODPATH/.aml.sh
if [ "`grep_prop disable.raw $OPTIONALS`" == 0 ]; then
  ui_print "- Does not disable Ultra Low Latency (Raw) playback"
  ui_print " "
else
  sed -i 's|#u||g' $FILE
fi

# run
MODSYSTEM=/system
. $MODPATH/copy.sh
. $MODPATH/.aml.sh

# unmount
unmount_mirror

















