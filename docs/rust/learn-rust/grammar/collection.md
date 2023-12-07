---
sidebar_position: 6
---
    
<small color="#ccc">last modified at 2023/12/7 8:44:3</small>
# 集合数据

## 字符串

Rust 将字符串分为两种:

- str，固定长度，不可改变

- String，可变长度

### str

Rust 的原始字符串类型，也成为`字符串切片`。通常以借用的形式出现，即 `&str`。

字符串切片是一些储存在别处的 UTF-8 编码字符串数据的`引用`，比如字符串字面值是被储存在程序的二进制输出中。

str 由两部分组成：

- 指向字符串序列的指针

- 记录长度的值

```rs
use std::slice::from_raw_parts;
use std::str::from_utf8;

let truth: &'static str = "Rust是一门优雅的语言";
let ptr = truth.as_ptr();
let len = truth.len();
assert_eq!(28, len);

let s = unsafe {
    let slice = from_raw_parts(ptr, len);
    from_utf8(slice)
};
assert_eq!(s, Ok(truth));
```

Rust 中的字符串本质上是一段有效的 UTF-8 字符序列。

### String

`String` 类型是可变长度、拥有所有权、UTF-8 编码的字符串。其内部实现是 `Vec<u8>` 的封装。

一些 String 的操作：

```rs
// 新建

// 创建空的字符串
let mut empty_string = String::new(); 

// 创建由初始值的字符串，需要该类型实现 Display trait，例如字符串字面值
let data = "initial contents";
let string = data.to_string();
// 等价于
let string = String::from(data);

// 更新

// 追加 slice
let mut s1 = String::from("foo");
let s2 = "bar";
s1.push_str(s2); // push_str 获取时 s2 的字符串 slice，并没有获取其所有权
println!("s2 is {}", s2); // s2 依然可用

// 拼接

// +
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2; // fn add(self, s: &str) -> String {}
// 说明：
// s1 被移动到 s3，不能继续使用
// 只能将 &str 和 String 相加，不能将两个 String 相加。
// &s2 能编译通过，是因为 &String 被强转成 &str，即 &s2 -> &s2[..]

// format! 宏
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");
let s = format!("{}-{}-{}", s1, s2, s3); // 不会获取所有权

// 索引引用
// Rust 不允许使用索引获取 String 字符

// 遍历字符串

// 如果你需要操作单独的 Unicode 标量值，最好的选择是使用 chars 方法。
for c in "नमस्ते".chars() {
    println!("{}", c);
}
// न
// म
// स
// ्
// त
// े

// bytes 方法返回每一个原始字节，这可能会适合你的使用场景：
for b in "नमस्ते".bytes() {
    println!("{}", b);
}
// 打印出其字节
// 224
// 164
// --snip--
// 165
// 135

```

## 向量（Vec）

可动态增长的数组，只能储存类型相同的值。

### 使用

```rs
// 新建

// 空 Vec
let v: Vec<i32> = Vec::new();
let v: Vec<i32> = Vec::with_capacity(5); // 指定容量

// 使用初始值
let v = vec![1, 2, 3]; 

// 更新

// 增加元素

let mut v = Vec::new();
v.push(5);
v.push(6);

// 读取
let v = vec![1, 2, 3, 4, 5];

let third: &i32 = &v[2]; 
println!("The third element is {}", third);

match v.get(2) { // 返回 Option<&T>
    Some(third) => println!("The third element is {}", third),
    None => println!("There is no third element."), // 当索引不存在或超出范围时
}

// 遍历并修改
let mut v = vec![100, 32, 57];
for i in &mut v {
    *i += 50; // 解引用
}
```

### 所有权

Vec 在离开其作用域是会被释放，并丢弃其所有元素。

当获取 Vec 的第一个元素的不可变引用并尝试在 Vec 末尾增加一个元素的时候，这是行不通的。

```rs
let mut v = vec![1, 2, 3, 4, 5];
let first = &v[0]; // 获取了 Vec 某个元素的不可变引用
v.push(6); // 尝试改变 Vec
println!("The first element is: {}", first); // 报错
```

为什么不能这么做？

> 由于 Vec 的工作方式：在 Vec 的结尾增加新元素时，在没有足够空间将所有所有元素依次相邻存放的情况下，可能会要求分配新内存并将老的元素拷贝到新的空间中。这时，第一个元素的引用就指向了被释放的内存。借用规则阻止程序陷入这种状况。

## 双端队列（VecDeque）

VecDeque 与 Vec 的区别：支持双端操作，支持 FIFO 和 FILO。

使用示例：

```rs
// 导入VecDeque模块
use std::collections::VecDeque;

// 新建并 push 数据

let mut buf:VecDeque<u8> = VecDeque::new();
for v in (1..=3).rev() {
    buf.push_back(v); // 尾部追加
}
println!("{:?}",buf); // [3, 2, 1]


let mut buf:VecDeque<u8> = VecDeque::with_capacity(5);
for v in &mut buf {
    buf.push_front(*v); // 头部插入
}
println!("{:?}",buf); // [1, 2, 3]

// 获取

assert_eq!(but.get(2), Some(&3));
```

使用 `pop_front` 和 `pop_back` 可以实现头部出栈和尾部出栈。

## 链表（LinkedList）

Rust 提供的链表是双向链表。

```rs
use std::collections::LinkedList;
let mut list1 = LinkedList::new();

list1.push_back('a');

let mut list2 = LinkedList::new();
list2.push_back('b');
list2.push_back('c');

list1.append(&mut list2);
println!("{:?}", list1); // ['a', 'b', 'c']
println!("{:?}", list2); // []

list1.pop_front();
println!("{:?}", list1); // ['b', 'c']

list1.push_front('e');
println!("{:?}", list1); // ['e', 'b', 'c']

list2.push_front('f');
println!("{:?}", list2); // ['f']
```

> 使用 Vec 或者 VecDeque 类型，比链表更快。

## 映射（Map）

Rust 提供两种类型的映射：

- `HashMap<K, V>`: 无序

- `BTreeMap<K, V>`: 有序

Key 必须是可哈希的类型，Value 必须是编译器已知大小的类型。

对于像 i32 这样的实现了 Copy trait 的类型，其值可以拷贝进哈希 map。对于像 String 这样拥有所有权的值，其值将被移动而哈希 map 会成为这些值的所有者。

如果将值的引用插入哈希 map，这些值本身将不会被移动进哈希 map；但是这些引用指向的值必须至少在哈希 map 有效时也是有效的。

使用示例：

```rs
// 插入
use std::collections::BTreeMap;
use std::collections::HashMap;
let mut hmap = HashMap::new();
let mut bmap = BTreeMap::new();
hmap.insert(3, "c");
hmap.insert(1, "a");
hmap.insert(2, "b");
hmap.insert(5, "e");
hmap.insert(4, "d");
bmap.insert(3, "c");
bmap.insert(2, "b");
bmap.insert(1, "a");
bmap.insert(5, "e");
bmap.insert(4, "d");
// 输出结果为：{1: "a", 2: "b", 3: "c", 5: "e", 4: "d"}，但key的顺序是随机的，因为HashMap是无序的
println!("{:?}", hmap);
// 输出结果永远都是 {1: "a", 2: "b", 3: "c", 4: "d", 5: "e"}，因为BTreeMap是有序的
println!("{:?}", bmap);

// 访问
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Yellow"), 50);

let team_name = String::from("Blue");
let score = scores.get(&team_name);
// 或者使用循环
for (key, value) in &scores {
    println!("{}: {}", key, value);
}

// 更新
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Blue"), 25);

println!("{:?}", scores); // {"Blue": 25}，原始值 10 被覆盖

// 只在键没有对应值时插入
scores.entry(String::from("Blue")).or_insert(50); // entry 检查键并返回是否存在

// 根据旧值更新
use std::collections::HashMap;

let text = "hello world wonderful world";
let mut map = HashMap::new();

for word in text.split_whitespace() {
    let count = map.entry(word).or_insert(0); // 返回可变医用（&mut V）
    *count += 1; // * 号解引用
}
```

`HashMap` 默认使用密码学安全的哈希函数，可抵抗 DDOS 攻击，但并不是最快的算法。可以指定一个不同的 hasher 来切换为其它函数。hasher 是一个实现了 BuildHasher trait 的类型。

## 集合（Set）

Rust 提供两种类型的集合：

- `HashSet<K>`: 无序

- `BTreeSet<K>`: 有序

集合中的元素是唯一的，且是可哈希的类型。

使用示例：

```rs
use std::collections::HashSet;
use std::collections::BTreeSet;

// 新建

let mut hbooks = HashSet::new();
let mut bbooks = BTreeSet::new();

// 插入数据

hbooks.insert(2);
hbooks.insert(1);
hbooks.insert(2);

// 判断元素是否存在，contains方法和HashMap中的一样

if !hbooks.contains(&1) {
    // ...
}

println!("{:?}", hbooks); // {2, 1}，顺序不固定

bbooks.insert(1);
bbooks.insert(2);
bbooks.insert(3);
println!("{:?}", bbooks); // 输出固定为 {1, 2, 3}，因为是有序
```

## 优先队列（BinaryHeap）

用二进制堆实现的优先级队列。

这将是一个最大的堆。

```rs
use std::collections::BinaryHeap;

// 新建
let mut heap = BinaryHeap::new();

// 可以使用 peek 来查看堆中的下一个项。
// 在这种情况下，那里还没有项目，所以得到 None。
assert_eq!(heap.peek(), None);

// 添加一些分数...
heap.push(1);
heap.push(5);
heap.push(2);

// 显示堆中最重要的项。
assert_eq!(heap.peek(), Some(&5));

// 我们可以检查堆的长度。
assert_eq!(heap.len(), 3);

// 我们可以遍历堆中的项，尽管它们是按随机顺序返回的。
for x in &heap {
    println!("{}", x);
}

// 如果我们改为弹出这些乐谱，则应按顺序返回。
assert_eq!(heap.pop(), Some(5));
assert_eq!(heap.pop(), Some(2));
assert_eq!(heap.pop(), Some(1));
assert_eq!(heap.pop(), None);

// 我们可以清除任何剩余项的堆。
heap.clear();

// 堆现在应该为空。
assert!(heap.is_empty())
```

最小堆，`std::cmp::Reverse` 或自定义 `Ord` 实现均可用于使 BinaryHeap 成为最小堆。

```rs
use std::collections::BinaryHeap;
use std::cmp::Reverse;

let mut heap = BinaryHeap::new();

// 在 `Reverse` 中包装值
heap.push(Reverse(1));
heap.push(Reverse(5));
heap.push(Reverse(2));

// 现在弹出这些乐谱，它们应该以相反的顺序返回。
assert_eq!(heap.pop(), Some(Reverse(1)));
assert_eq!(heap.pop(), Some(Reverse(2)));
assert_eq!(heap.pop(), Some(Reverse(5)));
assert_eq!(heap.pop(), None);
```

      