---
sidebar_position: 4
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

## 263.精读《我们为何弃用 css-in-js》

优点：
- 无全局样式冲突，模块化能力
- 和普通 JS 代码一起管理
- 支持 JS 变量

缺点：
- 运行时性能，React 18 的调度机制下，在运行时插入样式会暂停渲染，等解析完样式再继续
- 样式优先级无法自定义，class优先级有 header 定义顺序决定，而非 classname 顺序决定

## 29.精读《JS 中的内存管理》

内存生命周期：
1. 分配内存
2. 使用内存（读/写）
3. 释放内存（自动/手动）

JS 的内存回收：
- 标记清除：通过标记不再使用的对象，来回收内存（现代浏览器普遍采用）
  - 从根节点开始，遍历所有可达对象，标记为“活跃”
  - 垃圾回收器定期清理未标记的对象
- 引用计数：通过计数引用对象的数量，来判断何时回收内存
  - 限制：循环引用

## 30.精读《Javascript 事件循环与异步》

1. 同步代码进入 call stack，遵循FIFO原则
2. 异步代码进入 Event Loop 的 Task Queue
3. 当 call stack 为空时（这个时机由宿主环境决定），Event Loop 会将 Task Queue 中的任务依次放入 call stack 执行

Macrotask 和 Microtask
- Macrotask：包括整体代码块、setTimeout、setInterval、I/O 操作等
- Microtask：包括 Promise.then、MutationObserver、Process.nextTick（Node.js）等
- 执行顺序：先执行所有 Microtask，再执行一个 Macrotask

> **异步队列是周而复始执行，可以看作二维数组，横排是一个队列的一个个函数，纵排是一个个队列。 Microtask 把回调添加到当前队列，Macrotask 添加一个新的队列。**

## 35.精读《dob - 框架实现》

> MVVM 中，依赖追踪是核心

依赖追踪分为两部分：**依赖收集**和**触发回调**

实现参考 [mobx](./mobx-observer.md)

## 36.精读《When You “Git” in Trouble- a Version Control Story》

```shell
git fsck --full # 检查repo完整性，会显示未被引用的对象
git fsck --lost-found # 查找丢失的对象
git fsck --unreachable # 查找不可达的对象

git hash-object xxx.js # 计算文件的哈希值
git cat-file -p <hash> # 查看对象内容
git cat-file -t <hash> # 查看对象类型

# blob 对象，存储文件内容
# tree 对象，存储目录结构
# commit 对象，存储提交信息，包括作者、时间、当前tree对象，前一个commit对象

git reflog # 查看引用日志，找到丢失的分支或提交
```

## 52.精读《图解 ES 模块》

ES 模块化的工作机制

1. 静态分析：在编译时确定模块之间的依赖关系
2. 代码分割：按需加载模块，优化性能
3. 作用域隔离：每个模块都有自己的作用域，避免变量冲突
4. 导入导出：使用 `import` 和 `export` 语法进行模块之间的交互

与 CJS 的区别

1. ES 模块是静态的，CJS 是动态的
2. ES 模块支持异步加载，CJS 是同步加载
3. ES 模块有自己的作用域，CJS 共享作用域
4. ES 模块使用 `import` 和 `export`，CJS 使用 `require` 和 `module.exports`

## 53.精读《插件化思维》

插件化思维是一种将系统分解为多个可插拔模块的设计理念。通过定义清晰的接口和契约，使得各个模块之间可以独立开发、测试和部署。

如何实现插件化的框架设计：

1. **定义插件接口**：为插件定义统一的接口和规范，确保各个模块之间的兼容性。
2. **实现事件机制**：通过事件机制实现模块之间的通信和协作。
3. **使用依赖管理工具**：使用依赖管理工具（如 npm）管理插件的依赖关系。
4. **支持热更新**：支持插件的热更新，提升开发体验。

## 57.精读《现代 js 框架存在的根本原因》

现在框架最重要的帮助是保持 UI 与 状态的同步。
两种方式：
1. 重渲染组件，React，当状态改变后，生成新的虚拟DOM🌲，最终改变当前的真实DOM，成为reconciliation
2. 监听修改，Angular/Vue，状态改变触发对应DOM的Value更新

三个框架互相借鉴，一般会混合使用上述两种方式。

```md
// 评论
1. 个人觉得浏览器应该做的是更底层的事，比如新的人机交互，更快的加载和渲染速度等等，而UI与state同步的事，其实加上一个中间层就能搞定，react、vue等都是一个中间层，这一层应该开放给开发者进行处理。
2. 状态与UI同步的问题我个人理解是一个状态机处理状态的问题，整个应用是一个状态机，处理不同的输入。而能把应用变成状态机的只能是js，html和css都不行。所以以js为中心进行前端开发是趋势，除非找到新的编程模型
```

## 59.精读《如何利用 Nodejs 监听文件夹》

```js
// 轮询检测文件，有延迟
fs.watchFile(dir, (curr, prev) => {
  console.log(`File changed: ${dir}`);
});
```

```js
// 为了抹平操作系统差异，回调执行次数不确定
fs.watch(dir, (eventType, filename) => {
  console.log(`File changed: ${filename}`);
  // 优化判断逻辑
  // 1. 对比文件修改时间
  // 2. 校验文件md5
  // 3. 延迟判断（debounce）
});
```

## 6.精读《JavaScript 错误堆栈处理》

1. 抛出标准的 Error 对象
2. Promise 使用 reject 代替 throw 抛出错误，避免未捕获的异常
3. 监控客户端错误，`try...catch`（无法捕捉语法错误和全局错误）,使用 `window.onerror` 进行全局错误处理。
4. `window.onerror` 跨域解决方案
    - `<script>` 标签添加 `crossorigin` 属性
    - 服务器端设置 CORS 响应头

## 60.精读《如何在 nodejs 使用环境变量》

1. 命令行 `PORT=3000 node app.js`
2. `.env` 文件 + `.dotenv` 包
3. 生产环境，使用专门的云服务

## 62.精读《JS 引擎基础之 Shapes and Inline Caches》

JS 引擎的运作机制分为 AST 分析和字节码（机器码）生成。

JS 引擎为了提高性能，采用了多种优化手段，其中之一就是形状（Shapes）和内联缓存（Inline Caches）。

- 形状（Shapes）：JS 引擎会为对象创建一个形状描述符，记录对象的结构信息（如属性名、属性类型等），以便快速访问。
- 内联缓存（Inline Caches）：JS 引擎会在函数调用时记录下第一次调用的形状信息，以后再调用时可以直接使用缓存，提高性能。

> `Proxy` vs `Object.defineProperty`， 后者会破坏JS引擎对数据做的优化

## 76.精读《谈谈 Web Workers》

```js
// 主线程
const worker = new Worker('worker.js');
worker.postMessage('Hello, worker!');
worker.onmessage = function(event) {
  console.log(event.data);
};
worker.terminate();

const ab = new ArrayBuffer(1);
worker.postMessage(ab, [ab]); // 传输所有权（对象引用），主线程不再拥有 ab
```

```js
// worker 线程
self.onmessage = function(event) {
  console.log(event.data);
  self.postMessage('Hello, main thread!');
};
self.postMessage('Hello, main thread!');
```

创建方式：
1. 手动创建
2. 通过 URL.createObjectURL() 创建

```js
const blob = new Blob([`self.onmessage = function(event) {
  console.log(event.data);
  self.postMessage('Hello, main thread!');
};
self.postMessage('Hello, main thread!');`], { type: 'application/javascript' });
const url = URL.createObjectURL(blob);
const worker = new Worker(url);
```

## 83.精读《React16 新特性》

1. render 支持返回数组和字符串
2. Error Boundaries，组件捕获错误
3. createPortal，跨组件树传递子节点
4. 支持自定义DOM属性
5. 支持 Fiber 架构，提升性能。更新过程分为两个阶段：
    1. Reconciliation 阶段，构建 Fiber 树，可以被打断
    2. Commit 阶段，提交更新，影响真实DOM，不可被打断
6. Call Return，父组件根据子组件的的回调信息去渲染子组件。 适用场景：瀑布流布局
    1. 父返回对call的调用，`unstable_createCall(props.children, callback, props)`
    2. 子返回对return的调用，`unstable_createReturn(obj)`，`obj` 是call的回调参数
7. Fragment，允许在不增加额外节点的情况下返回多个子元素
8. `createContext`，用于跨组件传递数据
9. `createRef/forwardRef`，用于组件间的引用转发
10. 标记 reconciliation 阶段生命周期函数为不安全的
    - component**Will**Mount
    - component**Will**ReceiveProps
    - **should**ComponentUpdate
    - component**Will**Update
11. 新增生命周期函数
    - static getDerivedStateFromProps，根据 props 更新 state
    - getSnapshotBeforeUpdate，组件在更新前获取快照
    - component**Did**Catch，组件捕获错误
12. StrictMode，帮助识别不安全的生命周期函数、过时的 API 和其他潜在问题
13. Profiler 实验性 API，用于测量组件渲染性能
14. React.memo()/React.lazy/Suspense，支持组件的懒加载和性能优化
15. static contextType，类组件中使用 context 的便捷方式
16. static getDerivedStateFromError，组件捕获子组件错误并更新 state
17. Hooks（React 16.8）
    - useState，函数组件中的状态管理
    - useEffect，副作用处理
    - useContext，使用 context
    - useReducer，类似 Redux 的状态管理
    - useCallback，缓存函数引用
    - useMemo，缓存计算结果
    - useRef，创建可变引用
    - useImperativeHandle，自定义暴露给父组件的实例值
    - useLayoutEffect，与 DOM 交互的副作用处理
    - useDebugValue，调试自定义 Hook
18. Concurrent Mode（并发模式），React 16 引入的实验特性，支持更细粒度的渲染控制和更好的用户体验

## 86.精读《国际化布局 - Logical Properties》

- `inline-start` 和 `inline-end`，分别表示行内开始和行内结束，取代了 `left` 和 `right`。(display: inline)
- `block-start` 和 `block-end`，分别表示块级开始和块级结束，取代了 `top` 和 `bottom`。(display: block)
- 使用 css grid 与 flexbox 布局方案的网页，将在支持的浏览器上自动享受国际化布局调整，不需要改变语法。
- `writing-mode` 排版，`direction` 文字对齐

## 87.精读《setState 做了什么》

`react` 包定义接口，react-dom、react-native 实现接口。
- setState, ins.updater = ReactDOMUpdater/ReactNativeUpdater/ReactDOMServerUpdater
- useHook, 实现 dispatch 接口

## 88.精读《Caches API》

Caches API 是一个用于在浏览器中存储和检索请求及其响应的接口。它提供了一种简单的方式来缓存网络请求，以提高应用程序的性能和离线体验。

### 主要特点

1. **缓存存储**：Caches API 允许将请求及其响应存储在缓存中，以便后续使用。缓存可以是持久性的，也可以是临时的。
2. **请求拦截**：通过 Service Worker，可以拦截网络请求并返回缓存中的响应，从而实现离线支持和快速加载。
3. **版本管理**：Caches API 支持缓存版本管理，可以轻松地更新和删除旧的缓存。

### 使用示例

```js
// 打开或创建一个缓存
caches.open('my-cache').then(cache => {
  // 将请求及其响应存储在缓存中
  cache.put('/api/data', new Response(JSON.stringify({ data: 'Hello, world!' })));
});

// 从缓存中检索响应
caches.match('/api/data').then(response => {
  if (response) {
    // 缓存中存在响应
    response.json().then(data => {
      console.log(data);
    });
  }
});

// 结合 service worker 使用
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request);
    })
  );
});
```

### 注意事项

- Caches API 只能在 HTTPS 环境下使用，或者在 localhost 上进行开发。
- 缓存的大小是有限制的，浏览器会根据策略自动清理旧的缓存。

## 89.精读《如何编译前端项目与组件》

- 项目构建，使用复杂的构建约束策略，只要最终结果符合浏览器规范就行
- 组件构建，采用相对简单的办法，确保代码的通用性

## 96.精读《useEffect 完全指南》

函数组件特性：
- 每次render 都有自己的 state 和 props 快照（capture value）
- 每次render 都有自己的事件处理函数快照
- 每次render 都有自己的 effect 快照
- `useRef` 可以绕过快照限制，实现跨 render 共享数据
- `useEffect` 依赖项变化时，执行 effect 回调。依赖项可以是 state、props 或者其他变量（例如对象的引用）

## 97.精读《编写有弹性的组件》

1. 不要阻塞数据流，不要将接收到的props 本地化
2. 不要阻塞副作用的数据流
3. 不要因为性能优化而阻塞数据流（类组件中自定义的 shouldComponentUpdate）
4. 时刻准备渲染
5. 不要有单例组件
6. 隔离本地状态

```js
// 优化小手段：如果父组件依赖比较多子组件的反向控制，可以使用 useReducer 代替 useState
const AppDispatchContext = React.createContext(null);
const appReducer = (state, action) => {
  switch (action.type) {
    // ...
  }
  return newState;
}

const App = memo(function App(props) {
  const [state, dispatch] = useReducer(appReducer, initialState);
  return (
    <AppDispatchContext.Provider value={dispatch}>
      <ChildComponent {...props} state={state} />
    </AppDispatchContext.Provider>
  );
});

```
## 4.精读《AsyncAwait 优越之处》

Async/Await 优势：
- 语法简洁，易读性强
- 错误处理方便，使用 try/catch
- 调试方便

局限：
- 只能处理单个异步操作，多个操作需要借助Promise.all
- 不能取消异步操作
- 需要浏览器支持

## 72.精读《REST, GraphQL, Webhooks, & gRPC 如何选型》

- REST：无状态的数据传输结构，适用于通用、快速迭代和标准化语义的场景。
- gRPC：轻量的传输方式，特殊适合对性能高要求或者环境苛刻的场景，比如 IOT。
- GraphQL: 请求者可以自定义返回格式，某些程度上可以减少前后端联调成本。
- Webhooks: 推送服务，主要用于服务器主动更新客户端资源的场景。




<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at September 7, 2025 22:27</small></div>
      