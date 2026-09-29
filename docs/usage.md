# OpenSSL 静态库使用说明

面向下游工程（如游戏服、工具）链接本仓库产物。

## 选版本与平台

按工程需要选定标签（见 [versions.md](versions.md)），并选用对应平台产物目录：

| 平台 | 根目录 |
|------|--------|
| Windows | `bin/<标签>/` |
| Linux x86_64 | `bin/<标签>/linux-x86_64/` |

**不要**在同一进程内混链两个 OpenSSL 大版本；头文件与库必须同一平台目录。也不要混用 Windows `.lib` 与 Linux `.a`。

## 头文件

```
Windows:      <本仓库>/bin/<标签>/include
Linux x86_64: <本仓库>/bin/<标签>/linux-x86_64/include
```

```cpp
#include <openssl/ssl.h>
#include <openssl/err.h>
```

1.1.1 依赖生成头 `openssl/opensslconf.h`；3.x 另有 `openssl/configuration.h`。已收集进上述 `include/`，勿再指向 `openssl-src`。

## Windows 库文件

| 工程 CRT | 链接库 |
|----------|--------|
| `/MT`（Release 静态 CRT） | `libssl_mt.lib`、`libcrypto_mt.lib` |
| `/MTd`（Debug 静态 CRT） | `libssl_mtd.lib`、`libcrypto_mtd.lib` |

链接顺序：先 `libssl_*`，再 `libcrypto_*`。  
系统库（典型）：`ws2_32.lib`、`crypt32.lib`、`advapi32.lib`、`user32.lib`、`gdi32.lib`。

CRT 必须与 `_mt` / `_mtd` 一致。

### MSVC 示例

```bat
cl /EHsc /MT /I G:\GameServer\OpenSSL\trunk\bin\1_1_1w\include demo.cpp /link /LIBPATH:G:\GameServer\OpenSSL\trunk\bin\1_1_1w libssl_mt.lib libcrypto_mt.lib ws2_32.lib crypt32.lib advapi32.lib user32.lib
```

### CMake（Windows 示意）

```cmake
set(OPENSSL_ROOT "G:/GameServer/OpenSSL/trunk/bin/1_1_1w")
target_include_directories(myapp PRIVATE "${OPENSSL_ROOT}/include")
target_link_libraries(myapp PRIVATE
  "${OPENSSL_ROOT}/libssl_mt.lib"
  "${OPENSSL_ROOT}/libcrypto_mt.lib"
  ws2_32 crypt32 advapi32 user32)
```

## Linux x86_64 库文件

| 配置 | 链接库 |
|------|--------|
| Release | `libssl.a`、`libcrypto.a` |
| Debug | `libssl_debug.a`、`libcrypto_debug.a` |

链接顺序：先 `ssl`，再 `crypto`。  
系统库（典型）：`-lpthread -ldl -lm`（按发行版/用法再补）。

### gcc 示例

```bash
g++ -O2 -I/path/to/OpenSSL/trunk/bin/1_1_1w/linux-x86_64/include demo.cpp \
  -L/path/to/OpenSSL/trunk/bin/1_1_1w/linux-x86_64 \
  -lssl -lcrypto -lpthread -ldl -lm
```

若库名为 `libssl_debug.a`，可写 `-lssl_debug -lcrypto_debug`，或直接写完整路径：

```bash
g++ ... bin/1_1_1w/linux-x86_64/libssl_debug.a bin/1_1_1w/linux-x86_64/libcrypto_debug.a -lpthread -ldl -lm
```

### CMake（Linux 示意）

```cmake
set(OPENSSL_ROOT "/path/to/OpenSSL/trunk/bin/1_1_1w/linux-x86_64")
target_include_directories(myapp PRIVATE "${OPENSSL_ROOT}/include")
target_link_libraries(myapp PRIVATE
  "${OPENSSL_ROOT}/libssl.a"
  "${OPENSSL_ROOT}/libcrypto.a"
  pthread dl m)
```

## 初始化（运行时）

1.1.1 常见：

```cpp
SSL_library_init();
SSL_load_error_strings();
OpenSSL_add_all_algorithms();
```

3.x 多数场景由库自动初始化；错误信息仍可用 `ERR_print_errors_fp` / `ERR_get_error`。具体 API 以对应版本头文件与官方文档为准。

## 与编译文档的关系

如何产出产物见 [build.md](build.md)。改编译选项或脚本时先改构建文档与 `AGENTS.md`，再更新本文链接约定。
