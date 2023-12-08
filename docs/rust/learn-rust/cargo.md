---
sidebar_position: 2
---
    
<small style={{color: '#cccccc'}}>last modified at 2023/12/8 6:32:31</small>
# Cargo Tool

## 概述

`Cargo` 是一个工具,允许 Rust 项目声明其各种依赖项，并确保您始终获得可重复的构建。

为了实现这一目标, Cargo 做了四件事：

- 引入两个元数据文件，包含各种项目信息。

- 获取和构建程序包的依赖项。

- 调用 rustc 或其他具有正确参数的工具，构建程序包。

- 引入 Rust 项目的约定（规范/风格）。

## 安装

获得 Cargo 的最简单方法是使用 rustup 脚本，参考[如何安装 rust](setup.md)。

或者，可以从源代码开始[构建 Cargo](https://github.com/rust-lang/cargo#compiling-from-source)。

## 设置国内源

为了加快 cargo 的下载速度，避免网速慢或者被墙。可通过添加国内源头 USTC 解决。

修改 `$HOME/.cargo/config` 或者 `C:\Users\Administrator\.cargo\config` 加入以下内容：

```toml
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'ustc'

# 中国科学技术大学
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# rustcc社区
[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"

[http]
check-revoke = false
```

添加 `check-revoke = false` 是为了解决下面的问题：

```sh
warning: spurious network error (2 tries remaining): [6] Couldn't resolve host name (Could not resolve host: crates-io.proxy.ustclug.org)
warning: spurious network error (1 tries remaining): [6] Couldn't resolve host name (Could not resolve host: crates-io.proxy.ustclug.org)
error: failed to download from `https://crates-io.proxy.ustclug.org/api/v1/crates/serde_test/1.0.126/download`

Caused by:
  [6] Couldn't resolve host name (Could not resolve host: crates-io.proxy.ustclug.org)
```

或者在项目工程结构中，与 Cargo.toml 同级目录的 .cargo 文件夹下创建 config 文件，config 文件配置方法和内容与第一种相同。

更多国内源使用帮助，可参考 [USTC 的文档](http://mirrors.ustc.edu.cn/help/crates.io-index.html)

## 设置网络代理

修改文件 `~/.cargo/config`

HTTP 代理

```toml
[http]
proxy = "127.0.0.1:1081"
[https]
proxy = "127.0.0.1:1081"
```

Socks5 代理

```toml
[http]
proxy = "socks5://127.0.0.1:1080"
[https]
proxy = "socks5://127.0.0.1:1080"

```

## 创建一个新包

使用 `cargo new` 创建一个新的程序包

```sh
$ cargo new project_hello --bin // 创建二进制程序包

$ cargo new project_hello --lib // 创建库

```

默认会初始化一个 git 仓库。如果不希望这么做，可以加上 `--vcs none`

让我们看看Cargo为我们生成了什么：

```sh
$ cd project_hello
$ tree .
.
├── Cargo.toml
└── src
    └── main.rs

1 directory, 2 files
```

打开 `Cargo.toml` 文件，它包含了 Cargo 编译包时需要的元数据

```toml
[package]
name = "project_hello"
version = "0.1.0"
edition = "2018"

[dependencies]
```

`src/main.rs` 的内容如下：

```rs
fn main() {
    println! ("Hello, world!");
}
```

编译下整个程序

```sh
$ cargo build
Compiling project_hello v0.1.0 (D:\www\test\rust\project_hello)
    Finished dev [unoptimized + debuginfo] target(s) in 1.99s

```

运行下程序

```sh
$ cargo run
Finished dev [unoptimized + debuginfo] target(s) in 0.01s
     Running `target\debug\project_hello.exe`
Hello, world!
```

我们也可以直接使用 `cargo run`，会自行编译，然后运行。

此时会创建几个新文件和目录

```cmd
│  .gitignore
│  Cargo.lock // 包含我们的依赖项的有关信息（即便还没有依赖）
│  Cargo.toml
│
├─src
│      main.rs
│
└─target // 包含所有构建产品（二进制文件..）
    │  .rustc_info.json
    │  CACHEDIR.TAG
    │
    └─debug // 默认生成调试（debug）版本
        │  .cargo-lock
        │  project_hello.d
        │  project_hello.exe
        │
        ├─.fingerprint
        │  └─project_hello-62a87b349c701d30
        │          bin-project_hello
        │          bin-project_hello.json
        │          dep-bin-project_hello
        │          invoked.timestamp
        │
        ├─build
        ├─deps
        │      project_hello-62a87b349c701d30.d
        │      project_hello-62a87b349c701d30.exe
        │
        ├─examples
        └─incremental
            └─project_hello-2mvaeoymu67q8
                │  s-g54c3hmgac-kwrnn.lock
                │
                └─s-g54c3hmgac-kwrnn-k07365nrj5pt
                        2xhs0bkurczhjb6v.o
                        3k96ipehroo0nwml.o
                        46wyljjgpg44myyb.o
                        4azbvbksxthc5wh.o
                        4q2f2hot91w4db7o.o
                        4waetlv8y3u0muus.o
                        50kuitqlb1ggk95h.o
                        dep-graph.bin
                        g54tnvoxe9ghrcn.o
                        query-cache.bin
                        work-products.bin
```

可以使用 `cargo build --release`，这会在开启优化的情况下，编译文件：

```sh
$ cargo build --release
   Compiling project_hello v0.1.0 (D:\www\test\rust\project_hello)
    Finished release [optimized] target(s) in 0.44s
```

调试模式的编译是开发的默认设置 - 编译时间较短，因为编译器不进行优化，但代码运行速度较慢。发布（release）模式编译需要更长时间，但代码运行速度更快。

## 在现有的 Cargo 包上工作

首先，从某处获取该包。在这个例子中，我们将使用从GitHub上的存储库中克隆的rand：

```sh
$ git clone https://github.com/rust-lang-nursery/rand.git
$ cd rand
```

然后使用 `cargo build` 构建即可。这将获取所有的依赖项，然后与程序包一起构建。

      