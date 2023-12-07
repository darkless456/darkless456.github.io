---
sidebar_position: 5
---
    
# Dependencies

- Cargo.toml 描述依赖信息，由开发者编写。

- Cargo.lock 描述当前使用依赖的详细信息，由 Cargo 维护，一般不需要手动编辑。
  - `cargo update` 更新全部依赖
  - `cargo update -p uuid` 更新指定依赖

## 从 crates.io 添加依赖项

`crates.io` 是 Rust 社区的中央存储库，用作发现和下载包的位置。cargo 默认配置为使用它来查找请求的包。

### 添加依赖项

在 Cargo.toml 文件增加 `[dependencies]`项，并添加所需的 crate：

```toml
[dependencies]

time = "0.1.12"
regex = "0.1.41"
```

版本字符串是 [`semver`](https://github.com/dtolnay/semver#requirements) 版本要求。

重新运行 `cargo build`， Cargo 将获取新的依赖项及其所有依赖项，将它们全部编译，最后更新 `Cargo.lock`

```sh
$ cargo build
      Updating registry `https://github.com/rust-lang/crates.io-index`
   Downloading memchr v0.1.5
   Downloading libc v0.1.10
   Downloading regex-syntax v0.2.1
   Downloading memchr v0.1.5
   Downloading aho-corasick v0.3.0
   Downloading regex v0.1.41
     Compiling memchr v0.1.5
     Compiling libc v0.1.10
     Compiling regex-syntax v0.2.1
     Compiling memchr v0.1.5
     Compiling aho-corasick v0.3.0
     Compiling regex v0.1.41
     Compiling hello_world v0.1.0 (file:///path/to/project/hello_world)
```

`Cargo.lock` 文件包含有我们当前所使用依赖项的具体信息。

如果依赖的中某个 crate 更新了，我们仍会使用现有版本进行构建。

如果想要升级 crate 的版本，使用 `cargo update` 进行更新。

### 使用外部依赖

在 `main.rs` 中使用刚刚添加的 regex 依赖

```rs
extern crate regex;

use regex::Regex;

fn main() {
    let re = Regex::new(r"^\d{4}-\d{2}-\d{2}$").unwrap();
    println!("Did our date match? {}", re.is_match("2014-01-01"));
}
```

运行 `cargo run` 可以查看程序的运行结果。

## 指定依赖项

外部的 crate 可以依赖多个来源的库，如 crates.io、git 的存储库或本地文件系统上的子目录。您还可以临时覆盖依赖项的位置 - 例如，便于能够测试您在本地工作的依赖项中的错误修复。您可以为不同的平台或仅在开发期间，使用不同的依赖项。我们来看看如何做到这些。

### 指定依赖，来自 crates.io

默认情况下，Cargo 在 crates.io 上查找依赖项。在这种情况下，只需要名称和版本字符串。

```toml
[dependencies]
time = "0.1.12"
```

**跳脱条件**允许 SemVer 兼容更新指定版本。
例子：

```text
^1.2.3 := >=1.2.3 <2.0.0
^1.2 := >=1.2.0 <2.0.0
^1 := >=1.0.0 <2.0.0
^0.2.3 := >=0.2.3 <0.3.0
^0.2 := >= 0.2.0 < 0.3.0
^0.0.3 := >=0.0.3 <0.0.4
^0.0 := >=0.0.0 <0.1.0
^0 := >=0.0.0 <1.0.0
```

在 `1.0.0` 之前版本，SemVer 认为没有兼容性问题，但 Cargo 认为 `0.x.y` 是兼容 `0.x.z`，这里 `y >= z` 和 `X > 0`。

**Tilde 条件**指定具有更新最小版本的一定能力。如果指定 major 版本，minor 版本和 patch 程序版本，或仅指定 major 版本和 minor 版本，则仅允许 patch 程序级别更改。如果仅指定 major 版本，则允许进行 minor 和 patch 级别更改。
例子：

```text
~1.2.3 := >=1.2.3 <1.3.0
~1.2 := >=1.2.0 <1.3.0
~1 := >=1.0.0 <2.0.0
```

**通配符条件**允许任何通配符所在的版本。
例子

```text
* := >=0.0.0
1.* := >=1.0.0 <2.0.0
1.2.* := >=1.2.0 <1.3.0
```

**范围条件**允许手动指定要依赖的版本范围或确切版本。
例子

```text
>= 1.2.0
> 1
< 2
= 1.2.3
```

多个版本，要求用逗号分隔，例如 `>= 1.2， < 1.5`。

### 指定依赖，来自 git

依赖于位于 `git repo`的库，您需要指定的最小信息，为一个 `git` 字段，值为 `repo` 位置：

```toml
[dependencies]
rand = { git = "https://github.com/rust-lang-nursery/rand" }
```

Cargo 将向 git repo 请求 Cargo.toml。默认是 master 分支，也可以指定分支。

```toml
[dependencies]
rand = { git = "https://github.com/rust-lang-nursery/rand", branch = "develop" }
```

### 指定依赖，本地路径

我们也可以指定本地路径的依赖。

```sh
# inside of hello_world/
$ cargo new hello_utils
```

```toml
[dependencies]
hello_utils = { path = "hello_utils" }
```

Cargo 将在 `hello_utils` 文件夹下（相对路径）寻找 Cargo.toml。

> 注：crates.io 不允许仅使用指定路径依赖项的 crate。如果我们想要发布，需要指定其版本。

```toml
[dependencies]
hello_utils = { path = "hello_utils", version = "0.1.0" }
```

## 依赖 patch

### 指定 features

```toml
[dependencies.awesome]
version = "1.3.5"
default-features = false # 不会包括默认特性
features = ["secure-password", "civet"]
```

或者

```toml
[dependencies]
awesome = { version = "1.3.5", default-features = false, features = ["secure-password", "civet"] }
```

### 版本覆盖

```toml
[package]
name = "my-library"
version = "0.1.0"
authors = ["..."]

[dependencies]
uuid = "1.0"
```

假如你要修复 `uuid` 中的一个bug。首先要 clone uuid 的 repo 到本地。

```sh
$ git clone https://github.com/rust-lang-nursery/uuid
```

接下来编辑 Cargo.toml，增加如下：

```toml
[patch.crate-io] # 修补来源为 crates-io，可以为 git，如：[path."https://github.com/your/repository"]
uuid = { path = "../path/to/uuid" } # 本地 uuid 所在路径
```

以后在符合版本约束条件的情况下，每当向 crates.io 查询 uuid 版本时，会返回本地的版本。

在 dependencies 中声明的 uuid 版本 是 `>= 1.0.0, < 2.0.0` 时才适用

如 git 上已有更新的 1.0.1 版本，但未发布。可以更新：

```toml
[package]
name = "my-library"
version = "0.1.0"
authors = ["..."]

[dependencies]
uuid = "1.0.1" # 未来在 crates.io 上会发布的版本

[patch.crates-io]
uuid = { git = 'https://github.com/rust-lang-nursery/uuid' } # 本地正在使用的版本
```

### 指定 target

针对特定平台指定依赖

```toml
# cfg 语法方式，Cargo > 0.9.0(rust 1.8.0)

[target.'cfg(windows)'.dependencies]
winhttp = "0.4.0"

[target.'cfg(unix)'.dependencies]
openssl = "1.0.1"

[target.'cfg(target_arch = "x86")'.dependencies]
native = { path = "native/i686" }

[target.'cfg(target_arch = "x86_64")'.dependencies]
native = { path = "native/x86_64" }


# 针对特定 target 方式

[target.x86_64-pc-windows-gnu.dependencies]
winhttp = "0.4.0"

[target.i686-unknown-linux-gnu.dependencies]
openssl = "1.0.1"

[target."x86_64/windows.json".dependencies]
winhttp = "0.4.0"


# 使用自定义目标规范，引用路径和文件名

[target."i686/linux.json".dependencies]
openssl = "1.0.1"
native = { path = "native/i686" }

[target."x86_64/linux.json".dependencies]
openssl = "1.0.1"
native = { path = "native/x86_64" }

```

### Dev 和 Build 依赖

```toml
# dev 依赖，编译是不会使用，但用于测试，示例和基准
[dev-dependencies]
tempdir = "0.3"


# 针对特定 target 的 dev 依赖
[target.'cfg(unix)'.dev-dependencies]
mio = "0.0.1"


#  构建依赖
[build-dependencies]
cc = "1.0.3"

```

### 依赖重命名

假设有名字为 test 的 crate，在 crates.io、git、local 都存在，并都需要使用。为避免混淆可以对它们重命名。

```toml
[package]
name = "mypackage"
version = "0.0.1"

[dependencies]
test = "0.1"
bar = { git = "https://github.com/example/project", package = "test" }
baz = { version = "0.1", registry = "custom", package = "test" }
```

`package` 为真实 crate 的名字，如不指定，默认使用依赖项名称。

      