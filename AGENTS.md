# OpenSSL 构建指南

## 环境依赖

### Windows

- Windows 10+
- Visual Studio 2022/2026（Community 或 Professional）
- 仓库内工具：`tools/strawberry-perl-...`、`tools/nasm-3.01-win64`

### Linux（仅 x86_64）

- x86_64 主机（不支持 aarch64）
- 系统包：`perl`、`make`、`gcc` 或 `clang`、`nasm`
- Debian/Ubuntu 示例：`sudo apt-get install -y build-essential perl nasm`

## 目录结构

```
openssl-src/              OpenSSL 各版本源码
tools/                    Windows 编译工具（Perl、NASM）
build_*_<ver>/            Windows 中间构建目录
build_linux_*_<ver>/      Linux 中间构建目录
bin/<ver>/                Windows 产物（.lib + include）
bin/<ver>/linux-x86_64/   Linux 产物（.a + include）
docs/                     项目知识库
```

**本文件只保留构建、环境约束**，勿再往此处堆属性清单；产品与用法说明放 `docs/`，勿把知识库长文写进本文件。

## 换行符（硬约束，禁止再改）

- **本仓库文本默认 Windows / PC 换行：CRLF（`\r\n`）**。禁止无故改成 LF 或混用。
- **例外：`*.sh` 必须为 LF**（Linux shebang 不能带 `\r`）。根目录 `.editorconfig` / `.gitattributes` 已单独约定，勿改回 CRLF。
- Agent **不得** 因「规范化」等理由把 CRLF/LF 来回改；**只改业务内容，不动换行风格**（`.sh` 保持 LF，其余文本保持 CRLF）。
- 新建或整文件重写：非 `.sh` 必须 **CRLF**；`.sh` 必须 **LF**。
- 若 diff 里只出现换行差异：视为错误，应还原，**禁止单独提交换行变更**。

## 快速编译

### Windows

```bat
build_1_1_1w.bat init release
build_3_0_22.bat init debug
build_3_5_8.bat init release
```

### Linux x86_64

```bash
chmod +x build_*.sh init_tools.sh build_common.sh   # 首次
./build_1_1_1w.sh init release
./build_3_0_22.sh init debug
./build_3_5_8.sh init release
```

- `1` / `2` / `init …`：Configure + **全量编库**
- `3` / `4` / `build …`：**增量**编库（需先初始化过）

无参数则进菜单。完整说明见 [docs/build.md](docs/build.md)。

## 产物约定

Windows：

```
bin/<版本>/libcrypto_mt.lib | libssl_mt.lib      Release /MT
bin/<版本>/libcrypto_mtd.lib | libssl_mtd.lib    Debug /MTd
bin/<版本>/include/
```

Linux x86_64：

```
bin/<版本>/linux-x86_64/libcrypto.a | libssl.a              Release
bin/<版本>/linux-x86_64/libcrypto_debug.a | libssl_debug.a  Debug
bin/<版本>/linux-x86_64/include/
```

下游如何链接见 [docs/usage.md](docs/usage.md)。版本对照见 [docs/versions.md](docs/versions.md)。

## init_env / init_tools

- Windows：`init_env.bat`（vcvarsall x64）、`init_tools.bat`（仓库 Perl/NASM）
- Linux：`init_tools.sh`（检查系统 perl/make/gcc|clang/nasm，且架构为 x86_64）

Windows VS 默认搜索路径：

1. `C:\Program Files\Microsoft Visual Studio\18\Community`
2. `C:\Program Files\Microsoft Visual Studio\2022\Professional`

路径不同时改 `init_env.bat`。

## 编译选项（约束摘要）

- 官方 `perl Configure` + `build_libs`（Windows：`nmake`；Linux：`make`）
- Windows：`VC-WIN64A` / `debug-VC-WIN64A`，`no-shared`，`no-makedepend`，CRT `/MT` `/MTd`
- Linux：`linux-x86_64` / `debug-linux-x86_64`，`no-shared`，`no-makedepend`
- 不执行 `install`
