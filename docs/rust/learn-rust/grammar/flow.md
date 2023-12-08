---
sidebar_position: 4
---
    
<small style={{color: '#cccccc'}}>last modified at December 6, 2023 8:49 AM</small>
# 流程控制

## if

if 条件表达式的分支必须返回同一类型的值。

```rs
let n = 13;
// if 表达式可以用来赋值
let big_n = if n < 10 && n > -10 {
    // 分支必须返回同一个类型的值
    10 * n
} else {
    // 自动截取
    n / 2
};
assert_eq!(big_n, 6);
```

## for ... in

```rs
for n in 1..101 {
    if n % 15 == 0 {
        println!("fizzbuzz");
    } else if n % 3 == 0 {
        println!("fizz");
    } else if n % 5 == 0 {
        println!("buzz");
    } else {
        println!("{}", n);
    }
}

// for … in 后面是一个 Rang 类型，左闭右开，所以这个循环的最后一个 n 值是100。
```

## loop

```rs
let mut n = 1;
loop {
    if n > 101 { break; }
    if n % 15 == 0 {
        println!("fizzbuzz");
    } else if n % 3 == 0 {
        println!("fizz");
    } else if n % 5 == 0 {
        println!("buzz");
    } else {
        println!("{}", n);
    }
    n += 1;
}
```

## while

```rs
let mut n = 1;
while n < 101 {
    if n % 15 == 0 {
        println!("fizzbuzz");
    } else if n % 3 == 0 {
        println!("fizz");
    } else if n % 5 == 0 {
        println!("buzz");
    } else {
        println!("{}", n);
    }
    n += 1;
}
```

## loop 和 while 的区别

```rs
// 不能编译通过
let mut a;
while true {
      a = 1;
      break ;
}
println!("{}", a); // error[E0381]: borrow of possibly-uninitialized variable: `a`

// 可以编译通过
let mut a;
loop {
      a = 1;
      break ;
}
println!("{}", a);
```

`while` 表达式的条件位置并非常量上下文，无法在编译器求值，只能检查类型。

`loop` 是永久循环，必然执行一次；编译器会在编译期将 a 直接初始化为常量 1。

## match

match 用于匹配各种情况，有点类似 switch/case，且支持模式匹配。

match 分支：

- 左边是模式：
  - 不同分支可以是不同模式
  - 必须穷尽每一种可能，最后可以使用通配符 `_`。

- 右边是执行代码：
  - 所有分支必须返回同一类型的值

```rs
let number = 42;
match number {
    // 模式为单个值
    0 => println!("Origin"),
    // 模式为Range
    1...3 => println!("All"),
    // 模式为 多个值
    | 5 | 7 | 13  => println!("Bad Luck"),
    // 绑定模式，将模式中的值绑定给一个变量，供右边执行代码使用
    n @ 42 => println!("Answer is {}", n),
    // _ 通配符处理剩余情况
    _ => println!("Common"),
}
```

使用 match 语句赋值：

```rs
let boolean = true;
let binary = match boolean {
    false => 0,
    true => 1,
};
```

## if let

`if let` 表达式用来在某些场合替代 match 表达式：

```rs
let some_u8_value = Some(0u8);
if let Some(3) = some_u8_value {
    println!("three");
}
```

## while let

`while let` 某些场合可以简化代码：

```rs
let mut v = vec![1,2,3,4,5];
loop {
    match v.pop() {
        Some(x) => println!("{}", x),
        None => break,
    }
}
```

可改写为：

```rs
let mut v = vec![1,2,3,4,5];
while let Some(x) = v.pop() {
    println!("{}", x);
}
```

      