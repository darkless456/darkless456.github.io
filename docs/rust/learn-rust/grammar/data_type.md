---
sidebar_position: 4
---
    
# 基本数据类型

## 整型

|长度|有符号|无符号|
|--|--|--|
|8-bit|i8|u8|
|16-bit|i16|u16|
|32-bit|i32|u32|
|64-bit|i64|u64|
|arch|isize|usize|

> isize 和 usize 类型依赖运行程序的计算机架构：64 位架构上它们是 64 位的， 32 位架构上它们是 32 位的。

整型字面值

|数字字面值|示例|说明|
|--|--|--|
|Decimal|98_222||
|Hex|0xff|16进制|
|Octal|0o77|8进制|
|Binary|0b1111_0000|2进制|
|Byte(u8 only)|b'A'|字节字面量|

整型溢出

- 当在 debug 模式编译时，Rust 检查这类问题并使程序 panic

- 在 release 构建中，Rust 不检测溢出，相反会进行一种被称为 “two’s complement wrapping” 的操作。

简而言之，256 变成 0，257 变成 1，依此类推。

依赖溢出被认为是一种错误，即便可能出现这种行为。如果你确实需要这种行为，标准库中有一个类型显式提供此功能，Wrapping。

## 浮点型

Rust 有两个原生的 浮点数 f32 和 f64，分别占 32 位和 64 位。

默认类型是 f64，因为在现代 CPU 中，它与 f32 速度几乎一样，不过精度更高。

```rs
let num = 3.1415926f64;
assert_eq!(-3.14, -3.14f64);
assert_eq!(2., 2.0f64);
assert_eq!(2e4, 20000f64);
```

特殊值

```rs
use std::f32::{INFINITY, NEG_INFINITY, NAN, MIN, MAX};
println!("{:?}", INFINITY); // inf
println!("{:?}", NEG_INFINITY); // -inf
println!("{:?}", NAN); // NaN
println!("{:?}", MIN); // -340282350000000000000000000000000000000.0
println!("{:?}", MAX); // 340282350000000000000000000000000000000.0
```

## 布尔型

Rust 中的布尔类型使用 bool 表示，可以通过 `as` 操作将 bool 转为数字 0 和 1，但是不支持从数字转为 bool。

```rs
fn main() {
    let _t = true;

    // 显式指定类型注解
    let _f: bool = false;

    // 用 as 转成 int
    let i:i32 = _f as i32;

    print!("{}", i);
}
```

bool 代表一个值，它只能是 true 或 false。如果你把 bool 转为整数，那么 true 将是 1，false 将是 0。

bool 实现了各种 trait ，如 BitAnd、BitOr、Not 等，这些特征允许我们使用 &、| 和 ! 来执行布尔运算。

assert! 是测试中的一个重要的宏，用于检查一个表达式是否返回真值。

```rs
let bool_val = true & false | false;
assert!(!bool_val);
```

## 字符型

使用单引号 `'` 来定义字符类型。

Rust 的 char 类型代表了一个 Unicode 标量值（Unicode Scalar Value），每个字符占4个字节。

```rs
fn main() {
    let x = 'r';
    let x = 'Ú';
    // 支持转义
    println!("{}", '\'');
    println!("{}", '\\');
    println!("{}", '\n');
    println!("{}", '\r');
    println!("{}", '\t');
    // 用 ASCII 码表示字符
    assert_eq!('\x2A', '*');
    assert_eq!('\x25', '%');
    // 用 unicode 表示字符
    assert_eq!('\u{CA0}', 'ಠ');
    assert_eq!('\u{151}', 'ő');
    // 可以使用 as 操作符将字符转为数字类型
    assert_eq!('%' as i8, 37);
    assert_eq!('ಠ' as i8, -96); //该字符值的高位会被截断，最终得到-96
}
```

## never 类型

Rust 的 never 类型（`!`）用于表示永远不可能有返回值的计算类型。

Rust 是一个类型安全的语言，所以需要将没有返回值的情况（如线程退出）纳入类型管理。

```rs
#![feature(never_type)]
let x:! = {
    return 123
};
```

never 是`试验特性`，需要使用 nightly 版本，否则会报错。

## 元组（tuple）

元组（tuple）是一种异构有限序列：

- 异构，指元组内的元素可以是不同的类型

- 有限，是指元组有固定长度

创建元组

```rs
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

取值

```rs
// 模式匹配
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("The value of y is: {}", y);
}

// 点号（.) + 索引
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0;

    let six_point_four = x.1;

    let one = x.2;
}
```

> 当元组中只有一个元素时，需要加逗号，即 `(1,)`。空元组，`()`

## 数组（array）

数组（array）与元组不同，数组中的每个元素的类型必须相同。

- 数组大小固定

- 元素类型须相同

- 默认不可变，可通过 `let mut` 定义可变的数组，但只能通过下标（索引）来修改元素的值。

类型签名：[T; N]，

- T 是泛型标记，代表元素的具体类型。

- N 是数组长度，编译时确认值并且不可变。

```rs
// 声明数组，默认不可变
let arr: [i32; 3] = [1, 2, 3];

// 声明可变数组
let mut mut_arr = [1, 2, 3];
assert_eq!(1, mut_arr[0]);

// 通过下标修改可变数组元素的值
mut_arr[0] = 3;
assert_eq!(3, mut_arr[0]);

// 创建初始值为0大小为10的数组
let init_arr = [0; 10];
assert_eq!(0, init_arr[5]);
assert_eq!(10, init_arr.len());

// 下标越界，以 panic 的方式报错
// error: index out of bounds: the len is 3 but the index is 5
println!("{:?}", arr[5]);
```

数组是在栈（stack）而不是在堆（heap）上为数据分配内存空间。只有可以在栈上存放的元素才可以存放在该类型的数组中。

> 未来，rust将支持VLA（variable-length array）数组，即可变长度数组。

## 范围（range）

Rust 内置的范围类型，包括 左闭右开 和 全闭 两种区间，分别是 `std::ops::Range` 和 `std::ops::RangeInclusive` 的实例：

```rs
// (1..5)是结构体std::ops::Range的一个实例
use std::ops::{Range, RangeInclusive};
assert_eq!((1..5), Range{ start: 1, end: 5 });

// (1..=5)是结构体std::ops::RangeInclusive的一个实例
assert_eq!((1..=5), RangeInclusive::new(1, 5));

// 自带的 sum 方法用于求和
assert_eq!(3+4+5, (3..6).sum());
assert_eq!(3+4+5+6, (3..=6).sum());
(3..6)

// 每个范围都是一个迭代器，可用for 循环打印范围内的元素
for i in (1..5) {
    println!("{}", i);
}
for i in (1..=5) {
    println!("{}", i);
}
```

## 切片（slice）

slice 切片是对一个数组（包括固定大小数组和动态数组）的`引用片段`，可以安全访问数组的一部分，而不需要拷贝。

在底层，切片表示为一个指向数组起始位置的指针和数组长度。

```rs
// 固定大小数组的切片
let arr: [i32; 5] = [1, 2, 3, 4, 5];
assert_eq!(&arr, &[1,2,3,4,5]);
assert_eq!(&arr[1..], [2,3,4,5]);
assert_eq!((&arr).len(), 5);
assert_eq!((&arr).is_empty(), false);

// 可变数组的切片
let arr = &mut [1, 2, 3];
arr[1] = 7;
assert_eq!(arr, &[1, 7, 3]);

//使用 vec! 宏定义的动态数组的切片
let vec = vec![1, 2, 3];
assert_eq!(&vec[..], [1,2,3]);

// 字符串数组的切片
let str_slice: &[&str] = &["one", "two", "three"];
assert_eq!(str_slice, ["one", "two", "three"]);
```

## 结构体（struct）

### Named-Field Struct

```rs
#[derive(Debug, PartialEq)]
pub struct People {
    name: &'static str,
    gender: u32,
} // 注意这里没有分号

impl People {
    // new 方法的参数并没有 &self
    fn new(name: &'static str, gender: u32) -> Self {
        return People { name: name, gender: gender };
    }
    // 读方法，传递的是 &self 不可变引用
    fn name(&self) {
        println!("name: {:?}", self.name);
    }
    // 写方法，传递的是 &mut self 可变引用
    fn set_name(&mut self, name: &'static str) {
        self.name = name;
    }
    fn gender(&self) {
        let gender = if self.gender == 1 { "boy" } else { "girl" };
        println!("gender: {:?}", gender);
    }
}

fn main() {
    // 用 :: 来调用new方法，默认不可变
    let alex = People::new("Alex", 1);
    // 调用其他方法用 . 号，不用传递 &self
    // 为啥不直接把 &self 改成类型java的this语法呢？反正也不传递
    alex.name();
    alex.gender();
    // 也可以直接构建结构体，绕过new方法
    assert_eq!(alex, People { name: "Alex", gender: 1 });

    // 创建可变结构体
    let mut alice = People::new("Alice", 0);
    alice.name();
    alice.gender();
    assert_eq!(alice, People { name: "Alice", gender: 0 });
    // 就可以调用set方法了
    alice.set_name("Rose");
    alice.name();
    assert_eq!(alice, People { name: "Rose", gender: 0 });
}
```

### Tuple-Like Struct

```rs
// 元组结构体像元组和结构体的混合体，字段没有名字，只有类型。
#[derive(Debug, PartialEq)]
struct Color(i32, i32, i32); // 注意这里要有分号！

fn main() {
    // 直接构造，不用new方法
    let color = Color(0, 1, 2);
    assert_eq!(color.0, 0);
    assert_eq!(color.1, 1);
    assert_eq!(color.2, 2);
}

// 当元组结构体只有一个字段的时候，称为 New Type 模式。
#[derive(Debug, PartialEq)]
struct Integer(u32);

// 用关键字 type 为i32类型创建别名Int
type Int = i32;  

fn main() {
    let int = Integer(10);
    assert_eq!(int.0, 10);

    let int: Int = 10;
    assert_eq!(int, 10);
}
```

### Unit-Like Struct

```rs
// 单元结构体是没有任何字段的结构体。
// 等价于  struct Empty {}
struct Empty;
let x = Empty;
println!("{:p}", &x);
let y = x;
println!("{:p}", &y as *const _);
let z = Empty;
println!("{:p}", &z as *const _);

// struct RangeFull;  // 标准库源码中 RangeFull 就是一个单元结构体
assert_eq!((..), std::ops::RangeFull); //  RangeFull 就是(..)，表示全范围
```

## 枚举（enum）

### 无参数枚举

```rs
enum Number {
    Zero,
    One,
    Two,
}
let a = Number::One;
match a {
    Number::Zero => println!("0"),
    Number::One => println!("1"),
    Number::Two => println!("2"),
}
```

### 类 C 枚举

```rs
enum Color {
    Red = 0xff0000,
    Green = 0x00ff00,
    Blue = 0x0000ff,
}
println!("roses are #{:06x}", Color::Red as i32);
println!("violets are #{:06x}", Color::Blue as i32);
```

### 带参数枚举

```rs
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}
let f: fn(u8, u8, u8, u8) -> IpAddr = IpAddr::V4;
let ff: fn(String) -> IpAddr = IpAddr::V6;
let home = IpAddr::V4(127, 0, 0, 1);
```

带参数枚举的值本质上属于函数指针类型：

- fn(u8, u8, u8, u8) -> IpAddr

- fn(String) -> IpAddr

      