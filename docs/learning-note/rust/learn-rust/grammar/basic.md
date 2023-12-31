---
sidebar_position: 1
---
    
# Rust 的基本语法

## 变量

Rust 中的变量比较特殊，分为两种类型：不可变变量和可变变量。

### 不可变变量

Rust 的变量默认时不可变的（immutable），这是 Rust 为更安全和更适合并发性的代码提供的特性。

let 关键字用于定义变量，默认定义的是不可变变量：

```rs
fn main() {
    // 可以通过类型推导得到变量类型，因此可以不指定变量类型
    let a = 1;
    // 也可以明确指定变量类型
    let b: bool = true;

    // 当多种类型可能性时，须明确类型注解
    let guess: u32 = "42".parse().expect("Not a number!");
}
```

Rust 编译器保证，如果声明一个值不会变，它就真的不会变。这意味着当阅读和编写代码时，不需要追踪一个值如何和在哪可能会被改变，从而使得代码易于推导。

### 可变变量

在变量名前加 `mut` 关键字，将变为可变变量。

```rs
fn main() {
    let mut x = 5;
    println!("The value of x is: {}", x);
    x = 6; // 报错
    println!("The value of x is: {}", x);
}
```

### shadow

可以定义一个与之前变量同名的新变量，新变量会 shadowing 之前的变量。

```rs
fn main() {
    let x = 5;

    let x = x + 1;

    let x = x * 2;

    println!("The value of x is: {}", x);
}
```

关于如何使用不可变/可变的变量，以下建议可做参考：

- 使用大型数据结构时，适当地使用可变变量，可能比复制和返回新分配的实例更快。

- 对于较小的数据结构，总是创建新实例，采用更偏向函数式的编程风格，可能会使代码更易理解，为可读性而牺牲性能或许是值得的。

## 语句

语句是指要执行的一些操作和产生副作用的表达式。

分为两种：

- 声明语句

用于`声明`各种`语言项`，包括声明变量，静态变量，常量，结构体，函数等，以及通过 extern 和 use 关键字引入包和模块等。

- 表达式语句

特指以`分号`结束的`表达式`。此类表达式求值结果将会被`舍弃`，并总是返回单元类型`()`。

## 表达式

表达式主要用于计算求值。

Rust 编译器在解析代码时：

- 如果遇到分号 `;`，就会继续往后面执行。

- 如果遇到语句，就会执行语句。

- 如果遇到表达式，就会对表达式求值。

- 如果分号 `;` 后面什么都没有，就会补上单元值 ()。

- 当遇到函数时，就会将函数体的花括号识别为块表达式。

### 块表达式

块表达式是由一对花括号和一系列表达式组成的，它总是返回块中最后一个表达式的值。

```rs
{
  1 + 1
  1 + 2 // 整个块表达式的返回值
}
```

### 位置表达式

位置表达式（Place Expression）一般叫做左值，是表示内存位置的表达式，有以下几类：

- 本地变量

- 静态变量

- 解引用 (* express)

- 数组索引 (expr[expr])

- 字段引用 (expr.field)

- 位置表达式组合

通过位置表达式可以对某个数据单元的内存进行读写；位置表达式可以用于赋值。

### 值表达式

值表达式（Value Expression）一般叫做右值，值表达式引用了某个存储单元地址中的数据。它相当于数据，只能进行读操作。

从语义角度来说，位置表达式代表了持久性数据，值表达式代表了临时数据。位置表达式一般有持久的状态，值表达式要不是字面量，要不就是表达式求值过程中创建的临时值。

## 常量

常量时绑定到一个名称的不允许改变的值。

常量与不可变变量的区别：

- 不允许对常量使用 `mut`

- 使用 `const` 关键字声明常量，且必须注明值的类型。

- 常量只能是常量表达式，不能是函数调用的结果，或任何其他只能在运行时计算出的值

> Rust 的常量必须在编译时明确赋值。

示例：

```rs
const MAX_NUMBER: u32 = 100_000;
```

## 注释

Rust 的注释有两种：

- 普通注释
  - `//` 整行注释
  - `/* .. */` 区块注释

- 文档注释（支持 markdown 语法）
  - `///` 一般用于函数或结构体说明，至于说明对象的上方
  - `//!` 一般用于整个模块的说明，至于模块文件的头部

```rs
/// # 文档注释: Sum函数
/// 该函数为求和函数
/// # usage:
///    assert_eq!(3, sum(1, 2));
fn sum(a: i32, b: i32) -> i32 {
    a + b
}
pub fn annotation() {
    // 这是单行注释的示例
    /*
         * 这是区块注释, 被包含的区域都会被注释
         * 你可以把/* 区块 */ 置于代码中的任何位置
    */
    /*
        注意上面区块注释中的*符号，纯粹是一种注释风格，
        实际并不需要
        */
    let x = 5 + /* 90 + */ 5;
    println!("Is `x` 10 or 100? x = {}", x);
    println!("2 + 3 = {}", sum(2, 3));
}
```

## 打印

打印操作由 `std::fmt` 里面所定义的一系列宏来处理，包括：

- `format!`：将格式化文本输出到 字符串（String）。

- `print!`：与 format!类似，但将文本输出到控制台。

- `println!`: 与 print!类似，但输出结果追加一个换行符。

## 返回值

为什么 Rust 中的错误处理使用返回值而不是异常，参考以下解释

> 有些人需要在不允许使用 Exception 的地方使用 Rust（因为展开表和清理代码太大）。这些人实际上包括所有浏览器供应商和游戏开发人员。此外， Exception 具有讨厌的代码生成权衡。您要么将它们设为零成本（如 C ++，Obj-C 和 Swift 编译器通常所做的那样），在这种情况下，在运行时抛出异常的代价非常高，或者使它们成为非零成本（如 Java HotSpot 和 Go 6g/8g），在这种情况下，即使没有引发异常，您也会为每个 try 块（在 Go 中为defer）牺牲性能。对于使用 RAII 的语言，每个带有析构函数的堆栈对象都形成一个隐式 try 块，因此在实践中这是不切实际的。
>
> 零成本 Exception 的性能开销不是理论问题。我记得关于使用 GCJ（使用零成本 Exception）进行编译时，Eclipse 需要花费30秒来启动的故事，因为它在启动时会引发数千个 Exception。
>
> 当您同时考虑错误和成功路径时，相对于 Exception，C 处理错误的方法具有出色的性能和代码大小，这就是为什么系统代码非常喜欢它的原因。然而，它的人机工程学和安全性很差，Rust 用 Result 来解决。Rust 的方法形成了一种混合体，旨在实现 C 错误处理的性能，同时消除其陷阱。


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at December 6, 2023 16:49</small></div>
      