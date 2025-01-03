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

6. 浏览器路由跳转

    _普通跳转_
    - browser process 的 UI thread **响应用户输入**，并判断是否为合法网址。
      > 当输入时搜索协议时，分发到另外的服务处理
    - UI thread 通知 Network thread **获取网页内容**，Network thread 寻找合适协议处理网络请求，如：DNS 协议寻址，TLS 协议建立安全链接。
      > 如果遇到 301 重定向，通知 UI thread 重新走第二步。
    - Network thread **读取到响应头信息**，包含 `Content-Type` 表示返回内容格式，如果是 HTML，network thread 将数据传给 renderer process 处理。
      > 此时还会校验安全性，比如 [CORB](https://www.chromium.org/Home/chromium-security/corb-for-developers/) 或 [XSS](https://en.wikipedia.org/wiki/Cross-site_scripting) 问题。
    - 触发 render。一旦所有检查完成，Network thread 通知 UI thread 已准备好跳转（此时并没有加载完所有数据，只检查了响应头），UI thread 通知 renderer process 开始渲染。
      > 为了提升性能， UI thread 再通知 Network thread 的同时会实例化一个 renderer process 等着，一旦上一步检查完毕立即进入渲染阶段，如失败则丢弃该实例化 renderer process。
    - 确认导航。上一步之后 browser process 通过 IPC 像 renderer process 传送 stream 数据。
      > 此时导航被确认，浏览器的各个状态（导航状态，前进后退历史）被修改，同时方便 tab 关闭后快速恢复，会话记录被保存在硬盘。
    - 加载完成。当 renderer process 加载完成，通知 browser process `onLoad` 事件，此时浏览器完成加载，loading 小时，触发各种 onLoad 回调。
      > 此时 JS 可能还在加载远程资源

    _跳转到其他网站_
    - 执行普通跳转前，还会响应 `beforeunload` 事件，这个事件注册在 renderer process, 所以 browser process 会检查 renderer process 是否注册事件响应。注册该响应会拖慢关闭 tab 的速度。如无需要勿注册。
    - **如果跳转是由 JS 发起的**，执行跳转由 renderer process 触发，browser process 执行普通跳转流程。当执行跳转是，会触发原站点的 `unload` 事件，有旧的 renderer process 响应，而新站点会创建新的 renderer process 渲染。当旧网页全部关闭后，销毁就的 renderer process。
      > 一个 tab 内，在跳转时，可能存在多个 renderer process。

    _Service Worker_
    - [Service Worker](https://developer.chrome.com/docs/workbox/service-worker-overview/) 可以在页面加载前执行（业务逻辑，改变页面内容），浏览器把它实现在 renderer process 中。
    - 当 Service Worker 被注册后，会被丢到一个作用域中，UI thread 执行时会检查该作用域是否注册 Service Worker，如有，则 network thread 会创建 renderer process 执行 Service Worker，网络响应也会被 Service Worker 接管
      > [Navigation Preload](https://web.dev/blog/navigation-preload)，UI thread 会在检查是否注册 Service Worker 的同时通知 network thread 发起请求。

7. 页面渲染（Renderer Process）

    _渲染是分阶段进行的_
    - 解析，解析 HTML 文本为 DOM，遇到需要加载远程资源的标签（img, link, script），交给 network thread 并行处理，其中 script 标签会阻塞解析（因为JS可以改变DOM， 加async/defer可避免）
    - 样式，style 标签申明的样式作用于 DOM 上，生成 CSSOM，基于选择器确定节点
    - 布局，生成 LayoutTree 描述元素的布局，`display: none` 的元素不会出现在 tree 上。这是平面结构关系
    - 绘图（光栅化），PaintRecord 记录元素的层级关系，决定元素的绘制顺序。这是上下层级空间结构关系
    - 合成，将需要渲染的内容分层绘制与渲染，并可通过 CSS 属性 `will-change` 手动申明为一个新层。每一个合成层会将绘图内容切分为多个栅格交由 GPU 渲染（GPU适合并行任务），性能会非常好。

      每个阶段的计算都依赖上一阶段的输出，在优化性能时可以注意以下几种情况：
      1. 修改元素几何属性需要重新合成，因此会触发所有阶段的重新计算
      2. 修改元素绘图属性，如颜色，不需要重新计算布局
      3. transform 属性会跳过布局和绘图阶段，因此可以使用 GPU 性能加速

    隐式合成层、层爆炸、层自动合并
    1. 部分元素会显示提升到合成层，如transform、will-change、video、canvas、iframe、fixed等等。
    2. 发生元素重叠时，下方元素如果是显示提升到合成，其上方元素也会被提升到合成层。
    3. 当出现复杂行为时，如轨迹动画，浏览器无法知道哪些元素位于当前元素上方，只好把所有元素提升到合成层，当数量过多时，浏览器与GPU的通信会成为瓶颈。
    4. 浏览器支持层自动合并。

8. 事件处理（输入进入合成器）
    - 输入：用户的操作
    - 合成器：渲染最后一步，利用 GPU 进行光栅化绘图（并行），如果与主进程解偶会提高效率（运行在CPU，串行）
    - 结论：实际运行中，合成器需要响应输入，这可能导致合成器效率下降，导致页面卡顿

    让合成器与主进程解偶
    - 当元素绑定事件时，浏览器会将此监听的区域标记为“non-fast”区域
    - 当“non-fast”区域触发事件后，合成器必须与渲染进程通信，等待渲染进程执行JS监听回调并获取结果，如是否调用 preventDefault() 来阻止默认事件。这个等待时间消耗时巨大的，在低性能设备如手机，可能达到10～100ms。如果将事件委托绑定到document.body级别，整个页面都被标记为“non-fast”
    - 跳过与渲染进程的等待，合成器的效率将大大提高。但是 preventDefault() 将会失效
      ```js
      document.body.addEventListener('touchstart', e => {
        // ...
      }, { passive: true });
      ```

    事件合并，浏览器会合并高频触发的事件，如滚动，避免事件阻塞。如果不希望丢失中间状态，使用：`getCoalescedEvents`

## 238.精读《不再需要 JS 做的 5 件事》

- 使用 CSS 控制 SVG 动画，控制线条虚实
- Hover 时出现的 sidebar，伪类:hover，tab 选中 :focus-within
- sticky position, 在父容器内固定定位
- 手风琴菜单，`<details`> 标签
- 暗色主题，判断系统主题，`@media(prefers-color-theme: light/dark/nno-preference)`
- 幻灯片滚动
    ```css
    .parent {scroll-snap-type: y mandatory;} 
    .child {scroll-snap-align: start}
    ```

## 239.精读《JS 数组的内部实现》

- 快类型：`[Packed(连续有值), Holey（稀散）]_[SMI（32位整型）, Double（浮点）, ''（复合类型）]_Elements`
- 慢类型：`Dictionary_Elements` 字典模式，节省空间，额外查询消耗
- 快类型可自动降级且不可逆；快慢类型可转换，取决于节省空间是否超过50%

## 240.精读《React useEvent RFC》

`useEvent`，回调函数不变引用，但可以获取最新值。（绕过依赖检测）

## 242.精读《web reflow》

触发时机：
- 元素位置发生变化时
- 获取元素/鼠标位置，尺寸信息，为保证准确，需要reflow
- 元素focus/select，确定元素当前状态
- innerText
- contenteditable 的元素

优化：
- 合并操作
- 读写分离
- fastdom 库，在window.requestAnimationFrame 时机执行

## 254.精读《对前端架构的理解 - 分层与抽象》

- 业务模块的架构设计，从需求出发设计业务子模块，定义彼此的职责和关系
- 模块划分取决于业务特定，模块分层取决于业务拓展需求
- 冯诺伊曼架构 - 计算、存储、扩展（输入输出）
- 架构设计也要解决代码一致性问题（可维护性）
- 分层是架构设计的重点，需要根据业务动态变化
- 抽象是架构设计的难点，不要纠结于完美的抽象
- 总结：业务变化驱动架构不断演变


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at January 3, 2025 17:02</small></div>
      