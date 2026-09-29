# 已收录版本

| 标签（bat/sh / bin / build 目录） | 源码目录 | 说明 |
|-----------------------------------|----------|------|
| `1_1_1w` | `openssl-src/openssl-OpenSSL_1_1_1w` | OpenSSL 1.1.1w |
| `3_0_22` | `openssl-src/openssl-openssl-3.0.22` | OpenSSL 3.0.22 |
| `3_5_8` | `openssl-src/openssl-3.5.8` | OpenSSL 3.5.8 LTS |

入口：

- Windows：`build_<标签>.bat`
- Linux x86_64：`build_<标签>.sh`

产物：

- Windows：`bin/<标签>/`
- Linux：`bin/<标签>/linux-x86_64/`

中间树：

- Windows：`build_debug_<标签>/`、`build_release_<标签>/`
- Linux：`build_linux_debug_<标签>/`、`build_linux_release_<标签>/`

新增版本步骤见 [build.md](build.md)「新增版本」。
