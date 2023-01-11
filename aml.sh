MODPATH=${0%/*}

# magisk
if [ -d /sbin/.magisk ]; then
  MAGISKTMP=/sbin/.magisk
else
  MAGISKTMP=`realpath /dev/*/.magisk`
fi

# path
VENDOR=`realpath $MAGISKTMP/mirror/vendor`

# destination
if [ -d $VENDOR/lib/soundfx ]; then
  LIBPATH="\/vendor\/lib\/soundfx"
else
  LIBPATH="\/system\/lib\/soundfx"
fi
MODAEC=`find $MODPATH/system -type f -name *audio*effects*.conf`
MODAEX=`find $MODPATH/system -type f -name *audio*effects*.xml`
MODAP=`find $MODPATH/system -type f -name *policy*.conf -o -name *policy*.xml`
MODMC=$MODPATH/system/vendor/etc/media_codecs.xml

# function
remove_conf() {
for RMVS in $RMV; do
  sed -i "s/$RMVS/removed/g" $MODAEC
done
sed -i 's/path \/vendor\/lib\/soundfx\/removed//g' $MODAEC
sed -i 's/path \/system\/lib\/soundfx\/removed//g' $MODAEC
sed -i 's/path \/vendor\/lib\/removed//g' $MODAEC
sed -i 's/path \/system\/lib\/removed//g' $MODAEC
sed -i 's/library removed//g' $MODAEC
sed -i 's/uuid removed//g' $MODAEC
sed -i "/^        removed {/ {;N s/        removed {\n        }//}" $MODAEC
}
remove_xml() {
for RMVS in $RMV; do
  sed -i "s/\"$RMVS\"/\"removed\"/g" $MODAEX
done
sed -i 's/<library name="removed" path="removed"\/>//g' $MODAEX
sed -i 's/<library name="proxy" path="removed"\/>//g' $MODAEX
sed -i 's/<effect name="removed" library="removed" uuid="removed"\/>//g' $MODAEX
sed -i 's/<effect name="removed" uuid="removed" library="removed"\/>//g' $MODAEX
sed -i 's/<libsw library="removed" uuid="removed"\/>//g' $MODAEX
sed -i 's/<libhw library="removed" uuid="removed"\/>//g' $MODAEX
sed -i 's/<apply effect="removed"\/>//g' $MODAEX
sed -i 's/<library name="removed" path="removed" \/>//g' $MODAEX
sed -i 's/<library name="proxy" path="removed" \/>//g' $MODAEX
sed -i 's/<effect name="removed" library="removed" uuid="removed" \/>//g' $MODAEX
sed -i 's/<effect name="removed" uuid="removed" library="removed" \/>//g' $MODAEX
sed -i 's/<libsw library="removed" uuid="removed" \/>//g' $MODAEX
sed -i 's/<libhw library="removed" uuid="removed" \/>//g' $MODAEX
sed -i 's/<apply effect="removed" \/>//g' $MODAEX
}

# store
RMV="ring_helper alarm_helper music_helper voice_helper
     notification_helper ma_ring_helper ma_alarm_helper
     ma_music_helper ma_voice_helper ma_system_helper
     ma_notification_helper sa3d fens lmfv dirac dtsaudio
     dlb_music_listener dlb_ring_listener dlb_alarm_listener
     dlb_system_listener dlb_notification_listener"

# setup audio effects conf
if [ "$MODAEC" ]; then
  for RMVS in $RMV; do
    sed -i "/^        $RMVS {/ {;N s/        $RMVS {\n        }//}" $MODAEC
    sed -i "s/$RMVS { }//g" $MODAEC
    sed -i "s/$RMVS {}//g" $MODAEC
  done
  if ! grep -Eq '^output_session_processing {' $MODAEC; then
    sed -i -e '$a\
output_session_processing {\
    music {\
    }\
    ring {\
    }\
    alarm {\
    }\
    system {\
    }\
    voice_call {\
    }\
    notification {\
    }\
}\' $MODAEC
  else
    if ! grep -Eq '^    notification {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    notification {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    voice_call {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    voice_call {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    system {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    system {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    alarm {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    alarm {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    ring {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    ring {\n    }" $MODAEC
    fi
    if ! grep -Eq '^    music {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    music {\n    }" $MODAEC
    fi
  fi
fi

# setup audio effects xml
if [ "$MODAEX" ]; then
  for RMVS in $RMV; do
    sed -i "s/<apply effect=\"$RMVS\"\/>//g" $MODAEX
    sed -i "s/<apply effect=\"$RMVS\" \/>//g" $MODAEX
  done
  if ! grep -Eq '<postprocess>' $MODAEX\
  || grep -Eq '<!-- Audio post processor' $MODAEX; then
    sed -i '/<\/effects>/a\
    <postprocess>\
        <stream type="music">\
        <\/stream>\
        <stream type="ring">\
        <\/stream>\
        <stream type="alarm">\
        <\/stream>\
        <stream type="system">\
        <\/stream>\
        <stream type="voice_call">\
        <\/stream>\
        <stream type="notification">\
        <\/stream>\
    <\/postprocess>' $MODAEX
  else
    if ! grep -Eq '<stream type="notification">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"notification\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="voice_call">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"voice_call\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="system">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"system\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="alarm">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"alarm\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="ring">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"ring\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -Eq '<stream type="music">' $MODAEX\
    || grep -Eq '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -Eq '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"music\">\n        <\/stream>" $MODAEX
    fi
  fi
fi

# function
offload() {
# store
LIBHW=libaudioeffectoffload.so
LIBNAMEHW=offload
RMV="libeffectproxy.so $LIBHW"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  proxy {\n    path $LIBPATH\/libeffectproxy.so\n  }" $MODAEC
  sed -i "/^libraries {/a\  $LIBNAMEHW {\n    path $LIBPATH\/$LIBHW\n  }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"proxy\" path=\"libeffectproxy.so\"\/>" $MODAEX
  sed -i "/<libraries>/a\        <library name=\"$LIBNAMEHW\" path=\"$LIBHW\"\/>" $MODAEX
fi
}
volumemonitor_hw() {
# store
NAME=volumemonitor_hw
UUID=052a63b0-f95a-11e9-8f0b-362b9e155667
RMV="$NAME $UUID"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAMEHW\n    uuid $UUID\n  }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAMEHW\" uuid=\"$UUID\"\/>" $MODAEX
fi
}
soundalive() {
# store
LIB=libaudiosaplus_sec.so
LIBNAME=soundalive_sec
NAME=soundalive
UUID=cf65eb39-ce2f-48a8-a903-ceb818c06745
UUIDHW=0b2dbc60-50bb-11e3-988b-0002a5d5c51b
UUIDPROXY=05227ea0-50bb-11e3-ac69-0002a5d5c51b
RMV="$LIB $LIBNAME $NAME $UUID $UUIDHW $UUIDPROXY"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
  sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
  sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
fi
}
sa3d() {
# store
LIB=libmyspace.so
LIBNAME=myspace
NAME=sa3d
UUID=3462a6e0-655a-11e4-8b67-0002a5d5c51b
UUIDHW=c7a84e61-eebe-4fcc-bc53-efcb841b4625
UUIDPROXY=1c91fca0-664a-11e4-b8c2-0002a5d5c51b
RMV="$LIB $LIBNAME $NAME $UUID $UUIDHW $UUIDPROXY"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
  sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
  sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
fi
}
dha() {
# store
LIB=libmysound.so
LIBNAME=mysound
NAME=dha
UUID=263a88e0-50b1-11e2-bcfd-0800200c9a66
UUIDHW=3ef69260-50bb-11e3-931e-0002a5d5c51b
UUIDPROXY=37155c20-50bb-11e3-9fac-0002a5d5c51b
RMV="$LIB $LIBNAME $NAME $UUID $UUIDHW $UUIDPROXY"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
  sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
  sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
fi
}
dap_soundalive_proxy() {
# store
#LIB=libswdap.so
#LIBNAME=dap
#NAME=dap_proxy
#UUID=6ab06da4-c516-4611-8166-452799218539
#UUIDHW=a0c30891-8246-4aef-b8ad-d53e26da0253
#UUIDPROXY=9d4921da-8225-4f29-aefa-39537a04bcaa
LIB=libswdsa.so
LIBNAME=dap_soundalive
NAME=dap_soundalive_proxy
UUID=6ab06da4-c516-4611-8166-3686daf37649
UUIDHW=a0c30891-8246-4aef-b8ad-3686daf37649
UUIDPROXY=9d4921da-8225-4f29-aefa-3686daf37649
RMV="$LIB $NAME $LIBNAME $UUID $UUIDHW $UUIDPROXY"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
  sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
  sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
  sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
fi
}
gamedap_soundalive() {
# store
LIB=libswgsa.so
LIBNAME=gamedap_soundalive
NAME=gamedap_soundalive
UUID=3783c334-d3a0-4d13-874f-3686daf37649
RMV="$LIB $LIBNAME $NAME $UUID"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
fi
}
soundbooster_plus() {
# store
LIB=libsamsungSoundbooster_plus.so
LIBNAME=soundbooster_plus
NAME=soundbooster_plus
UUID=50de45f0-5d4c-11e5-a837-0800200c9a66
RMV="$LIB $LIBNAME $NAME $UUID"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
fi
}
spatializer() {
# store
LIB=libswspatializer.so
LIBNAME=spatializer
NAME=spatializer
UUID=ccd4cf09-a79d-46c2-9aae-06a1698d6c8f
RMV="$LIB $LIBNAME $NAME $UUID"
# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
fi
# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
fi
}

# effect
offload
volumemonitor_hw
soundalive
sa3d
dha
dap_soundalive_proxy
gamedap_soundalive
soundbooster_plus
#11spatializer

# patch audio policy
if [ "$MODAP" ]; then
  sed -i 's/COMPRESS_OFFLOAD/NONE/g' $MODAP
  sed -i 's/,compressed_offload//g' $MODAP
fi

# patch audio policy
#uif [ "$MODAP" ]; then
#u  sed -i 's/RAW/NONE/g' $MODAP
#u  sed -i 's/,raw//g' $MODAP
#ufi

# patch media codecs
if [ -f $MODMC ]; then
  sed -i '/<MediaCodecs>/a\
    <Include href="media_codecs_dolby_audio.xml"/>' $MODMC
fi











