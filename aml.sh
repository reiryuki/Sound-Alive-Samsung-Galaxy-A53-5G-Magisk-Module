[ ! "$MODPATH" ] && MODPATH=${0%/*}
[ ! "$API" ] && API=`getprop ro.build.version.sdk`

# destination
if [ ! "$libdir" ]; then
  if [ "$API" -ge 26 ]; then
    libdir=/vendor
  else
    libdir=/system
  fi
fi
MODAECS=`find $MODPATH -type f -name *audio*effects*.conf`
MODAEXS=`find $MODPATH -type f -name *audio*effects*.xml`
MODAPS=`find $MODPATH -type f -name *policy*.conf -o -name *policy*.xml`

# function
archdir() {
if [ -f $libdir/lib/soundfx/$LIB ]\
|| [ -f $MODPATH/system$libdir/lib/soundfx/$LIB ]\
|| [ -f $MODPATH$libdir/lib/soundfx/$LIB ]; then
  ARCHDIR=/lib
elif [ -f $libdir/lib64/soundfx/$LIB ]\
|| [ -f $MODPATH/system$libdir/lib64/soundfx/$LIB ]\
|| [ -f $MODPATH$libdir/lib64/soundfx/$LIB ]; then
  ARCHDIR=/lib64
else
  unset ARCHDIR
fi
}
remove_conf() {
for RMV in $RMVS; do
  sed -i "s|$RMV|removed|g" $MODAEC
done
sed -i 's|path /vendor/lib/soundfx/removed||g' $MODAEC
sed -i 's|path /system/lib/soundfx/removed||g' $MODAEC
sed -i 's|path /vendor/lib/removed||g' $MODAEC
sed -i 's|path /system/lib/removed||g' $MODAEC
sed -i 's|path /vendor/lib64/soundfx/removed||g' $MODAEC
sed -i 's|path /system/lib64/soundfx/removed||g' $MODAEC
sed -i 's|path /vendor/lib64/removed||g' $MODAEC
sed -i 's|path /system/lib64/removed||g' $MODAEC
sed -i 's|library removed||g' $MODAEC
sed -i 's|uuid removed||g' $MODAEC
sed -i "/^        removed {/ {;N s/        removed {\n        }//}" $MODAEC
sed -i 's|removed { }||g' $MODAEC
sed -i 's|removed {}||g' $MODAEC
}
remove_xml() {
for RMV in $RMVS; do
  sed -i "s|\"$RMV\"|\"removed\"|g" $MODAEX
done
sed -i 's|<library name="removed" path="removed"/>||g' $MODAEX
sed -i 's|<library name="proxy" path="removed"/>||g' $MODAEX
sed -i 's|<effect name="removed" library="removed" uuid="removed"/>||g' $MODAEX
sed -i 's|<effect name="removed" uuid="removed" library="removed"/>||g' $MODAEX
sed -i 's|<libsw library="removed" uuid="removed"/>||g' $MODAEX
sed -i 's|<libhw library="removed" uuid="removed"/>||g' $MODAEX
sed -i 's|<apply effect="removed"/>||g' $MODAEX
sed -i 's|<library name="removed" path="removed" />||g' $MODAEX
sed -i 's|<library name="proxy" path="removed" />||g' $MODAEX
sed -i 's|<effect name="removed" library="removed" uuid="removed" />||g' $MODAEX
sed -i 's|<effect name="removed" uuid="removed" library="removed" />||g' $MODAEX
sed -i 's|<libsw library="removed" uuid="removed" />||g' $MODAEX
sed -i 's|<libhw library="removed" uuid="removed" />||g' $MODAEX
sed -i 's|<apply effect="removed" />||g' $MODAEX
}

# store
RMVS="ring_helper alarm_helper music_helper voice_helper
      notification_helper ma_ring_helper ma_alarm_helper
      ma_music_helper ma_voice_helper ma_system_helper
      ma_notification_helper sa3d fens lmfv dirac dtsaudio
      dlb_music_listener dlb_ring_listener dlb_alarm_listener
      dlb_system_listener dlb_notification_listener"

# setup audio effects conf
for MODAEC in $MODAECS; do
  for RMV in $RMVS; do
    sed -i "/^        $RMV {/ {;N s/        $RMV {\n        }//}" $MODAEC
    sed -i "s|$RMV { }||g" $MODAEC
    sed -i "s|$RMV {}||g" $MODAEC
  done
  if ! grep -q '^output_session_processing {' $MODAEC; then
    sed -i '$a\
\
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
    bluetooth_sco {\
    }\
    dtmf {\
    }\
    enforced_audible {\
    }\
    accessibility {\
    }\
    tts {\
    }\
    assistant {\
    }\
    call_assistant {\
    }\
    patch {\
    }\
    rerouting {\
    }\
}\' $MODAEC
  else
    if ! grep -q '^    rerouting {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    rerouting {\n    }" $MODAEC
    fi
    if ! grep -q '^    patch {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    patch {\n    }" $MODAEC
    fi
    if ! grep -q '^    call_assistant {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    call_assistant {\n    }" $MODAEC
    fi
    if ! grep -q '^    assistant {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    assistant {\n    }" $MODAEC
    fi
    if ! grep -q '^    tts {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    tts {\n    }" $MODAEC
    fi
    if ! grep -q '^    accessibility {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    accessibility {\n    }" $MODAEC
    fi
    if ! grep -q '^    enforced_audible {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    enforced_audible {\n    }" $MODAEC
    fi
    if ! grep -q '^    dtmf {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    dtmf {\n    }" $MODAEC
    fi
    if ! grep -q '^    bluetooth_sco {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    bluetooth_sco {\n    }" $MODAEC
    fi
    if ! grep -q '^    notification {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    notification {\n    }" $MODAEC
    fi
    if ! grep -q '^    voice_call {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    voice_call {\n    }" $MODAEC
    fi
    if ! grep -q '^    system {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    system {\n    }" $MODAEC
    fi
    if ! grep -q '^    alarm {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    alarm {\n    }" $MODAEC
    fi
    if ! grep -q '^    ring {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    ring {\n    }" $MODAEC
    fi
    if ! grep -q '^    music {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    music {\n    }" $MODAEC
    fi
  fi
done

# setup audio effects xml
for MODAEX in $MODAEXS; do
  for RMV in $RMVS; do
    sed -i "s|<apply effect=\"$RMV\"/>||g" $MODAEX
    sed -i "s|<apply effect=\"$RMV\" />||g" $MODAEX
  done
  if ! grep -q '<postprocess>' $MODAEX\
  || grep -q '<!-- Audio post processor' $MODAEX; then
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
        <stream type="bluetooth_sco">\
        <\/stream>\
        <stream type="dtmf">\
        <\/stream>\
        <stream type="enforced_audible">\
        <\/stream>\
        <stream type="accessibility">\
        <\/stream>\
        <stream type="tts">\
        <\/stream>\
        <stream type="assistant">\
        <\/stream>\
        <stream type="call_assistant">\
        <\/stream>\
        <stream type="patch">\
        <\/stream>\
        <stream type="rerouting">\
        <\/stream>\
    <\/postprocess>' $MODAEX
  else
    if ! grep -q '<stream type="rerouting">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"rerouting\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="patch">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"patch\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="call_assistant">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"call_assistant\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="assistant">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"assistant\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="tts">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"tts\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="accessibility">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"accessibility\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="enforced_audible">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"enforced_audible\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="dtmf">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"dtmf\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="bluetooth_sco">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"bluetooth_sco\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="notification">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX\
    || grep -q '<!-- heaton.zhong' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"notification\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="voice_call">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"voice_call\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="system">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"system\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="alarm">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX\
    || grep -q '<!-- heaton.zhong' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"alarm\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="ring">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX\
    || grep -q '<!-- heaton.zhong' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"ring\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="music">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX\
    || grep -q '<!-- heaton.zhong' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"music\">\n        <\/stream>" $MODAEX
    fi
  fi
done

# function
volumemonitor_hw() {
LIB=libaudioeffectoffload.so
LIBNAMEHW=offload
LIBNAMEHW=offload_mod
NAME=volumemonitor_hw
UUID=052a63b0-f95a-11e9-8f0b-362b9e155667
RMVS="libeffectproxy.so $LIB $LIBNAMEHW $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  proxy {\n    path \\$libdir\\$ARCHDIR\/soundfx\/libeffectproxy.so\n  }" $MODAEC
    sed -i "/^libraries {/a\  $LIBNAMEHW {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAMEHW\n    uuid $UUID\n  }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"proxy\" path=\"libeffectproxy.so\"\/>" $MODAEX
    sed -i "/<libraries>/a\        <library name=\"$LIBNAMEHW\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAMEHW\" uuid=\"$UUID\"\/>" $MODAEX
  done
fi
}
soundalive() {
LIB=libaudiosaplus_sec.so
LIBNAME=soundalive_sec
NAME=soundalive
UUID=cf65eb39-ce2f-48a8-a903-ceb818c06745
UUIDHW=0b2dbc60-50bb-11e3-988b-0002a5d5c51b
UUIDPROXY=05227ea0-50bb-11e3-ac69-0002a5d5c51b
RMVS="$LIB $LIBNAME $NAME $UUID $UUIDHW $UUIDPROXY"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
    sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
    sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
  done
fi
}
soundalive_sec() {
LIB=libaudiosaplus_sec.so
LIBNAME=soundalive_sec
NAME=soundalive_sec
UUID=cf65eb39-ce2f-48a8-a903-ceb818c06745
RMVS="$LIB $LIBNAME $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  done
fi
}
sa3d() {
LIB=libmyspace.so
LIBNAME=myspace
NAME=sa3d
NAME=sa3d_mod
UUID=3462a6e0-655a-11e4-8b67-0002a5d5c51b
UUIDHW=c7a84e61-eebe-4fcc-bc53-efcb841b4625
UUIDPROXY=1c91fca0-664a-11e4-b8c2-0002a5d5c51b
RMVS="$LIB $LIBNAME $NAME $UUID $UUIDHW $UUIDPROXY"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
#m    sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r    sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a    sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s    sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v    sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n    sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#b    sed -i "/^    bluetooth_sco {/a\        $NAME {\n        }" $MODAEC
#f    sed -i "/^    dtmf {/a\        $NAME {\n        }" $MODAEC
#e    sed -i "/^    enforced_audible {/a\        $NAME {\n        }" $MODAEC
#y    sed -i "/^    accessibility {/a\        $NAME {\n        }" $MODAEC
#t    sed -i "/^    tts {/a\        $NAME {\n        }" $MODAEC
#i    sed -i "/^    assistant {/a\        $NAME {\n        }" $MODAEC
#c    sed -i "/^    call_assistant {/a\        $NAME {\n        }" $MODAEC
#p    sed -i "/^    patch {/a\        $NAME {\n        }" $MODAEC
#g    sed -i "/^    rerouting {/a\        $NAME {\n        }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
    sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
    sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
#m    sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r    sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a    sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s    sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v    sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n    sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#b    sed -i "/<stream type=\"bluetooth_sco\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#f    sed -i "/<stream type=\"dtmf\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#e    sed -i "/<stream type=\"enforced_audible\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#y    sed -i "/<stream type=\"accessibility\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#t    sed -i "/<stream type=\"tts\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#i    sed -i "/<stream type=\"assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c    sed -i "/<stream type=\"call_assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#p    sed -i "/<stream type=\"patch\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#g    sed -i "/<stream type=\"rerouting\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
  done
fi
}
myspace() {
LIB=libmyspace.so
LIBNAME=myspace
NAME=myspace
UUID=cf65eb39-ce2f-48a8-a903-ceb818c06745
RMVS="$LIB $LIBNAME $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
#m    sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r    sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a    sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s    sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v    sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n    sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#b    sed -i "/^    bluetooth_sco {/a\        $NAME {\n        }" $MODAEC
#f    sed -i "/^    dtmf {/a\        $NAME {\n        }" $MODAEC
#e    sed -i "/^    enforced_audible {/a\        $NAME {\n        }" $MODAEC
#y    sed -i "/^    accessibility {/a\        $NAME {\n        }" $MODAEC
#t    sed -i "/^    tts {/a\        $NAME {\n        }" $MODAEC
#i    sed -i "/^    assistant {/a\        $NAME {\n        }" $MODAEC
#c    sed -i "/^    call_assistant {/a\        $NAME {\n        }" $MODAEC
#p    sed -i "/^    patch {/a\        $NAME {\n        }" $MODAEC
#g    sed -i "/^    rerouting {/a\        $NAME {\n        }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
#m    sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r    sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a    sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s    sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v    sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n    sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#b    sed -i "/<stream type=\"bluetooth_sco\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#f    sed -i "/<stream type=\"dtmf\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#e    sed -i "/<stream type=\"enforced_audible\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#y    sed -i "/<stream type=\"accessibility\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#t    sed -i "/<stream type=\"tts\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#i    sed -i "/<stream type=\"assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c    sed -i "/<stream type=\"call_assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#p    sed -i "/<stream type=\"patch\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#g    sed -i "/<stream type=\"rerouting\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
  done
fi
}
dha() {
LIB=libmysound.so
LIBNAME=mysound
NAME=dha
UUID=263a88e0-50b1-11e2-bcfd-0800200c9a66
UUIDHW=3ef69260-50bb-11e3-931e-0002a5d5c51b
UUIDPROXY=37155c20-50bb-11e3-9fac-0002a5d5c51b
RMVS="$LIB $LIBNAME $NAME $UUID $UUIDHW $UUIDPROXY"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
#m    sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r    sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a    sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s    sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v    sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n    sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#b    sed -i "/^    bluetooth_sco {/a\        $NAME {\n        }" $MODAEC
#f    sed -i "/^    dtmf {/a\        $NAME {\n        }" $MODAEC
#e    sed -i "/^    enforced_audible {/a\        $NAME {\n        }" $MODAEC
#y    sed -i "/^    accessibility {/a\        $NAME {\n        }" $MODAEC
#t    sed -i "/^    tts {/a\        $NAME {\n        }" $MODAEC
#i    sed -i "/^    assistant {/a\        $NAME {\n        }" $MODAEC
#c    sed -i "/^    call_assistant {/a\        $NAME {\n        }" $MODAEC
#p    sed -i "/^    patch {/a\        $NAME {\n        }" $MODAEC
#g    sed -i "/^    rerouting {/a\        $NAME {\n        }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
    sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
    sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
#m    sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r    sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a    sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s    sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v    sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n    sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#b    sed -i "/<stream type=\"bluetooth_sco\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#f    sed -i "/<stream type=\"dtmf\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#e    sed -i "/<stream type=\"enforced_audible\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#y    sed -i "/<stream type=\"accessibility\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#t    sed -i "/<stream type=\"tts\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#i    sed -i "/<stream type=\"assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c    sed -i "/<stream type=\"call_assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#p    sed -i "/<stream type=\"patch\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#g    sed -i "/<stream type=\"rerouting\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
  done
fi
}
mysound() {
LIB=libmysound.so
LIBNAME=mysound
NAME=mysound
UUID=cf65eb39-ce2f-48a8-a903-ceb818c06745
RMVS="$LIB $LIBNAME $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
#m    sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r    sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a    sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s    sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v    sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n    sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#b    sed -i "/^    bluetooth_sco {/a\        $NAME {\n        }" $MODAEC
#f    sed -i "/^    dtmf {/a\        $NAME {\n        }" $MODAEC
#e    sed -i "/^    enforced_audible {/a\        $NAME {\n        }" $MODAEC
#y    sed -i "/^    accessibility {/a\        $NAME {\n        }" $MODAEC
#t    sed -i "/^    tts {/a\        $NAME {\n        }" $MODAEC
#i    sed -i "/^    assistant {/a\        $NAME {\n        }" $MODAEC
#c    sed -i "/^    call_assistant {/a\        $NAME {\n        }" $MODAEC
#p    sed -i "/^    patch {/a\        $NAME {\n        }" $MODAEC
#g    sed -i "/^    rerouting {/a\        $NAME {\n        }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
#m    sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r    sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a    sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s    sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v    sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n    sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#b    sed -i "/<stream type=\"bluetooth_sco\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#f    sed -i "/<stream type=\"dtmf\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#e    sed -i "/<stream type=\"enforced_audible\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#y    sed -i "/<stream type=\"accessibility\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#t    sed -i "/<stream type=\"tts\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#i    sed -i "/<stream type=\"assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c    sed -i "/<stream type=\"call_assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#p    sed -i "/<stream type=\"patch\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#g    sed -i "/<stream type=\"rerouting\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
  done
fi
}
soundbooster_plus() {
LIB=libsamsungSoundbooster_plus.so
LIBNAME=soundbooster_plus
NAME=soundbooster_plus
UUID=50de45f0-5d4c-11e5-a837-0800200c9a66
RMVS="$LIB $LIBNAME $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
#m    sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r    sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a    sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s    sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v    sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n    sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#b    sed -i "/^    bluetooth_sco {/a\        $NAME {\n        }" $MODAEC
#f    sed -i "/^    dtmf {/a\        $NAME {\n        }" $MODAEC
#e    sed -i "/^    enforced_audible {/a\        $NAME {\n        }" $MODAEC
#y    sed -i "/^    accessibility {/a\        $NAME {\n        }" $MODAEC
#t    sed -i "/^    tts {/a\        $NAME {\n        }" $MODAEC
#i    sed -i "/^    assistant {/a\        $NAME {\n        }" $MODAEC
#c    sed -i "/^    call_assistant {/a\        $NAME {\n        }" $MODAEC
#p    sed -i "/^    patch {/a\        $NAME {\n        }" $MODAEC
#g    sed -i "/^    rerouting {/a\        $NAME {\n        }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
#m    sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r    sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a    sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s    sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v    sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n    sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#b    sed -i "/<stream type=\"bluetooth_sco\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#f    sed -i "/<stream type=\"dtmf\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#e    sed -i "/<stream type=\"enforced_audible\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#y    sed -i "/<stream type=\"accessibility\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#t    sed -i "/<stream type=\"tts\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#i    sed -i "/<stream type=\"assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c    sed -i "/<stream type=\"call_assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#p    sed -i "/<stream type=\"patch\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#g    sed -i "/<stream type=\"rerouting\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
  done
fi
}
dap_proxy() {
LIB=libswdap.so
LIBNAME=dap
LIBNAME=dap_sa
NAME=dap_proxy
NAME=dap_sa_proxy
UUID=6ab06da4-c516-4611-8166-452799218539
UUIDHW=a0c30891-8246-4aef-b8ad-d53e26da0253
UUIDPROXY=9d4921da-8225-4f29-aefa-39537a04bcaa
RMVS="$LIB $NAME $LIBNAME $UUID $UUIDHW $UUIDPROXY"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library proxy\n    uuid $UUIDPROXY\n  }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libhw {\n      library $LIBNAMEHW\n      uuid $UUIDHW\n    }" $MODAEC
    sed -i "/^    uuid $UUIDPROXY/a\    libsw {\n      library $LIBNAME\n      uuid $UUID\n    }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <\/effectProxy>" $MODAEX
    sed -i "/<effects>/a\            <libhw library=\"$LIBNAMEHW\" uuid=\"$UUIDHW\"\/>" $MODAEX
    sed -i "/<effects>/a\            <libsw library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effectProxy name=\"$NAME\" library=\"proxy\" uuid=\"$UUIDPROXY\">" $MODAEX
  done
fi
}
dap() {
LIB=libswdap.so
LIBNAME=dap
LIBNAME=dap_sa
NAME=dap
NAME=dap_sa
UUID=6ab06da4-c516-4611-8166-452799218539
RMVS="$LIB $LIBNAME $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  done
fi
}
spatializer() {
LIB=libswspatializer.so
LIBNAME=spatializer
LIBNAME=spatializer_mod
NAME=spatializer
NAME=spatializer_mod
UUID=ccd4cf09-a79d-46c2-9aae-06a1698d6c8f
RMVS="$LIB $LIBNAME $NAME $UUID"
archdir
if [ "$ARCHDIR" ]; then
  for MODAEC in $MODAECS; do
    remove_conf
    sed -i "/^libraries {/a\  $LIBNAME {\n    path \\$libdir\\$ARCHDIR\/soundfx\/$LIB\n  }" $MODAEC
    sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
  done
  for MODAEX in $MODAEXS; do
    remove_xml
    sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
    sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
  done
fi
}

# patch audio effects
#2volumemonitor_hw
#xsoundalive
#3#xsa3d
#4#xdha
#5#xdap_proxy
#wsoundalive_sec
#3#wmyspace
#4#wmysound
#5#wdap
#6soundbooster_plus
#7if [ ! -f /vendor/etc/audio_effects_spatializer.xml ]\
#7&& [ ! -f /odm/etc/audio_effects_spatializer.xml ]\
#7&& [ ! -f /system/etc/audio_effects_spatializer.xml ]\
#7&& [ ! -f /my_product/etc/audio_effects_spatializer.xml ]; then
#7  spatializer
#7fi

# patch audio policy
for MODAP in $MODAPS; do
  sed -i 's|COMPRESS_OFFLOAD|NONE|g' $MODAP
  sed -i 's|,compressed_offload||g' $MODAP
#u  sed -i 's|RAW|NONE|g' $MODAP
#u  sed -i 's|,raw||g' $MODAP
done















