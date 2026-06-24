# Sound Alive & Sound Assistant Samsung Galaxy A53 5G Magisk Module

## DISCLAIMER
- Samsung apps and blobs are owned by Samsung™.
- The MIT license specified here is for the Magisk Module only, not for Samsung apps and blobs.

## Descriptions
- Equalizer sound effects ported from Samsung Galaxy A53 5G (a53x) and integrated as a Magisk Module for all supported and rooted devices with Magisk
- Global type sound effect
- This is also allowed to install in One UI/TouchWiz ROM
- MySpace, MySound, & SoundBooster effects can only be activated via post process stream mode (READ Optionals bellow!)

## Sources
- https://github.com/ItsLynix/samsung_a53x_dump a53xnaxx-user-13-TP1A.220624.014-A536BXXU4BVJG-release-keys
- libmagiskpolicy.so: Magisk (stable) 30.7 (30700)

## Changelog

v2.2
- Support NoMount metamodule
- Update libmagiskpolicy.so from Magisk (stable) 30.7 (30700)
- Resets module folders/files permissions at post-fs-data
- Move _uninstall.log to /data/adb/logs/
- Removes conflicted weird modules
- Does not disable raw playback (You can use Audio Compatibility Patch Reborn Magisk Module instead)

v2.1
- Fix wrong target in latest KernelSU

v2.0
- Tidy up aml.sh
- Exclude \*audio\*effects\*haptic\*.xml
- Abort installation if fail to mount mirror system
- Fix wrong file permissions in some ROMs
- Remove useless c2 codec service

v1.9
- Improve /odm and /my_product support detection

v1.8
- Fix some methods and crashes

v1.7
- Add Action button to clear apps caches
- Fix architecture detection in some weird ROMs
- Fix bug in uninstall.sh

v1.6
- Fix semDesktopModeEnabled method
- DolbyManager.apk and XiaomyDolby.apk detection

v1.5
- Allow installation in Android Emulator

v1.4
- Improve \*audio\*effects\*.xml patch detection
- Disable spatializer soundfx by default
- Detects spatializer support if sa.spatial=1

v1.3
- Improve audio_effects.xml patch detection
- Does not use media_codecs_c2_dolby_audio.xml if it's already exist

## Screenshots
https://t.me/androidryukimods/854

## Requirements
- arm64-v8a or armeabi-v7a architecture
- Android 5 (SDK 21) and up
- HIDL audio service
- Magisk or Kitsune Mask or KernelSU or Apatch installed
- One UI Core Magisk Module installed in non-One UI/non-TouchWiz ROM https://github.com/reiryuki/One-UI-Core-Magisk-Module

## Installation Guide & Download Link
- If you are using KernelSU, you need to disable Unmount Modules by Default in KernelSU app settings and install https://github.com/KernelSU-Modules-Repo/meta-overlayfs or https://github.com/KernelSU-Modules-Repo/magic_mount_rs or https://github.com/KernelSU-Modules-Repo/hybrid_mount or https://github.com/maxsteeel/nomount first depending on ROM compatibility
- Install One UI Core Magisk Module first if you are in non-One UI/non-TouchWiz ROM: https://github.com/reiryuki/One-UI-Core-Magisk-Module
- Install this module via Magisk app or Kitsune Mask app or KernelSU app or Apatch app or Recovery if Magisk or Kitsune Mask installed
- Install AML Magisk Module https://t.me/ryukinotes/34 only if using any other else audio mod module
- Reboot
- If you are using KernelSU, you need to allow superuser list manually all package name listed in package.txt (and your home launcher app also) (enable show system apps) and reboot afterwards
- If you are using SUList, you need to allow list manually your home launcher app (enable show system apps) and reboot afterwards

## Known Issues
- SoundAlive effect may not work if using post process stream mode
- UHQ Upscaler, Adapt Sound, Voice Changer, & Separate app sound doesn't work except with OneUI ROM
- Unsupported in some Mediatek devices
- Makes stock AOSP sound effects (equalizer, bassboost, virtualizer, & reverb) not loaded

## Optionals
- https://t.me/ryukinotes/60
- Global: https://t.me/ryukinotes/35
- Stream: https://t.me/ryukinotes/52

## Troubleshootings
Global: https://t.me/ryukinotes/34

## Support & Bug Report
- https://t.me/ryukinotes/54
- If you don't do above, issues will be closed immediately

## Credits and Contributors
- @HuskyDG
- https://t.me/viperatmos
- https://t.me/androidryukimodsdiscussions
- You can contribute ideas about this Magisk Module here: https://t.me/androidappsportdevelopment

## Sponsors
https://t.me/ryukinotes/25


