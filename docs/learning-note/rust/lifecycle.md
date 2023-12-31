---
sidebar_position: 2
---
    
# Rust Lifecycle

## 一些要点

- Rust 的生命周期标注是帮助编译器确定对象的生命周期的，并不影响程序的实际运行。
- 所有的引用类型对象都有独立的生命周期，如函数参数、变量、指针、数组、结构体、枚举等。
- Rust 自动推测生命周期的基础是，入参的生命周期是推测出参生命周期的基础。
- 自动推测的规则：
  - 只有一个引用入参，那么该入参的生命周期就是所有引用出参的生命周期。
  - 多个引用入参，其中有一个是 `self`，则引用出参的生命周期就是 `self` 的生命周期。
  - 多个引用入参，其中没有 `self`，则此时编译器无法推测出参的生命周期，需要程序员标注。

```text
Rust中的变量和值，变量和数据，这两种说法是不同的，值不总是等价于实际数据，基本上可以认为，变量的值总在栈中，但变量实际的数据，可能在栈中，可能在堆中，可能在全局内存段。

例如，let s = 3u8;，变量s的值是3，实际数据也是3，此时值等价于实际数据，3在栈中。

再例如，let s = "Hello World!";，变量是s，实际数据是存放在全局内存段中的"hello world!"，变量保存的值是切片引用&str，引用是一种胖指针，指向全局内存段的实际数据。所以这里变量的值不等价于数据。

变量退出作用域，销毁的是它的值。所以，s退出作用于是，被销毁的是其值，即切片引用&str，而不是销毁它的数据。

如果实际数据保存在堆，那么变量退出作用域时，销毁值的同时是否会也销毁堆中的数据，这由实现Drop的代码来决定。

例如，let v = String::from("hello");，变量v的值是一个String类型的值，String类型内部一个Vec，总的来说它的值是一个Struct，其值保存在栈中，这个Struct中有一个指针指向堆中的数据，堆中的数据其字符数据部分(即hello的每一个字符)拷贝自于全局内存段。当v被释放时，Struct被Drop，Drop的时候会将堆中的内存也释放，这是Vec实现Drop时决定的。
```


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at December 7, 2023 16:56</small></div>
      