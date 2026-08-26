# 预编译件上游出处清单(prebuilts manifest)

- 应用版本: 1.0.2+13(标签 `music-v1.0.2+13`)

## 版本锁定(pubspec.lock)
- media_kit_libs_android_audio: 1.3.8
- media_kit_libs_ios_audio: 1.1.4
- dart_smb2: 0.1.1

## 安卓 libmpv/FFmpeg 对象码出处
gradle 构建期从上游 release 下载(md5 锁定),即 APK 内分发的实际二进制:
["url": "https://github.com/media-kit/libmpv-android-audio-build/releases/download/v1.1.8/default-arm64-v8a.jar", "md5": "6f4af754ae94da8cbb24655fd66c07ed", "destination": file("$buildDir/v1.1.8/default-arm64-v8a.jar")],
["url": "https://github.com/media-kit/libmpv-android-audio-build/releases/download/v1.1.8/default-armeabi-v7a.jar", "md5": "d8d1ba181d3d6ecb341e1e8d87506e17", "destination": file("$buildDir/v1.1.8/default-armeabi-v7a.jar")],
["url": "https://github.com/media-kit/libmpv-android-audio-build/releases/download/v1.1.8/default-x86_64.jar", "md5": "43ed7b0e6bdaa1a6ed2c1eee01f5e44a", "destination": file("$buildDir/v1.1.8/default-x86_64.jar")],
["url": "https://github.com/media-kit/libmpv-android-audio-build/releases/download/v1.1.8/default-x86.jar", "md5": "a2acb148c02d02f0892047f5c6c4f964", "destination": file("$buildDir/v1.1.8/default-x86.jar")]

上游构建脚本仓库: https://github.com/media-kit/libmpv-android-audio-build (default flavor, LGPL 构建)

## iOS 真机 libmpv/FFmpeg 对象码出处
经 media_kit_libs_ios_audio 1.1.4 的 ios/Frameworks/*.xcframework 打包(vendored,均以独立动态 framework 分发)。
上游构建脚本仓库: https://github.com/media-kit/libmpv-darwin-build (LGPL 构建)

## libsmb2 对象码出处
经 dart_smb2 0.1.1 打包(安卓 jniLibs / iOS xcframework);源码见 source/libsmb2-6.1.tar.gz(上游 release 6.1,即 dart_smb2 标注的 v6.1.0)。
上游: https://github.com/sahlberg/libsmb2 (LGPL-2.1)

## FFmpeg 源码说明
source/ 下 FFmpeg 归档来源:先前下载的 FFmpeg 源码归档。
