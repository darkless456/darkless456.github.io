---
sidebar_position: 3
---
    
# Perusal Series

## 214.精读《web streams》

stream 是持续加载资源的方式。I/O 处理比较好的方式。

- readable streams，只可读
- writable streams，只可写
- transform streams，对流数据转换

## 215.精读《什么是 LOD 表达式》

LOD(Level of Detail)，数据详细级别。LOD 表达式，在一个查询中描述不同的详细粒度。

数据分析可以看作是对数据汇总计算的过程，伴随着数据的详细程度逐渐降低。

## 218.精读《Rust 是 JS 基建的未来》

- swc
  - @swc/cli 基建
  - @swc/core 针对开发者，提供基本 API
  - @swc/wasm-web 浏览器调用 wasm 版 swc
  - @swc/jest jest 实现
  - swc-loader，替代 babel-loader
  - swcpack，swc 版 webpack
- esbuild （go 编写）
- NAPI-RS，rust 到 node 的衔接层

## 22.精读《V8 引擎特性带来的的 JS 性能变化》

1. try...catch 对性能的影响忽略不计
2. 解决 delete 的性能问题
3. 解决 arguments 转数组性能问题
4. bind 对性能影响可以忽略
5. 函数调用对性能影响可以忽略（注释，空白，函数间调用）
6. 64 位数字计算性能只有 32 位的 2/3，尽量用字符串处理大数
7. 遍历 object 速度，for in > Object.keys > Object.values
8. 单态函数性能高于多态，如混合类型 array 性能低于单类型 array

## 219 ～ 222.精读《深入了解现代浏览器一～四》

1. CPU、GPU 是计算硬件，提供 API 供汇编语言调用；操作系统（OS）基于它们之上用 C 语言（如 Linux）管理硬件，例如进程调度、内存分配、用户态切换；应用程序运行于 OS 之上，通过 OS 间接操作硬件。
2. 硬件是没有隔离和安全措施的，所以 APP 直接操作硬件会带来安全风险。
3. OS 的进程可以分配独立的内存空间，创建多个线程，这些线程共享内存空间。进程通过 IPC 通信。
4. 浏览器可以拆分成多个模块（Chrome）

- 浏览器模块（Browser），协调其他模块运行
- 网络模块（Network），网络 I/O
- 存储模块（Storage），本地 I/O
- 用户界面模块（UI），浏览器 UI
- GPU 模块，图形计算
- 渲染模块（Renderer），网页渲染
- 设备模块（Device），本地设备交互
- 插件模块（Plugin），浏览器插件

5. 浏览器架构设计

- 少进程，资源消耗小，稳定性差，低性能设备
- 多进程，资源消耗大，稳定性好，高性能设备
- 弹性架构，可以在不同进程架构中切换


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at November 14, 2024 17:32</small></div>
      