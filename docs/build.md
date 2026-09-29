# OpenSSL 多版本编译

官方流程：`perl Configure` + `build_libs`。只产出静态库与头文件，**不执行** `install`。

- **Windows**：`nmake build_libs`，入口 `build_<标签>.bat`
- **Linux x86_64**：`make build_libs`，入口 `build_<标签>.sh`（不做 aarch64）

## 环境

### Windows

| 项 | 说明 |
|----|------|
| OS | Windows 10+ |
| VS | 2022 / 2026（Community 或 Professional），x64 |
| 工具 | 仓库内 `tools/strawberry-perl-...`、`tools/nasm-3.01-win64` |
| 脚本 | `init_env.bat`、`init_tools.bat`、`build_common.bat` |

### Linux（仅 x86_64）

| 项 | 说明 |
|----|------|
| 架构 | `uname -m` 必须为 `x86_64` |
| 工具 | 系统 `perl`、`make`、`gcc` 或 `clang`、`nasm` |
| 脚本 | `init_tools.sh`、`build_common.sh`、`build_<标签>.sh` |
| 安装示例 | Debian/Ubuntu：`sudo apt-get install -y build-essential perl nasm` |

## 目录角色

```
openssl-src/<源码目录>/     各版本源码（互不混用）
tools/                      Windows 用 Perl、NASM
build_debug_<标签>/         Windows Debug 中间树
build_release_<标签>/       Windows Release 中间树
build_linux_debug_<标签>/   Linux Debug 中间树
build_linux_release_<标签>/ Linux Release 中间树
bin/<标签>/                 Windows 产物
bin/<标签>/linux-x86_64/    Linux 产物（与 Windows 隔离）
build_<标签>.bat / .sh      该版本入口
build_common.bat / .sh      公共 Configure / 编库 / 收集
```

版本标签与源码目录对照见 [versions.md](versions.md)。

## 编译入口

菜单与参数在 **bat / sh 上相同**。

```bat
build_1_1_1w.bat
build_3_0_22.bat
build_3_5_8.bat
```

```bash
chmod +x build_*.sh init_tools.sh build_common.sh
./build_1_1_1w.sh
./build_3_0_22.sh
./build_3_5_8.sh
```

### 交互菜单（无参数）

| 选项 | 动作 |
|------|------|
| 1 | **初始化** Debug：删旧构建树 → Configure → **全量编库** |
| 2 | **初始化** Release：删旧构建树 → Configure → **全量编库** |
| 3 | **增量**编译 Debug（需先做过 1，不再 Configure） |
| 4 | **增量**编译 Release（需先做过 2，不再 Configure） |
| 0 | 退出 |

### 命令行参数（Agent / 自动化）

无菜单、不 pause；成功 exit `0`，失败非 0。

```bat
build_1_1_1w.bat init release
build_1_1_1w.bat 2
```

```bash
./build_1_1_1w.sh init release
./build_1_1_1w.sh 2
```

| 参数 | 含义 |
|------|------|
| `1` 或 `init debug` | 初始化 Debug（Configure + 全量编库） |
| `2` 或 `init release` | 初始化 Release（Configure + 全量编库） |
| `3` 或 `build debug` | 增量编库 Debug（不再 Configure） |
| `4` 或 `build release` | 增量编库 Release（不再 Configure） |

也支持 `debug init` / `release build` 这种顺序。

## 产物布局

### Windows

```
bin/<标签>/
  libcrypto_mt.lib / libssl_mt.lib      Release，CRT /MT
  libcrypto_mtd.lib / libssl_mtd.lib    Debug，CRT /MTd
  include/
```

### Linux x86_64

```
bin/<标签>/linux-x86_64/
  libcrypto.a / libssl.a                Release
  libcrypto_debug.a / libssl_debug.a    Debug
  include/
```

头文件来源：源码 `include/` 与构建目录生成头合并（如 1.1.1 的 `opensslconf.h`，3.x 的 `configuration.h`）。Windows / Linux 各自一份 include，勿混用。

## Configure 要点

| 平台 | 配置 | 目标 | 额外参数 |
|------|------|------|----------|
| Windows | Release | `VC-WIN64A` | `no-shared` `no-makedepend` `/MT` |
| Windows | Debug | `debug-VC-WIN64A` | `no-shared` `no-makedepend` `/MTd` |
| Linux | Release | `linux-x86_64` | `no-shared` `no-makedepend` |
| Linux | Debug | `debug-linux-x86_64` | `no-shared` `no-makedepend` |

- `no-shared`：只要静态库  
- `no-makedepend`：加快编译  
- Windows：`nmake build_libs`；Linux：`make -j$(nproc) build_libs`  

## 隔离原则

- 不同版本：不同源码目录、不同 `build_*`、不同 `bin/<标签>/`
- Windows / Linux：中间目录与产物目录均分离（Linux 用 `build_linux_*` 与 `bin/*/linux-x86_64/`）
- Debug / Release：不同构建树

## 新增版本

1. 源码放到 `openssl-src/<目录名>/`
2. 复制 `build_1_1_1w.bat` 与 `build_1_1_1w.sh`，改 `VER`、`SRC_DIR`
3. 在 [versions.md](versions.md) 补一行对照
4. Windows：`build_<标签>.bat init release`；Linux：`./build_<标签>.sh init release`

## 常见现象

- **Agent 后台跑脚本时日志约 1MB 后不再刷新**：进程可能仍在编译，用产物目录时间戳判断进度。
- **增量编译报未配置**：先执行菜单 1/2 或 `init debug|release`。
- **Linux 报 shebang 错误**：确认 `*.sh` 为 LF 换行（见 `AGENTS.md` 换行例外）。
