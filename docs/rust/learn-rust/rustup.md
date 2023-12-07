---
sidebar_position: 3
---
    
<small color="#ccc">last modified at 2023/12/7 8:44:3</small>
# Rustup

## 概述

`rustup` 是一个工具链复用器 (toolchain multiplexer)。它安装和管理许多 Rust 工具链，并通过一套安装在 `~/.cargo/bin` 的工具来展示它们。安装在 `~/.cargo/bin` 中的 `rustc` 和 `cargo` 可执行文件是委托给真正的工具链的代理。

因此，当 rustup 第一次安装时，运行 rustc 会运行 $HOME/.cargo/bin/rustc 中的代理，而它又会运行稳定的编译器。如果你后来用 rustup default nightly 把默认的工具链改成了 nightly，那么同样的代理将运行 nightly 编译器。

这与 Ruby 的 rbenv、Python 的 yenv 或 Node 的 nvm 类似。

## 概念

一些基本术语：

- channel - Rust 被发布到三个不同的"频道"：stable, beta, 和 nightly。

- toolchain - “工具链” 是 Rust 编译器（rustc）和相关工具（如 cargo）的完整安装。一个工具链的规范包括发布渠道或版本，以及工具链运行的主机平台。

- target - rustc 能够为许多平台生成代码。"target" 指定了代码将被生成的平台。默认情况下，cargo 和 rustc 使用主机工具链的平台作为目标。要为不同的目标平台进行编译，通常需要先通过 rustup target 命令安装目标平台的标准库。

- component - 每个Rust版本都包括几个"组件"，其中一些是必须的（比如 rustc），一些是可选的（比如 clippy）。

- profile - 为了使组件的工作更容易，profile 定义了组件的分组。

### channel

Rust 被发布到三个不同的"频道"：stable, beta 和 nightly。稳定版每6周发布一次（偶尔会有点状发布）。测试版是将出现在下一个稳定版中的版本。nightly 发布是每晚进行的。rustup 协助安装不同的通道，保持它们的最新状态，并在它们之间轻松切换。

在安装了一个发布通道后，可以用 rustup 将安装的版本更新到该通道的最新版本。

rustup 也可以安装特定版本的Rust，比如 1.45.2 或 nightly-2020-07-27。

### toolchain

rustup 的许多命令都涉及到工具链，工具链即 Rust 编译器的单一安装。最基本的是跟踪官方发布渠道：stable、beta和nightly；但 rustup 也可以从官方档案中安装工具链，用于替代的主机平台，以及从本地构建中安装。

```sh
$ rustup toolchain install stable-x86_64-pc-windows-msvc
# 等价于
$ rustup toolchain install stable-msvc
```

### component

每个工具链都有几个"组件"，其中一些是必须的（比如 rustc），一些是可选的（比如 clippy）。rustup component 命令是用来管理已安装的组件的。例如，运行 rustup component list 可以看到可用和已安装的组件的列表。

安装工具链时添加组件。

```sh
rustup toolchain install nightly --component rust-docs
```

通过命令添加组件到当前工具链中。

```sh
rustup component add rust-docs
```

对不同组件的概述：

- rustc - Rust编译器。

- cargo - Cargo是一个软件包管理器和构建工具。

- rustfmt - Rustfmt是一个用于自动格式化代码的工具。

- rust-std - 这是Rust的标准库。rustc支持的每个目标都有一个单独的rust-std组件，例如rust-std-x86_64-pc-windows-msvc。

- rust-docs - 这是一个Rust文档的本地副本。使用 rustup doc 命令可以在网络浏览器中打开文档。

- rls - RLS是一个语言服务器，提供对编辑器和IDE的支持。

- clippy - Clippy是一个lint工具，为常见的错误和风格选择提供额外的检查。

- miri - Miri是一个实验性的Rust解释器，它可以用来检查未定义行为。

- rust-src - 这是一个Rust标准库源代码的本地拷贝。它可以被一些工具使用，比如RLS，为标准库中的函数提供自动补全；Miri是一个Rust解释器；以及Cargo的实验性build-std功能，它允许你在本地重建标准库。

- rust-analysis - 关于标准库的元数据，由RLS等工具使用。

- rust-mingw - 这包含了一个链接器和平台库，用于在x86_64-pc-windows-gnu平台上构建。

- llvm-tools-preview - 这是一个实验性组件，包含LLVM工具的集合。

- rustc-dev - 这个组件包含作为库的编译器。大多数用户不需要这个；只有在开发链接到编译器的工具时才需要它，例如对Clippy进行修改。

### profile

rustup 有一个 "配置文件" 的概念。它们是在安装新的 Rust 工具链时可以选择下载的组件组。目前可用的配置文件有minimal, default 和 complete:

minimal: 最小的配置文件包括尽可能少的组件，以获得一个可工作的编译器（rustc、rust-std 和 cargo）。如果你不使用本地文档，建议在 Windows 系统上使用这个组件（大量的文件可能会对一些反病毒系统造成问题），并在 CI 中使用。

default: 默认配置文件包括最小配置文件中的所有组件，并增加了 rust-docs、rustfmt 和 clippy。rustup 默认使用这个配置文件，它是推荐用于一般用途的配置文件。

complete: 完整的配置文件包括所有通过 rustup 可用的组件。千万不要使用这个，因为它包括了元数据中曾经包含的所有组件，因此几乎总是会失败。如果你正在寻找一种方法来安装 devtools，如 miri 或 IDE 集成工具（rls），你应该使用默认的配置文件，并手动安装所需的额外组件，可以使用 rustup component add 或在安装工具链时使用 -c。

设置配置文件

```sh
rustup set profile minimal
```

### proxy

rustup 为常见的 Rust 工具提供了一些包装器。这些被称为代理，代表了由各种组件提供的命令。

代理列表目前在rustup中是静态的，如下所示。

- rustc 是 Rust 编程语言的编译器，由项目本身提供，来自 rustc 组件。

- rustdoc 是发布在 rustc 组件中的工具，帮助你为 Rust 项目生成文档。

- cargo 是 Rust 包管理器，它下载 Rust 包的依赖项，编译你的包，制作可分发的包，并将它们上传到 crates.io（Rust 社区的包注册中心）。它来自 cargo 组件。

- rust-lldb 和 rust-gdb 分别是 lldb 和 gdb 调试器的简单包装器。这些包装器可以实现一些 Rust 值的格式化打印，并通过其脚本接口为调试器添加一些便利的功能。

- rls 是 Rust IDE 整合工具的一部分。它实现了语言服务器协议，允许 IDE 和编辑器，如 Visual Studio Code、ViM 或 Emacs，访问你正在编辑的 Rust 代码的语义。它来自 rls 组件。

- cargo-clippy 和 clippy-driver 与 clippy linting 工具有关，它为常见的错误和风格选择提供额外的检查，它来自 clippy 组件。

- cargo-miri 是 Rust 的中级中间表示法（MIR）的实验性解释器，来自 miri 组件。

## 交叉编译

TBC

## 一些示例

| Command | Description |
| -- | -- |
|rustup default nightly|Set the default toolchain to the latest nightly|
|rustup set profile minimal|Set the default profile|
|rustup target list|List all available targets for the active toolchain|
|rustup target add arm-linux-androideabi|Install the Android target|
|rustup target remove arm-linux-androideabi|Remove the Android target|
|rustup run nightly rustc foo.rs|Run the nightly regardless of the active toolchain|
|rustc +nightly foo.rs|Shorthand way to run a nightly compiler|
|rustup run nightly bash|Run a shell configured for the nightly compiler|
|rustup default stable-msvc|On Windows, use the MSVC toolchain instead of GNU|
|rustup override set nightly-2015-04-01|For the current directory, use a nightly from a specific date|
|rustup toolchain link my-toolchain "C:\RustInstallation"|Install a custom toolchain by symlinking an existing installation|
|rustup show|Show which toolchain will be used in the current directory|
|rustup toolchain uninstall nightly|Uninstall a given toolchain|
|rustup toolchain help|Show the help page for a subcommand (like toolchain)|
|rustup man cargo|(Unix only) View the man page for a given command (like cargo)|

## 参考资料

[The Rustup Book](https://rust-lang.github.io/rustup/index.html)

      