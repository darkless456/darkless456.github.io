---
sidebar_position: 11
---
    
<small color="#ccc">last modified at 2023/12/7 8:44:3</small>
# Manifest

## profile

```toml
# 此为 开发配置文件, 给 `cargo build` 所使用.
[profile.dev]
opt-level = 0      # 控制编译器构建的`--opt-level`。
                   # 0-1适合调试。 2是良好优化的。最大为 3。
                   # 's' 企图优化大小, 'z' 则 进一步优化大小.
debug = true       # (u32 or bool) 包括调试信息（调试符号）.
                   # 相当于 `-C debuginfo=2` 编译器 标志.
rpath = false      # 控制 编译器 是否应该设置加载器路径.
                   # 若为 true, 传递 `-C rpath` 标志 给 编译器.
lto = false        # 链接时间优化通常会减少二进制文件和静态库的大小
                   # 但会增加编译时间.
                   # 若是 true, 传递 `-C lto` 标志 给 编译器, 和 若是一个
                   # 字符串值 像 'thin' ，那会传递 `-C lto=thin`
                   # 给 编译器
debug-assertions = true # 控制是否启用调试断言
                   # (e.g. debug_assert!() 和 算术溢出检查)
codegen-units = 16 # if > 1 并行代码生成，以改善
                   # 编译时间, 但阻止了些优化.
                   # 传递 `-C codegen-units`.
panic = 'unwind'   # 恐慌策略 (`-C panic=...`), 也可以是 'abort'
incremental = true # 是否启用增量编译
overflow-checks = true # 使用溢出检查进行整数运算。
                   # 传递 `-C overflow-checks=...`标志 给 compiler.

# 发布(release)的配置文件, 用于 `cargo build --release` (和 依赖项的
# `cargo test --release`,  包括本地 library 或 binary).
[profile.release]
opt-level = 3
debug = false
rpath = false
lto = false
debug-assertions = false
codegen-units = 16
panic = 'unwind'
incremental = false
overflow-checks = false

# 测试的配置文件, 用于 `cargo test` (对于 `cargo test --release`，可看
# `release` 和 `bench` 配置文件).
[profile.test]
opt-level = 0
debug = 2
rpath = false
lto = false
debug-assertions = true
codegen-units = 16
panic = 'unwind'
incremental = true
overflow-checks = true

# 基准的配置文件, 用于`cargo bench` (和 要测试的目标 和
# 单元测试的 `cargo test --release`).
[profile.bench]
opt-level = 3
debug = false
rpath = false
lto = false
debug-assertions = false
codegen-units = 16
panic = 'unwind'
incremental = false
overflow-checks = false
```

## features

```toml
[package]
name = "awesome"

[features]
# 默认的可选包集。大多数人都想使用这些
# 包, 但它们是严格可选的。请注意，`session`不是包
# 而是此清单中列出的另一个功能。
default = ["jquery", "uglifier", "session"]

# 没有依赖关系的特性，主要用于条件编译，
# 像 `#[cfg(feature = "go-faster")]`.
go-faster = []

# `secure-password` 特性 需要 bcrypt 包. 这种别名
将允许人们以更高级别的方式讨论该 特性 和 允许
# 此软件包将在未来为该特性添加更多要求.
secure-password = ["bcrypt"]

# 特性可用于重新导出其他包的特性. `awesome`包的 `session`
# 特性将确保 cookie/session 也是可用的
session = ["cookie/session"]

[dependencies]
# 这些包是强制性的，是该软件包发行版的核心。
cookie = "1.2.0"
oauth = "1.1.0"
route-recognizer = "=2.1.0"

# 所以可选依赖项的列表, 其中一些是上面的
# `features`. 它们可以通过应用程序选择加入。
jquery = { version = "1.0.2", optional = true }
uglifier = { version = "1.5.3", optional = true }
bcrypt = { version = "*", optional = true }
civet = { version = "*", optional = true }
```

## workspace

一组 crates 可以定义在一个 workspace，共享相同的 Cargo.lock 和 output 目录。

```toml
[workspace]

# 可选字段，从路径依赖推断（如果不存在）。
# 此处必须给出，包含的其他非路径依赖。
# 特别是, 对于 一个虚拟清单，所有成员都要列出来。
members = ["path/to/member1", "path/to/member2", "path/to/member3/*"]

# 可选字段，忽略某些工作路径
exclude = ["path1", "path/to/dir2"]
```

- workspace 可以包含多个 crates，其中一个是 root crate

- root crate 的 Cargo.toml 包含 [workspace]，但不要求必须有其他配置

- 任何 crate 编译时，输出到 root 目录的 output 目录

- 所有 crates 共享同一个 Cargo.lock 文件

- 对于 Cargo.toml 中的 **`[patch]、[replace]、[profile.*]`**，只有 root 的 Cargo.toml 有效，忽略 member 的配置

> 注：某个 crate 不能同时作为 root crate 和 member

## replace

可以用来重写其他副本的依赖项。语法类似于 [dependencies] 部分:

```toml
[replace]
"foo:0.1.0" = { git = 'https://github.com/example/foo' }
"bar:1.0.2" = { path = 'my/local/bar' }
```

## target

所有的 `[[bin]]`，`[lib]`，`[[bench]]`，`[[test]]` 和 `[[example]]` 部分都支持类似的配置，用于指定应该如何构建目标。双括号 `[[bin]]` 部分，是TOML格式的数组。

```toml
[package]
# ...

[lib]
# 生成目标与库的名称. 本该默认是
# 包名, 替换所有破折号
# 为 下划线. (Rust `extern crate` 声明会参考该名;
# 因此，该值必须是可用的有效Rust标识符.)
name = "foo"

# 该字段，指向 crate 的入口(位置), 路径相对于 `Cargo.toml`.
path = "src/lib.rs"

# 一个给目标启用单元测试 的 标志. 会被 `cargo test`使用.
test = true

# 一个给目标启用文档测试 的 标志. 只与库相关
# , 不会影响其他部分。会被
# `cargo test`使用.
doctest = true

# 一个给目标启用基准 的 标志. 会被 `cargo bench`使用.
bench = true

# 一个给目标启用文档 的 标志. 会被 `cargo doc`使用.
doc = true

# 若该目标为 编译器扩展, 那要把该字段设为 true
# ，以让 Cargo 正确编译和，可用于所有依赖项.
plugin = false

# 若该目标为 "macros 1.1" 程序宏, 那要把该字段设为 true
proc-macro = false

# 若设为 false, `cargo test` 会为 rustc 省略 `--test` 标志, 这
# 阻止它生成测试工具 这在二进制存在，
# 构建管理测试运行器本身的情况下，有用.
harness = true

# 若设置了，那 目标会使用一个与`[package]`配置不同的版本
# , 也许是，编译一个库
2018年版本或，编译单元测试的2015年版本. 默认情况下
# 所有目标都使用`[package]`中指定的版本进行编译。
edition = '2015'
```

      