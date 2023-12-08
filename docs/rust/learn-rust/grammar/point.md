---
sidebar_position: 5
---
    
<small style={{color: '#cccccc'}}>last modified at December 8, 2023 7:10 AM</small>
# 指针

## 概述

Rust 中可以表示内存地址的类型称为 指针。

指针的类型：

- 引用（reference）

- 原始指针（raw pointer）

- 函数指针（fn pointer）

- 智能指针（smart pointer）

`Safe Rust` 和 `Unsafe Rust`：

- Safe Rust，引用，编译器会对引用进行借用检查。

- Unsafe Rust，原始引用，需要编程人员自己保证内存和类型安全。

## 引用（reference）

使用操作符 `&`，可以直接获取表达式的内存地址。引用是一种非空的指针。

```rs
let a = [1,2,3];
let b = &a;
println!("{:p}", b); // 0x7ffcbc067704，该地址是示例，不同机器不一样

// 要获取可变引用，必须先声明可变绑定
let mut c = vec![1,2,3];

// 通过 &mut 得到可变引用
let d = &mut c;
d.push(4);
println!("{:?}", d); // [1, 2, 3, 4]

let e = &42;
assert_eq!(42, *e);
```

> 不管是 `&a` 还是 `&mut c` 都是对原有变量的所有权的借用，所以引用被称为`借用`。

## 原始指针（raw pointer）

Rust 支持两种原始引用：

- 不可变原始指针，`*const T`。

- 可变原始指针，`*&mut T`。

> 用 `as` 操作符可以将引用转为原始指针。

```rs
let mut x = 10;
let ptr_x = &mut x as *mut i32;
let y = Box::new(20);
let ptr_y = &*y as *const i32;

// 原生指针操作要放在unsafe中执行
unsafe {
    *ptr_x += *ptr_y;
}
assert_eq!(x, 30);
```

## 函数指针（fn pointer）

函数作为参数：

```rs
// 将函数作为参数传递
pub fn math(op: fn(i32, i32) -> i32, a: i32, b: i32) -> i32 {
    // 通过函数指针调用函数
    op(a, b)
}
fn sum(a: i32, b: i32) -> i32 {
    a + b
}

let a = 2;
let b = 3;
assert_eq!(math(sum, a, b), 5);
```

函数作为返回值：

```rs
fn is_true() -> bool { 
  true 
}

// 函数的返回值是另外一个函数
fn true_maker() -> fn() -> bool { 
  is_true 
}

// 通过函数指针调用函数
assert_eq!(true_maker()(), true);
```

## 智能指针（smart pointer）

### `Box<T>`

Rust 中的值默认被分配到`栈内存`。可以通过 `Box<T>` 将值装箱（在`堆内存`中分配）。

- `Box<T>`，超出作用域范围是，会自动调用析构函数，销毁内部对象并自动释放内存

- 可以用解引用操作符 `*` 来获取 `Box<T>` 中的 T。

- 其行为类似引用，并会自动释放内存，故称为智能指针。

```rs
#[derive(Debug, PartialEq)]
struct Point {
    x: f64,
    y: f64,
}
let box_point = Box::new(Point { x: 0.0, y: 0.0 });
let unboxed_point: Point = *box_point; // 解引用获取类型被包括的值
assert_eq!(unboxed_point, Point { x: 0.0, y: 0.0 });
```

[TBC]

      