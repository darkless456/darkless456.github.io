---
sidebar_position: 12
---
    
<small style="color: #ccc;">last modified at 2023/12/7 8:54:31</small>
# Install Rust

## 在线使用 Rust

在线测试 Rust 代码，不用安装本地环境

[在线 Rust](https://play.rust-lang.org/)

## Linux & Mac 安装

执行以下命令

```sh
$ curl https://sh.rustup.rs -sSf | sh
```

### 配置 Cargo 国内源

打开（或创建）文件 ~/.cargo/config，加入以下内容：

```text
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'ustc'

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"
```

## Windows 安装

在安装 Rust 之前，Windows 平台上需要先安装 `Microsoft C++ build tools` 或者 `MinGW-w64` 的 GCC。
如果不安装，后面编译会出错。

打开下面的网站：

[Visual C++ Build Tools](https://visualstudio.microsoft.com/zh-hans/visual-cpp-build-tools/)

选择"Download Visual C++ Build Tools 2015"。

或者

[MinGW-w64](https://www.mingw-w64.org/downloads/)

选择对应版本下载

下载之后按照提示一路安装即可。

## Rust 已安装版本

```sh
$ rustc --version
rustc 1.57.0 (f1edd0429 2021-11-29)
```

## 版本更新

### 升级

用过 `rustup` 安装 Rust 之后，运行以下命令可以升级版本

```sh
$ rustup update
```

### 切换至 nightly 版本

```sh
$ rustup default nightly
```

切回至 stable 版本

```sh
$ rustup default stable
```

      