#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# FFmpeg 鸿蒙交叉编译脚本(仅 WMA 解码,最小体积)
#
# 产物: libavcodec/libavformat/libavutil/libswresample .so (aarch64-ohos)
# 输出到: vendor/ffmpeg-ohos/libs/arm64-v8a/
#
# 用法: bash scripts/build-ffmpeg-ohos.sh [ffmpeg源码目录]
#   源码目录默认 /tmp/ffmpeg-wma/FFmpeg
#
# 背景:鸿蒙 AVPlayer 不支持 wma/asf(微软格式),需 FFmpeg 解码。
# 只启用 asf demuxer + wmav1/wmav2/wmapro 解码器 + swresample(重采样到
# AudioRenderer 需要的 s16),disable 其余一切,最小化 so 体积。
# ---------------------------------------------------------------------------
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FFMPEG_SRC="${1:-/tmp/ffmpeg-wma/FFmpeg}"
NDK="${DEVECO_SDK_HOME:-/Applications/DevEco-Studio.app/Contents/sdk}/default/openharmony/native"
TOOLCHAIN="$NDK/llvm"
SYSROOT="$NDK/sysroot"
CC="$TOOLCHAIN/bin/aarch64-unknown-linux-ohos-clang"
OUT="$REPO_ROOT/vendor/ffmpeg-ohos"
# 安装前缀固定(与检出路径解耦):configure 的 --prefix 会随 FFMPEG_CONFIGURATION
# 字符串嵌入 .so;若用 REPO_ROOT 派生,换机器/换检出目录就无法字节级复现。
# 固定为统一路径,任意环境可复现同等二进制(验证记录见 docs/ohos-android-gap.md)。
INSTALL_PREFIX="/tmp/ffmpeg-ohos-install"

if [[ ! -x "$CC" ]]; then
  echo "✗ 找不到鸿蒙交叉编译器: $CC" >&2
  echo "  请确认 DevEco SDK 安装或设置 DEVECO_SDK_HOME" >&2
  exit 1
fi
if [[ ! -f "$FFMPEG_SRC/configure" ]]; then
  echo "✗ 找不到 FFmpeg 源码: $FFMPEG_SRC/configure" >&2
  echo "  用法: bash scripts/build-ffmpeg-ohos.sh [ffmpeg源码目录]" >&2
  exit 1
fi

cd "$FFMPEG_SRC"
make distclean >/dev/null 2>&1 || true

echo "==> configure (aarch64-ohos, 仅 WMA 解码)"
./configure \
  --target-os=linux \
  --arch=aarch64 \
  --enable-cross-compile \
  --cc="$CC" \
  --cxx="${CC}++" \
  --sysroot="$SYSROOT" \
  --extra-cflags="-D__OHOS__ -O2 -fPIC" \
  --extra-ldflags="-fPIC" \
  --prefix="$INSTALL_PREFIX" \
  --enable-shared \
  --disable-static \
  --disable-programs \
  --disable-doc \
  --disable-everything \
  --disable-network \
  --disable-autodetect \
  --enable-avformat \
  --enable-avcodec \
  --enable-swresample \
  --enable-avutil \
  --enable-demuxer=asf \
  --enable-decoder=wmav1,wmav2,wmapro,wmalossless \
  --enable-protocol=file \
  --enable-small \
  --disable-symver \
  --disable-avdevice \
  --disable-avfilter \
  --disable-swscale \
  --disable-debug

# SONAME 去版本后缀:鸿蒙 HAP 打包按文件名解析 DT_NEEDED,带版本号
# (libavcodec.so.61)需同名字文件,故统一改成 libavcodec.so 等无版本名。
# --disable-symver 只去符号版本化,SONAME 需覆盖 SLIB* make 变量
# (FFmpeg 7.x 的 config.mak 在 ffbuild/ 下)。
sed -i.bak \
  -e 's|^SLIBNAME=.*|SLIBNAME=$(SLIBPREF)$(FULLNAME)$(SLIBSUF)|' \
  -e 's|^SLIBNAME_WITH_VERSION=.*|SLIBNAME_WITH_VERSION=$(SLIBNAME)|' \
  -e 's|^SLIBNAME_WITH_MAJOR=.*|SLIBNAME_WITH_MAJOR=$(SLIBNAME)|' \
  -e 's|^SLIB_INSTALL_NAME=.*|SLIB_INSTALL_NAME=$(SLIBNAME)|' \
  -e 's|^SLIB_INSTALL_LINKS=.*|SLIB_INSTALL_LINKS=|' \
  -e 's|^SLIB_INSTALL_EXTRA_LIB=.*|SLIB_INSTALL_EXTRA_LIB=|' \
  -e 's|^SLIB_INSTALL_EXTRA_SHLIB=.*|SLIB_INSTALL_EXTRA_SHLIB=|' \
  ffbuild/config.mak

echo "==> make (并行 $(sysctl -n hw.ncpu))"
make -j"$(sysctl -n hw.ncpu)" >/dev/null

echo "==> install 到 $INSTALL_PREFIX"
rm -rf "$OUT" "$INSTALL_PREFIX"
mkdir -p "$OUT/libs/arm64-v8a"
make install >/dev/null
cp -R "$INSTALL_PREFIX/include" "$OUT/include"
# 只保留解码链四库。strip 必须用 --strip-unneeded:共享库默认 strip 会把
# .dynsym(动态导出符号)剥掉,链接期全部 undefined(实测踩坑)。
STRIP="$TOOLCHAIN/bin/llvm-strip"
for lib in libavformat libavcodec libswresample libavutil; do
  "$STRIP" --strip-unneeded "$INSTALL_PREFIX/lib/${lib}.so"
  cp "$INSTALL_PREFIX/lib/${lib}.so" "$OUT/libs/arm64-v8a/"
done

# 交付合规:记录工具链与源码版本到 TOOLCHAIN-VERSION.txt。LGPL 源码交付
# 的可复现性三要素 = 源码 commit + 构建脚本 + 工具链版本;索取源码时随附
# 本文件(见 site/music/oss.html「如何获取对象码与源码」)。
{
  echo "# FFmpeg(ohos/arm64, wma) 构建工具链版本记录"
  echo "built-at: $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "ndk:      $NDK"
  echo "compiler: $("$CC" --version | head -n 1)"
  if git -C "$FFMPEG_SRC" rev-parse HEAD >/dev/null 2>&1; then
    echo "ffmpeg:   $(git -C "$FFMPEG_SRC" describe --tags --always --dirty)"
  else
    echo "ffmpeg:   (非 git 检出,以 tag n7.1.1 源码包为准)"
  fi
  echo "script:   scripts/build-ffmpeg-ohos.sh"
} > "$OUT/TOOLCHAIN-VERSION.txt"

# 同步到鸿蒙工程 libs(HAP 打包时按文件名解析 DT_NEEDED)。
APP_LIBS="$REPO_ROOT/apps/jijianyinyue/ohos/entry/libs/arm64-v8a"
mkdir -p "$APP_LIBS"
cp "$OUT/libs/arm64-v8a/"*.so "$APP_LIBS/"
echo "==> 已同步到 apps/jijianyinyue/ohos/entry/libs/arm64-v8a/"

echo "==> 产物:"
ls -lh "$OUT/libs/arm64-v8a/"
echo "✓ FFmpeg(ohos/arm64, wma) 编译完成"
