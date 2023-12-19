---
sidebar_position: 2
---
    
# Rust Lint

## 概述

`Lints` 是用于帮助改善代码质量的工具

## 等级

Rustc 的 Lints 分为四个级别：

- 允许/allow

- 警告/warn

- 拒绝/deny

- 禁止/forbid

每一个 lint 都有一个默认级别，并且编译器有一个默认的警告级别。

### 允许/allow

这个 lints 存在，但默认情况下`不执行任何操作`。例如：

```rs
// 尽管代码违反了 missing_docs lint，但不会产生警告。如想开启需通过手动配置。
pub fn foo() {}
```

### 警告/warn

如果你违反了 warn 这种 lint 的级别，将会在编译时产生一些`警告`。例如：

```rs
pub fn foo() {
    let x = 5;
}
```

会产生如下警告：

```sh
warning: unused variable: `x`
 --> lib.rs:2:9
  |
2 |     let x = 5;
  |         ^
  |
  = note: `#[warn(unused_variables)]` on by default
  = note: to avoid this warning, consider using `_x` instead
```

### 拒绝/deny

将会在你违反其规则时产生一个`错误`。例如：

```rs
fn main() {
    100u8 << 10;
}
```

将产生如下错误：

```sh
rustc main.rs
error: bitshift exceeds the type's number of bits
 --> main.rs:2:13
  |
2 |     100u8 << 10;
  |     ^^^^^^^^^^^
  |
  = note: `#[deny(exceeding_bitshifts)]` on by default
```

### 禁止/forbid

`forbid` 是一种特殊的 lint 级别，它比 `deny` 等级更高。 它与 deny 一样会发出一个`错误`，但是与 deny 级别不同的是，forbid 级别`不能被比错误更低的情况覆盖`。然而，lint 仍然被 `--cap-lints` 限制，因此 `rustc --cap-lints warn` 命令将 forbid 级别的 lints 设置为仅有警告信息。

## 配置警告级别

### 通过编译器标志

通过 `-A`(allow)、`-W`(warning)、`-D`(deny)、`-F`(forbid) 标志可以设置一个或多个 lint 的级别。

```rs
rustc lib.rs --crate-type=lib -W missing-docs
warning: missing documentation for crate
 --> lib.rs:1:1
  |
1 | pub fn foo() {}
  | ^^^^^^^^^^^^
  |
  = note: requested on the command line with `-W missing-docs`

warning: missing documentation for a function
 --> lib.rs:1:1
  |
1 | pub fn foo() {}
  | ^^^^^^^^^^^^
```

```rs
rustc lib.rs --crate-type=lib -D missing-docs
error: missing documentation for crate
 --> lib.rs:1:1
  |
1 | pub fn foo() {}
  | ^^^^^^^^^^^^
  |
  = note: requested on the command line with `-D missing-docs`

error: missing documentation for a function
 --> lib.rs:1:1
  |
1 | pub fn foo() {}
  | ^^^^^^^^^^^^

error: aborting due to 2 previous errors
```

也可以传递多个标志：

```sh
rustc lib.rs --crate-type=lib -D missing-docs -D unused-variables
```

当然也可以混用不同标志：

```sh
rustc lib.rs --crate-type=lib -D missing-docs -A unused-variables
```

这些命令行参数是有顺序，后面同名 lint 会覆盖之前的：

```sh
# 最终结果是允许 unused-variables lint
rustc lib.rs --crate-type=lib -D unused-variables -A unused-variables
```

### 通过属性

通过设置一个 `crate-wide` 属性也可以修改 lint 的级别：

文件名：src/lib.rs

```rs
#![warn(missing_docs)]

pub fn foo() {}
```

```rs
#![warn(missing_docs, unused_variables)] // 传递多个 lint

pub fn foo() {}
```

```rs
// 使用多个属性
#![warn(missing_docs)] 
#![deny(unused_variables)]

pub fn foo() {}
```

### Capping lints

`rustc` 支持一个标签，`--cap-lints LEVEL` 用来设置 lint 级别上限。即此设置所有的 lint 的最高级别。

文件名：src/lib.rs

```rs
fn main() {
    100u8 << 10;
}
```

```sh
rustc lib.rs --cap-lints warn
warning: bitshift exceeds the type's number of bits
 --> lib.rs:2:5
  |
2 |     100u8 << 10;
  |     ^^^^^^^^^^^
  |
  = note: `#[warn(exceeding_bitshifts)]` on by default

warning: this expression will panic at run-time
 --> lib.rs:2:5
  |
2 |     100u8 << 10;
  |     ^^^^^^^^^^^ attempt to shift left with overflow
```

现在仅仅只是出现了警告，而不是错误。

在 `Cargo` 中这个特性被使用的很多；它会在我们编译依赖时设置 `--cap-lints allow` 命令，以便在有任何警告信息的时候，不会影响到我们的构建输出。

## 参考资料

[Rust Book - Lints](https://doc.rust-lang.org/rustc/lints/index.html)

[Rustc 手册](https://learnku.com/docs/rustc-book/2020/31-lint-levels/8862)


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at December 6, 2023 16:49</small></div>
      