---
sidebar_position: 1
---
    
# Perusal Series - 1

## 100.精读《V8 引擎 Lazy Parsing》

并不是所有 Js 都需要在初始化时就被执行，因此也不需要在初始化时就解析所有的 Js！因为编译 Js 会带来三个成本问题：

- 编译不必要的代码会占用 CPU 资源。
- 在 GC 前会占用不必要的内存空间。
- 编译后的代码会缓存在磁盘，占用磁盘空间。

因此所有主流浏览器都实现了 Lazy Parsing（延迟解析），它会将不必要的函数进行预解析，也就是只解析出外部函数需要的内容，而全量解析在调用这个函数时才发生。

## 102.精读《Monorepo 的优势》

总的来说，虽然拆分子仓库、拆分子 NPM 包（For web）是进行项目隔离的天然方案，但当仓库内容出现关联时，没有任何一种调试方式比源码放在一起更高效。

工程化的最终目的是让业务开发可以 100% 聚焦在业务逻辑上，那么这不仅仅是脚手架、框架需要从自动化、设计上解决的问题，这涉及到仓库管理的设计。

多仓库注意点：（大型系统明显）

- 管理、调试
- 分支管理
- 依赖关系
- 团队协作

## 107.精读《Optional chaining》

JS 新特性草案结构

1. 起因，解决什么问题。
2. 其他语言的实现方案。
3. 语法介绍，介绍所有可能的使用情况
4. 语义，语法含义
   以下是可选项

- 是否有不支持的情况，一般会留下讨论的 issue
- 暂不考虑的点，说明原因，留下讨论 issue
- 正在讨论的点
- FAQ
- 草案进度
- 参考文献
- 相关问题
- 预先讨论资料

## 109.精读《Vue3.0 Function API》

Vue: mutable + template
React: immutable + JSX

Vue 使用 setup 函数和 template 将数据层和渲染层分离
React 使用 JSX 将数据层和渲染层耦合

两者区别：

1. setup 函数仅执行一遍，template 重渲染继承 Vue 的依赖收集机制

- 更符合 JS 使用直觉
- 对 Hooks 使用顺序无要求，可以放在条件语句中
- 重渲染无需调用全部渲染函数
- 减少对性能优化的要求
- 数据流难以追踪，后续维护的便利程度

2. react 中更新状态要调用赋值函数

- 单向数据流，确定性、可调试性、数据追踪
- 需要适用 useMemo 等性能优化手段来减少非必要渲染
- 重复调用带来的 GC 压力

## 11.精读《前端调试技巧》

1. 代码中 Debugger
2. console.log/console.dir
3. lint/语法高亮
4. React Developer Tools/Vue Developer Tools
5. Chrome Dev Tools

- 远程调试

6. 移动端调试

- 真机调试, browserstack, dynatrace
- Weinre, 页面加载脚本，与 PC 端通信
- 内嵌控制台，eruda/VConsole
- Rosin, fiddler 插件
- jsconsole, 手机访问对应 IP，调试对应浏览器的控制台

7. 实时调试，document.activeElement
8. 结构化打印对象瞬时状态，JSON.stringify(obj, null, 2)，避免引用问题
9. Array.prototype.find
10. 代理请求，charles, fiddler
11. chrome 插件
12. 用户实机调试，通过将控制台信息打印到服务器
13. DOM 断点、事件断点

- dom 右键，选择，在 dom 被修改时触发断点
- Event Listener Breakpoints

14. 错误追踪平台
15. 黑盒调试，Dev Tools 源码中右键，选择 Black Script 变成黑盒。针对报错由某处代码统一抛出的情况
16. CSS Tracker, 删除冗余 CSS
17. $0 ~ $4 是 chrome 记录的最后插入的 5 个元素
18. 监听特定函数调用

```shell
> function func(num){}
> monitor(func)
> func(3)
// < function func called with arguments: 3
```

19. 模拟请求，postman
20. 找到控制台最后一个对象，`$_`

## 112.精读《源码学习》

阅读源码的方式：

1. 源码解读文章
2. 代码断点
3. 无目的寻宝

阅读代码不是目的，读懂源码背后的核心设计思路才是目的。从代码中学习理论。

## 118.精读《使用 css 变量生成颜色主题》

Web 内容无障碍指南，涵盖了让 Web 内容更易于访问的各种建议。

- 网页颜色的对比度在 1:1 到 21:1 之间
- 文本和图像文本的对比度最小值为 4.5:1
- 对比度越高，越利于阅读。低对比度对视力障碍或色觉缺陷用户不友好。

示例：

按钮文字如何选择使用白色还是黑色

**根据明度决定是黑色还是白色**

心理学公式：`Gray = R*0.299 + G*0.587 + B*0.114`

```js
if (red * 0.299 + green * 0.587 + blue * 0.114 > 186) {
  // use #000000
} else {
  // use #ffffff
}
```

如果用户选取的颜色很浅，与背景颜色的对比度小于 4.5。这是可以寻找对比度更强的颜色，不断加深当前选择的颜色，获取到满足对比度要求的同色系颜色。

经验：给定一个主题色，如何获取第二第三主题色

将颜色放到 HSL 色轮上，转动 HUE 值 60 度，得到第二主题色。

纯 CSS 解决方案

根据明度决定按钮文字颜色的代码

```css
:root {
  --light: 80;
  /* 文字颜色变化的临界值 */
  --threshold: 60;
}
.btn {
  /* 会被解析成黑色或者白色 */
  --switch: calc((var(--light) - var(--threshold)) * -100%);
  color: hsl(0, 0%, var(--switch));
}
```

可视化图表对于颜色的应用

1. 不用多种颜色表示同类数据
2. 多条行图表，不使用不同颜色或者色轮对立的颜色。对比度过强
3. 避免使用具有特殊意义的颜色，如红色或绿色表示销售额变化

## 120.精读《React Hooks 最佳实践》

```tsx
const App: React.FC<{ title: string }> = ({ title }) => {
  return React.useMemo(() => <div>{title}</div>, [title]);
};

App.defaultProps = {
  title: "Function Component",
};
```

组件间通信

```tsx
export const StoreContext = React.createContext<{
  state: State;
  dispatch: React.Dispatch<Action>;
}>(null)

export interface State {};

export interface Action { type: 'xxx' } | { type: 'yyy' };

export const initState: State = {};

export const reducer: React.Reducer<State, Action> = (state, action) => {
  switch (action.type) {
    default:
      return state;
  }
};

//全局共享
const AppProvider: React.FC = props => {
  const [state, dispatch] = React.useReducer(reducer, initState);

  return React.useMemo(() => (
    <StoreContext.Provider value={{ state, dispatch }}>
      <App />
    </StoreContext.Provider>
  ), [state, dispatch])
};

// 访问/修改
const app: React.FC = () => {
  const { state, dispatch } = React.useContext(StoreContext);

  return React.useMemo(() => (
    <div>{state.name}</div>
  ), [state.name])
};
```

input 的值频繁变化。

1. react scheduling 的调度系统会做优化
2. onChange 本身不慢，大部分使用值的组件也不慢，因此没必要从 onChange 源头开始 debounce。
   > 当 input 受控时， 在 onChange 下 debounce，导致值不能及时回填，引发 UI 的输入问题
3. 更好的方式时，寻找渲染性能慢且使用 input 值的组件，对入参 debounce

```ts
const App: React.FC = ({ text }) => {
  // 无论 text 变化多快，textDebounce 最多 1 秒修改一次
  const textDebounce = useDebounce(text, 1000);

  return useMemo(() => {
    // 使用 textDebounce，但渲染速度很慢的一堆代码
  }, [textDebounce]);
};
```

在使用 useEffect 时要注意调试上下文，注意父级传递的参数引用是否正确，如果引用传递不正确，有两种做法：

- 对依赖进行深度比较
- 使用 ref 对引用变化的 props 进行包装

```tsx
function useCurrentValue<T>(value: T): React.RefObject<T> {
  const ref = React.useRef(null);
  ref.current = value; // 保证引用不变，但总是指向最新的值
  return ref;
}

const App: React.FC = ({ onChange }) => {
  const onChangeCurrent = useCurrentValue(onChange);
};
```

## 121.精读《前端与 BI》

商业智能（Business Intelligence），1.0 阶段（报表展现），2.0 阶段（探索式分析）

数据集、渲染引擎、数据模型、可视化

## 123.精读《用 Babel 创造自定义 JS 语法》

TDD

联想编程，探索式编程，通过错误和阅读代码，一步步通过合理联想实现目标。成为技术专家的软素质

词法、语法分析，编译原理

插件机制，申明式、命令式；JS 书写、JSON 书写

柯理化/偏函数

AST visit，遍历 AST 树

内置函数注册，全局变量、自动 import

**从某个功能点为切面，走一遍框架的完整流程式一种高效的学习方式**

## 124.精读《用 css grid 重新思考布局》

block, float, flex 一维布局方式，需要使用 div 层级结构描述

grid 二维布局

```html
<div class="card">
  <img src="https://i.pravatar.cc/125?image=3" alt="" class="profile-img" />
  <ul class="social-list">
    <li>
      <a href="#" class="social-link"><i class="fab fa-dribbble-square"></i></a>
    </li>
    <li>
      <a href="#" class="social-link"><i class="fab fa-facebook-square"></i></a>
    </li>
    <li>
      <a href="#" class="social-link"><i class="fab fa-twitter-square"></i></a>
    </li>
  </ul>
  <h2 class="profile-name">Ramsey Harper</h2>
  <p class="profile-position">Graphic Designer</p>
  <p class="profile-info">
    <!-- ... -->
  </p>
</div>
```

```css
.card {
  /* ... */
  display: grid;
  grid-template-columns: 1fr 3fr;
  grid-column-gap: 2em;
  grid-template-areas: /* layout */
    "image name"
    "image position"
    "social description";
}

.profile-name {
  grid-area: name;
}
.profile-position {
  grid-area: position;
}
.profile-info {
  grid-area: description;
}
.profile-img {
  grid-area: image;
}
.social-list {
  grid-area: social;
}
```

## 125.精读《深度学习 - 函数式之美》

深度学习数学模型与函数式编程的相似性：

- 数据不可变
- 函数可任意组合

不可变数据保证并发安全，函数间隔离让竞争和锁问题可以更容易处理

并发效率，分而治之，分区计算，对分区计算结果进行合并，clojure

haskell 机器学习，惰性求职，无论数据量多大，实际消耗的运算资源取决于实际用到的部分。备注：也是一种分区的方式

## 127.精读《React Conf 2019 - Day1》

class 生效的顺序与加载顺序有关

```jsx
// 效果可能是 blue 而不是 red
<div className="blue red" />

// 效果一定是 red，因为 css-in-js 在最终编排 class 时，虽然两种样式都存在，但书写顺序导致最后一个优先级最高，
// 合并的时候就会舍弃失效的那个 class
<div className={styles('blue', 'red')} />
```

提升网页加载速度

普通网页加载，download code -> render ui + fetch data -> render fetched data

改善方案

1. 预请求，一遍加载脚本一遍发出已解析出的请求
2. 源码分段加载，对请求也适用。例如下载的代码拆分了 UI 和 非 UI，优先加载 UI 渲染的代码。
3. 源码按需加载
4. UI 层面，占位图、骨架屏来实现相对自然的视觉连贯性

React.Suspense 可以嵌套。资源会按嵌套顺序加载。

React 的跨平台特性，来自其渲染函数 ReactReconciler 只关心如何组织组件与组件间关系，不关心具体实现。因此它会暴露一些函数供外部使用

创建实例，React 组件本质是 tag + 属性，Reconciler 不关心如何创建元素，通过 create Instance 来创建并拿到基本属性，web 上是利用 DOM API 实现

更新组件，实现 prepareUpdate and commitUpdate， user action -> prepareUpdate -> payload -> commitUpdate -> update

react 利用平台无关的语法生成 AST，利用 react-reconciler 解析这个 AST，利用回调函数实现 UI 更新

SVG 图标有话，将字符串使用替换成图标实例，再利用 tree-shaking 实现按需加载

干预 github 主要语言检测，在 .gitattributes 文件中忽略指定文件夹检测

## 129.精读《React Conf 2019 - Day2》

Fast refresh 对每个 Function component 生成一份专属签名，描述核心状态，当状态改变时销毁重渲染，对非核心状态改变进行代价更小的 rerender。

```js
// signature: "useState{isLoggedIn}"

function ExampleComponent() {
  const [isLoggedIn, setIsLoggedIn] = useState(true);
}
```

对样式、dom 结构的修改不触发签名变化。

局限：不能很好的支持 class component，混合非 React 组件时不能精确 reload，消耗内存

Suspense

- Promise error 时，进去 fallback，表示中间状态
- 业务组件不用关心请求中间状态，是否正在进行，直接拿数据来处理
- ErrorBoundary 包裹处理异常，该组件的 fallback 来做异常状态显示
- fetch on render
- 控制组件加载顺序，避免页面抖动

动画 react-spring, react-use-gesture

## 132.精读《正交的 React 组件》

正交，模块之间不会互相影响。前端代码将 UI 与数据处理逻辑分离也是一种符合正交原则的设计。有利于长期维护。

从正交设计角度来看，

- hooks，状态管理与 UI 分离
- Suspense，取数据与 UI 分离
- ErrorBoundary，异常与 UI 分离

## 134.精读《我在阿里数据中台大前端》

对数据的诉求：

- 数据从哪来，如何数字化
- 如何获得想要的数据，数据计算、建模、管理
- 如何使用数据，数据服务
- 如何利用数据，商业决策（BI 平台）、制定计划。。。
- 如何保护数据，安全保障

_前端不是因为我们使用 JS，而是我们站在业务的最前端，解决业务问题。_

## 138.精读《精通 console.log》

1. console.log() | info() | debug() | warn() | error()

- 直接打印字符串，展示形态不同，信息分类
- 支持占位符，%o - 对象、%s - 字符串、%d - 数字、%c - css 样式
- 可输出复杂内容，输入仅支持字符串（通过多入参解决这个问题）
- 自动判断类型，输出对应的格式

2. console.dir()

- 强制输出 JSON 格式

3. console.table()

- 输出表格

4. console.group() & console.groupEnd()

- 信息分组

5. console.count()

- 统计调用次数

6. console.assert()

- 断言并输出第二个参数

7. console.trace()

- 打印调用栈

8. console.time([ label ]) & console.timeEnd([ label ])

- 打印代码执行时间

9. console.memory

- 内存使用情况

10. console.clear()

- 清空控制台信息

## 140.精读《结合 React 使用原生 Drag Drop API》

HTML 拖拽核心 API：

- dragStart, 当元素被拖动时，可以获取被拖动的元素
- dragEnter, 拖入某个区域
- dragLeave, 拖出某个区域
- dragOver, 正在某个区域内拖拽，应该怎么防止被拖动的元素
- drop, 当松开鼠标放置被拖动的元素时触发

设置元素可拖放

> <img draggable="true" />

在 dragStart 和 drop 之间传递被拖动的元素，使用 dataTransfer

```js
// 当开始拖动
function onDragStart(ev) {
  ev.preventDefault();
  ev.stopPropagation();

  ev.dataTransfer.setData("component", ev.target.id);
}

// 当松开鼠标时
function onDrop(ev) {
  ev.preventDefault();
  ev.stopPropagation();

  const componentId = ev.dataTransfer.getData("component");

  // 获取被拖动的元素
  const dragEle = document.getElementBy(componentId);

  containerEle.appendChild(dragEle); // 将被拖动元素加入容器中
}
```

更复杂的场景，一个元素可以被拖动，也可以被拖入其他元素。此时我们需要用可被拖动元素包裹可被拖入元素

```js
export function Box() {
  return (
    <DraggableElement>
        <DroppableElement>
          ...
        <DroppableElement>
    </DraggableElement>
  )
}
```

## 141.精读《useRef 与 createRef 的区别》

Hooks 的独特之处，虽然在普通函数中，但在 React 引擎中会得到超出普通函数的表现，比如初始化仅执行一次，或者引用不变等。

```md
React Lifecycle:

1. Render phase, render // 不允许写有副作用的代码，因为这个阶段可能被 React 取消或重试。初始化操作是可以的，因为副作用最多只执行一次。
2. Reconciliation phase, React update DOM and **ref**
3. Layout phase, layout cleanup and layout effect (useLayoutEffect), block UI
4. Commit phase, effect layout and effect (useEffect), side effect/schedule update
```

```js
function usePrevious(value) {
  const ref = useRef();
  useEffect(() => {
    // side effect 总是在 render 阶段之后执行
    ref.current = value;
  }, [value]);
  return ref.current;
}
```

## 142.精读《如何做好 CodeReview》

- 覆盖范围
  - good，代码正确性、测试覆盖率、功能变化、代码规范与最佳实践
  - better，引入代码的必要性、与现有系统的适配性（是否自洽）、可维护性；从全局视角考虑
- 语气
  - good，给出建设性意见，不发表强硬措辞。因为这样的讨论具有一定攻击性，激发对方的防御心理，给对方留有余地
  - better，对好的地方鼓励，对不完善的地方包容并提出体现善意的建议
- 审阅
  - good，在得到充分讨论后，才通过开放式 PR，Reviewer 对自己关注部分完成 Review 后给出反馈，通过协作软件与作者进一步讨论
  - better，灵活执行，紧急的改动，留下改进建议或者 TODO，但快速通过。
- 后续沟通
  - good，给出完整的建议，如后续代码不符预期，与提交者面对面沟通
  - better，第一次就给出完整的建议，当修改不符预期，面对面沟通
- 区分重点
  - good，区分建议的重要程度
  - better，采用工具自动化解决一些问题，如 lint 通过后才能合并 PR
- 新成员
  - good，评判标准一视同仁
  - better，对成员给出更详细的解决方法，更多关怀
- 跨时区
  - good，仅在工作时间重叠范围进行 code review，语音/视频沟通
  - better，必要时将某些模块交由对方维护或对方团队负责 review，避免跨时区 review
- 公司支持
  - good，能得到公司的支持
  - better，公司完善 review

## 143.精读《Suspense 改变开发方式》

异步状态管理

- 代码中利用本地状态管理
  - 代码中手动指定状态
  - 重复的样板代码，与组件绑定，不好统一管理
- 全局上下文（context）管理
  - 组件有固定的代码结构
  - 不好控制 loading 的范围
- Suspense
  - 要求代码 suspended，即在 pending 时抛出可以被捕获的 promise 异常，在 promise 结束后再渲染组件
  - 自由决定状态管理的范围

## 144.精读《Webpack5 新特性 - 模块联邦》

让代码直接在项目见利用 CDN 直接共享，不再需要本地安装 NPM 包、构建再发布。

传统共享代码的方式：

- NPM
- UMD
- Micro-FE

新的方式，webpack module federation，有个**中心应用（不提供给用户使用）**，分发服用的 npm 包和模块。

```js
//app1
const HtmlWebpackPlugin = require("html-webpack-plugin");
const ModuleFederationPlugin = require("webpack/lib/container/ModuleFederationPlugin");

module.exports = {
  // other webpack configs...
  plugins: [
    new ModuleFederationPlugin({
      name: "app_one_remote", // 应用名称，全局唯一
      remotes: {
        // 其他应用 name 映射到当前项目（别名）
        app_two: "app_two_remote",
        app_three: "app_three_remote",
      },
      exposes: {
        // 到处模块
        AppContainer: "./src/App",
      },
      shared: ["react", "react-dom", "react-router-dom"], // 远程加载的模块中的所使用的公共模块
    }),
  ],
};

//app2
export default {
  plugins: [
    new ModuleFederationPlugin({
      name: "app_two",
      library: { type: "var", name: "app_two" },
      filename: "remoteEntry.js",
      exposes: {
        Search: "./src/Search",
      },
      shared: ["react", "react-dom"],
    }),
  ],
};

// 导入被expose 的模块
// [name]/[expose_name]
```

## 145.精读《React Router v6》

React Router v6 带来的改变

1. API 命名，使用 `Routes` 代替 `Switch`

2. 透传 routeProps

```js
// v5
<Route path=":userId" component={Profile} />
<Route
  path=":userId"
  render={routeProps => (
    <Profile {...routeProps} animate={true} />
  )}
/>

// v6
<Route path=":userId" element={<Profile />} />
<Route path=":userId" element={<Profile animate={true} />} />
```

3. 嵌套路由

```js
// v5
function App() {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact path="/" component={Home} />
        <Route path="/profile" component={Profile} />
      </Switch>
    </BrowserRouter>
  );
}

function Profile() {
  let match = useRouteMatch();

  return (
    <div>
      <nav>
        <Link to={`${match.url}/me`}>My Profile</Link>
      </nav>

      <Switch>
        <Route path={`${match.path}/me`}>
          <MyProfile />
        </Route>
        <Route path={`${match.path}/:id`}>
          <OthersProfile />
        </Route>
      </Switch>
    </div>
  );
}

// v6
// Approach #1
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="profile/*" element={<Profile />} />
      </Routes>
    </BrowserRouter>
  );
}

function Profile() {
  return (
    <div>
      <nav>
        <Link to="me">My Profile</Link>
      </nav>

      <Routes>
        <Route path="me" element={<MyProfile />} />
        <Route path=":id" element={<OthersProfile />} />
      </Routes>
    </div>
  );
}

// Approach #2
// You can also define all
// <Route> in a single place
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="profile" element={<Profile />}>
          <Route path=":id" element={<MyProfile />} />
          <Route path="me" element={<OthersProfile />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

function Profile() {
  return (
    <div>
      <nav>
        <Link to="me">My Profile</Link>
      </nav>

      <Outlet />
    </div>
  );
}
```

4. `useNavigate` 代替 `useHistory`

```js
// v5
history.push("/home");
history.replace("/home");

// v6
navigate("/home");
navigate("/home", { replace: true });
```

利用 Context 的方式

- 一个 context，多个 useContext，全局上下文
- 多个 context，嵌套组件可以获得更多更新的上下文，给下层组件的扩展提供空间


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at November 14, 2024 17:32</small></div>
      