# 极简系列 · 开源合规交付仓库(LGPL 源码与对象码)

本仓库是「极简音乐」(及后续「极简视频」)LGPL-2.1 合规交付的公开渠道,
提供应用各发布版本所链接 LGPL 库的**完整对应源码、构建脚本与对象码**。
任何第三方均可自由获取与再分发(遵循各组件原始许可证),无需邮件申请。

## 仓库结构

| 目录 | 内容 |
|------|------|
| `source/` | LGPL 库对应源码快照(FFmpeg n7.1.1、libsmb2 6.1) |
| `build/` | 构建脚本与配置(鸿蒙交叉编译脚本、工具链版本记录、预编译件上游出处清单) |
| `patches/` | 宽松许可证组件的本地补丁源码(smb_connect / flutter_secure_storage / audio_service) |
| `releases/<tag>/` | 各应用版本实际分发的 LGPL 库对象码(.so / .xcframework / .jar)及 SHA256SUMS |

## 版本对照索引

| 发布标签 | 应用版本 | 说明 |
|----------|----------|------|
| `music-v0.0.6+8` | 极简音乐 0.0.6(build 8) | 2026-08-17 同步 |
| `music-v0.0.7+9` | 极简音乐 0.0.7(build 9) | 2026-08-17 同步 |
| `music-v1.0.0+10` | 极简音乐 1.0.0(build 10) | 2026-08-24 同步 |
| `music-v1.0.1+11` | 极简音乐 1.0.1(build 11) | 2026-08-25 同步 |
| `music-v1.0.2+12` | 极简音乐 1.0.2(build 12) | 2026-08-26 同步 |
| `music-v1.0.2+13` | 极简音乐 1.0.2(build 13) | 2026-08-26 同步 |
| `music-v1.0.2+14` | 声坞 1.0.2(build 14) | 2026-08-30 同步 |
| `music-v1.0.3+15` | 声坞 1.0.3(build 15) | 2026-08-30 同步 |
| `music-v1.0.5+17` | 声坞 1.0.5(build 17) | 2026-09-02 同步 |
| `music-v1.0.6+18` | 声坞 1.0.6(build 18) | 2026-09-02 同步 |
| `music-v1.0.7+19` | 声坞 1.0.7(build 19) | 2026-09-02 同步 |
| `music-v1.0.8+20` | 声坞 1.0.8(build 20) | 2026-09-02 同步 |
| `music-v1.0.9+21` | 声坞 1.0.9(build 21) | 2026-09-02 同步 |
<!-- SYNC-TABLE-ROWS -->

每次应用发版,以 `bash scripts/sync-oss-repo.sh` 同步本仓库并打对应标签,
保证索取者能取到与其手中二进制**精确对应**的源码与对象码。

## 对应关系说明

- **鸿蒙端 FFmpeg**:`source/` 下的 FFmpeg n7.1.1 源码归档为实际构建所用,
  配套 `build/build-ffmpeg-ohos.sh`(交叉编译脚本)与 `build/TOOLCHAIN-VERSION.txt`
  (工具链版本记录),三者合用可复现 `releases/<tag>/ohos/` 下的四个 .so。
- **安卓 / iOS 真机端 libmpv(内含 FFmpeg)**:经 media_kit 预编译发行件引入
  (安卓构建期经 gradle 从上游 release 下载,iOS 经 xcframework 打包),上游构建
  仓库与二进制出处(含 md5 锁定)见 `build/prebuilts-manifest.md`;对象码见
  `releases/<tag>/android/` 与 `releases/<tag>/ios/`。
- **libsmb2**:安卓 / iOS 预编译件经 dart_smb2 打包,源码为
  `source/libsmb2-6.1.tar.gz`(上游 release 6.1,对应 dart_smb2 标注的 v6.1.0)。

## 许可证

- `source/`、`releases/` 内的 FFmpeg / libmpv / libsmb2 源码与二进制分别遵循其
  原始许可证(**LGPL-2.1**),原样保留上游 LICENSE / COPYING 文件,再分发同样适用。
- `build/`、`patches/` 中本项目自有的脚本与补丁不附加任何额外限制,随原组件
  许可证条款再分发。
- 本仓库**不包含**极简音乐 / 极简视频的应用业务代码(UI、业务逻辑等自有代码)。
  LGPL 动态链接场景下这些内容不在交付义务范围内,亦属开发者保留权利的部分。

完整开源声明(LGPL 权利说明、组件清单与平台差异)随应用安装包内置,
见应用内「关于 → 开源声明」。
