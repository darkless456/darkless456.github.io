---
sidebar_position: 2
---
    
# Perusal Series - 2

## 146.精读《React Hooks 数据流》

1. 单组件 `useState`
2. 跨组件 `useContext`
3. 合并更新 `useReducer`
4. 按需更新 Redux `useSelector`
5. 防止数据引用频繁变化
```js
const user = useSelector((state) => ({ user: state.user }), shallEqual)
// 当 user 值发生变化时才重渲染
const user = useSelector((state) => ({ user: state.user }), deepEqual)
```
6. 缓存查询函数, reselect `createSelector`
```js
const user = useSelector(
  (state) => ({ user: verySlowFn(state.user) }),
  deepEqual
)
// 告诉 useSelector，当入参 state.user 引用变化时才执行查询函数
const userSelector = createSelector(
  (state) => state.user, // 当 state.user 引用不变时，使用上次计算的结果
  (user) => verySlowFn(user),
)
const user = useSelector(
  (state) => userSelector(state),
  deepEqual
)
```
> 这种方式适用于被缓存的函数具有幂等性，即入参一样，结果一样。
7. 结合外部变量的缓存查询
```js
const areaSelector = (state, props) => state.areas[props.areaId].user
const userSelector = createSelector(areaSelector, (user) => verySlowFn(user))

const users = useSelector(
  (state) => userSelector(state, { areaId: 1 }),
  deeEqual,
)
```

## 148. 精读《React Error Boundaries》

API
```js
class MyErrorBoundary extends Component {
  state = {
    error: null,
  };

  static getDerivedStateFromError(error) {
    // 更新 state，下次渲染可以展示错误相关的 UI
    return { error: error };
  }

  componentDidCatch(error, info) {
    // 错误上报
    logErrorToMyService(error, info);
  }

  render() {
    if (this.state.error) {
      // 渲染出错时的 UI
      return <p>Something broke</p>;
    }
    return this.props.children;
  }
}
```

不适用的场景：
- 回调场景，
- 异步场景
- 服务端渲染
- 自身错误
- 编译时错误

可作用于 Function Component 和 Hooks

## 149. 精读《React 性能调试》

性能检测工具：

**React Profiler**
```js
const Movies = ({ movies, addToQueue }) => (
  <React.Profiler id="Movies" onRender={callback}>
    <div />
  </React.Profiler>
);

function callback(
  id, // 传入 id
  phase, // mount 或 update，更新状态
  actualTime, // 实际渲染耗时
  baseTime, // 没有使用memo时的渲染预计耗时
  startTime, // 开始渲染时间
  commitTime, // 提交更新的时间
  interactions // 什么原因导致的渲染，如 setState 。。。
) {}
```

**Tracing API**
```js
import {
  unstable_trace as trace,
  unstable_wrap as wrap,
} from "scheduler/tracing";

class MyComponent extends Component {
  addMovieButtonClick = (event) => {
    trace("Add To Movies Queue click", performance.now(), () => {
      this.setState({ itemAddedToQueue: true });
    });
  };
}

trace("Some event", performance.now(), () => {
  setTimeout(
    wrap(() => {
      // 异步操作
    })
  );
});
```

**Puppeteer**
自动化操作打印报告，类似chrome浏览器性能报告

重要性能参数：
- **FPS，每秒帧数，红色代表卡顿**
- **CPU，面积图展示 CPU 消耗**
- **NET，每条横杠代表一种资源加载**
  - **细线，等待时间**
  - **粗线，实际加载**
  - **浅色，服务器等待时间**
- **HEAP，内存消耗，长期消耗需要上监控**

**User Timing API**
利用`performance.mark`自定义性能检测节点
```js
// Record the time before running a task
performance.mark("Movies:updateStart");
// Do some work

// Record the time after running a task
performance.mark("Movies:updateEnd");

// Measure the difference between the start and end of the task
performance.measure("moviesRender", "Movies:updateStart", "Movies:updateEnd");
```

## 15.精读《TC39 与 ECMAScript 提案》

`TC39`, 推动 JS 发展的委员会，由各浏览器厂商代表组成。

标准制定流程：

1. stage0 strawman，新想法，新改变讨论
2. stage1 proposal，正式提案，潜在问题，规范描述
3. stage2 draft，初始规范草案，接受增量修改，实验性规范实现
4. stage3 candidate，获取反馈，提供polyfill 或 babel 插件
5. stage4 finished，准备发布

查看 TC39 的提案
- stage0 的提案 https://github.com/tc39/proposals/blob/master/stage-0-proposals.md 
- stage1 - 4 的提案 https://github.com/tc39/proposals

> 不同阶段的 babel 插件：babel-presets-stage-0 babel-presets-stage-1 babel-presets-stage-2 babel-presets-stage-3 babel-presets-stage-4

## 152. 精读《recoil》

```js
// 1. 状态作用域
import { RecoilRoot } from 'recoil';
function App() {
  return (
    <RecoilRoot>
      <Home />
    </RecoilRoot>
  )
}

// 2. 定义数据
const textState = atom({
  key: 'textState',
  default: '',
})


import { useRecoilValue, useRecoilState, setText } from 'recoil';
function Home() {
  // 3. 读取数据
  const text = useRecoilValue(textState);
  // or
  const [text, setText] = useRecoilState(textState);
  
  // 4. 只修改数据
  const setText = useSetRecoilState(textState);
  // 重置默认值并读取
  const [text, setText] = useResetRecoilState(textState);
}

// 5. 仅读不订阅
useRecoilCallback(async({ getPromise }) => {
  const result = await getPromise(data);
  console.log('result', result);
})

// 6. 派生值

const newTextState = selector({
  key: 'newTextState',
  get: ({ get }) => get(textState) + '.ori',
  set: ({ set }, newValue) => set(textState, newValue + '.new').
})

// 7. 异步场景，支持 suspense 和 error boundary
// 如需自己管理loading，可使用 useRecoilValueLoadable 代替

const currentUser = selector({
  key: 'currentUser',
  get: async ({ get }) => {
    const data = await getDataFromApi();
  },
})

const currentUserInfo = useRecoilValue(currentUser);


// 8. 有外部依赖的场景

const currentUser = selectorFamily({
  key: 'currentUser',
  get: (userId) => ({ get }) => { // userId 自动变为外部依赖
    return get(userInfoState[userId])
  }
})
```

理解：
1. atom 和 useRecoilXXX 是封装后的 useContext
2. 派生可以利用 useMemo

一些总结：
1. 对象读与写分离，按需渲染
2. 缓存派生值，依赖保证**引用**相等（数据一致性）
3. 无关联数据原子化，关联数据使用派生值推导

## 154. 精读《用 React 做按需渲染》

```js
const RenderWhenActive = React.memo(({children}) => children, (prevProps, nextProps) => !nextProps.active);

const ComponentLoader = ({children}) => {
  const active = useActive(children.id);

  return <RenderWhenActive active={active}>{children}</RenderWhenActive>;
}

const useActive = (domId: string) => {
  const [active, setActive] = React.useState(false);

  React.useEffect(() => {
    const visibleObserver = new VisibleObserver(domId, rootDomId, setActive);

    visibleObserver.observe();

    return () => visibleObserver.unObserve();
  }, [domId]);

  return active;
}

abstract class AbstractVisibleObserver{
  protected targetDomId: string;
  protected rootDomId: string;
  protected onActiveChange: (active?: boolean) => void;

  constructor(targetDomId, rootDomId, onActiveChange) {
    // ...
  }

  abstract public observe() {}
  abstract public unObserve() {}
}

// 轮询 和  浏览器 API

class IntersectionVisibleObserver extends AbstractVisibleObserver {
  // 使用浏览器提供的能力
}

class SetIntervalVisibleObserver extends AbstractVisibleObserver {
  // 定期查询dom 的相对位置，看是否有交集
}

class VisibleObserver extends AbstractVisibleObserver {
  constructor(targetDomId, rootDomId, onActiveChange) {
    if ('IntersectionObserver' in globalThis) { // 判断当前是否支持浏览器 API
      // IntersectionVisibleObserver
    } else {
      // SetIntervalVisibleObserver
    }
  }
}

```

## 157. 精读《如何比较 Object 对象》

1. 引用对比
  - `===`
  - `==` 
  - `Object.is()`
2. 手动对比，自定义函数，对比obj的某些键值对
3. 浅对比，对比obj第一层的引用
4. 深对比，递归对比obj的键值对

## 158. 精读《Typescript 4》

```ts
// 1. 可变元组类型
type Arr = readonly any[];

function concat<T extends Arr, U extends Arr>(arr1: T, arr2: U): [...T, ...U] {
  return [...arr1, ...arr2];
}
// 2. 元组标记（函数参数类型定义）
type Foo = [first: number, second?: string, ...rest: any[]];
// 3. Class 从构造函数推断成员变量类型（直接赋值），如果是通过函数则可能不会自动识别，需要用 !: 显式声明
// 4. 短路赋值
a &&=b; // a && (a = b)
a ||=b; // a || (a = b)
a ??=b; // a ?? (a = b)
// 5. Catch 的 error 可以是 unknown 类型
// 6. 自定义 JSX 工厂 ？ 自定义 jsx 的解析函数，脱离 react 使用 jsx
// 7. 其他
// 支持 @deprecated 注释，局部 TS server 快速启动解析，将 package.json 的中 deps 作为优先导入，不能覆盖父类的 getter 和 setter，delete 删除的属性必须定义为 optional
```

## 16.精读《CSS Animations vs Web Animations API》

```js
// web animation

let ele = document.querySelector('.anime');
const keyframe = [ // 类似 css keyframe
  { opacity: 0 },
  { opacity: 1 }
]；
const options = {
  iterations: Infinity, // 动画的重复次数，默认是 1
  iterationStart: 0, // 用于指定动画开始的节点，默认是 0
  delay: 0, // 动画延迟开始的毫秒数，默认 0
  endDelay: 0, // 动画结束后延迟的毫秒数，默认 0
  direction: 'alternate', // 动画的方向 默认是按照一个方向的动画，alternate 则表示交替
  duration: 700, // 动画持续时间，默认 0
  fill: 'forwards', // 是否在动画结束时回到元素开始动画前的状态
  easing: 'ease-out', // 缓动方式，默认 "linear"
};
let animation = ele.animate(keyframe, options);

let animationObj = ele.getAnimation(); // 获取 dom 的 animation 对象
// 操作 animation 对象
animationObj.onFinish = function() { /* ... */ } // event 方式
animationObj.finished.then(() => { /* ... */});  // promise 方式
```

## 160. 精读《函数缓存》

函数缓存，本质上是用空间（存储空间）换时间（计算过程），比较适合应用于纯函数。

基于参数的函数缓存：
1. 仅缓存最后一次计算结果，参数变化即缓存失效
2. 缓存所有计算结果，需注意参数变化数量
3. 介于 1 和 2 之间的选择，如 LRU 保留最小化最近使用的计算结果（保留热点数据）

```js
// lodash memorize

function memorize(func, resolver) {
  // validation code ...
  
  // cache
  var memorized = function() {
    var key = resolver ? resolver.apply(this, arguments) : arguments[0];
    var cache = memorized.cache;

    if (cache.get(key)) {
      return cache.get(key);
    }
    var result = func.apply(this, arguments);
    memorized.cache = cache.set(key, result) || cache; // cache.set(key, result) 执行成功返回新的全量 cache 结果，否则返回原来的 
    return result;
  }
  memorized.cache = new (memorize.Cache || Map)(); // 让用户自定义 cache 所使用的存储结构
}
```

## 162.精读《Tasks, microtasks, queues and schedules》

```js
var outer = document.querySelector(".outer");
var inner = document.querySelector(".inner");

new MutationObserver(function () {
  console.log("mutate");
}).observe(outer, {
  attributes: true,
});

function onClick() {
  console.log("click");

  setTimeout(function () {
    console.log("timeout");
  }, 0);

  Promise.resolve().then(function () {
    console.log("promise");
  });

  outer.setAttribute("data-random", Math.random());
}

inner.addEventListener("click", onClick);
outer.addEventListener("click", onClick);
```

- 用户点击 inner
  1. 点击触发 onClick 函数入栈。
  2. 立即执行 console.log('click') 打印 click。
  3. console.log('timeout') 入栈 Tasks。
  4. console.log('promise') 入栈 microtasks。
  5. outer.setAttribute('data-random') 的触发导致监听者 MutationObserver 入栈 microtasks。
  6. onClick 函数执行完毕，此时线程调用栈为空，开始执行 microtasks 队列。
  7. 打印 promise，打印 mutate，此时 microtasks 已空。
  8. 执行冒泡机制，outer div 也触发 onClick 函数，同理，打印 promise，打印 mutate。
  9. 都执行完后，执行 Tasks，打印 timeout，打印 timeout。

- 模拟点击 inner.click()
  1. inner.click() 触发 onClick 函数入栈。
  2. 立即执行 console.log('click') 打印 click。
  3. console.log('timeout') 入栈 Tasks。
  4. console.log('promise') 入栈 microtasks。
  5. outer.setAttribute('data-random') 的触发导致监听者 MutationObserver 入栈 microtasks。
  6. **由于冒泡改为 js 调用栈执行，所以此时 js 调用栈未结束，不会执行 microtasks，反而是继续执行冒泡，outer 的 onClick 函数入栈。**
  7. 立即执行 console.log('click') 打印 click。
  8. console.log('timeout') 入栈 Tasks。
  9. console.log('promise') 入栈 microtasks。
  10. 由于 5 中的 MutationObserver 的回调还没调用，因此这次 outer.setAttribute('data-random') 的改动实际上没有作用。打印结果跟 5 一样
  11. js 调用栈执行完毕，开始执行 microtasks，按照入栈顺序，打印 promise，mutate，promise。
  microtasks 执行完毕，开始执行 Tasks，打印 timeout，timeout。

结论：
1. 同步执行优先级最高
2. Task（setTimeout）
  - 顺序执行
  - 浏览器可能在 Tasks 之间执行渲染
  - 未开始执行时，优先级低于 Microtask
3. Microtasks（Promise）
  - 顺序执行
  - 当前调用栈没有优先级高的同步代码或者没有正在执行的逻辑
  - 当 Task 未开始执行时，优先级更高

## 163.精读《Spring 概念》

1. IOC (Inverse of Control) 依赖反转。框架自动注入依赖
2. AOC（Aspect Oriented Program）面向切片编程
  - 解决主要业务逻辑与次要业务逻辑（监控，异常）之间耦合
  - 在哪些地方（类，方法）切入，什么时机切入（前，后，前后。。。），以及做什么

## 190.精读《DOM diff 原理详解》

1. 完全对比 O(n³) 无法接受，故降级为同层对比的 O(n) 方案。
2. 为什么降级可行？因为跨层级很少发生，可以忽略。
3. 同层级也不简单，难点是如何高效位移，即最小步数完成位移。

## 191.精读《高性能表格》

期望：
1. 鼠标 or 拖滚动条滚动完全无白屏。
2. 行列与单元格跟随无延迟。
3. 可拓展，单元格可任意合并替换为可视化组件。

方法：
1. 单元格使用绝对定位，利用 worker 线程做并行计算
2. 模拟滚动代替原生滚动
  - 原生滚动在快速滚动时出现白屏，计算能力限制
  - 模拟滚动有 JS 触发，浏览器会在滚动前提前渲染
3. 性能优化
  - 预计算单元格
  - 压榨 worker 线程并行计算能力

## 192.精读《DOM diff 最长上升子序列》

求一个数组中，最长连续上升部分。

1. 暴力求解
2. 动态规划

## 193.精读《React Server Component》

- `*.server.js`，服务端组件，返回时 DSL 结构，跟 Next.js 不同
  - 优势，拥有服务端 API 能力，不返回非必要依赖项，SEO
- `*.client.js`，客户端组件
- `*.js`，取决于调用者

与传统服务端渲染的区别：
- 保持前端状态
- 语言一致性，C/S 端都可以使用 JS
- 使用现有前端生态，npm、JSX。。。

## 194.精读《算法基础数据结构》

1. 数组，连续内存，查找效率高
2. 链表，指针指向下一元素，增删效率高
3. 栈，先进后出结构
4. 堆，特殊完整二叉树
  - 大顶堆，根结点是最大数
  - 小顶堆，根结点是最小数
  - 用数组操作二叉树
    - 下标为 `K` 的节点
    - 父节点下标 `floor(K/2)`
    - 子节点下标 `K*2`, `K*2+1`
5. 哈希表
  - HashMap, TreeMap, HashSet, TreeSet
  - 数组 - 链表/红黑树（无序）
  - HashTree（有序）
6. 二叉搜索树
  - 平衡二叉树 增删改查 效率为 O(logn)
  - 不平衡时最终可能退化为链表
7. 字典树，搜索关联单词，节点使用标记表示单词结尾
8. 并查集，判断多个元素之间是属于某个集合
9. 布隆过滤器，快速过滤不存在数据（不完整过滤），使用二进制判断

## 195.精读《新一代前端构建工具对比》

1. esbuild，go 语言编写，没有 AST 操作能力，有 bundler（编译） 和 minifier（压缩）
2. snowpack，清亮 bundless 方案，利用浏览器的 ESM Import 特性
3. vite，一站式构建，bundless
4. wmr，preact 版 vite

## 2.精读《模态框的最佳实践》

模态框作用
- 抓住用户注意力
- 需要用户输入
- 显示额外的信息

模态框组成
- 退出，鼠标按钮、键盘按键、内容区域之外
- 描述性标题
- 动作按钮，避免用户对按钮操作感到迷惑，如一个取消操作的模态框内的取消按钮
- 大小与位置，建议视窗中间偏上，因为移动端如果太低的话可能失去一些信息
- 焦点，切换键盘焦点到模态框，accessibility
- 友好的触发方式

对可访问性的思考 accessibility
- 用户可能没有常规输入设备（鼠标、键盘），使用语音控制等非常规手段，如何操作
- 触屏支持
- 横向滚动条，尤其没有触控板时
- 键盘缩放和触控板缩放的表现

## 20.精读《Nestjs》文档

```ts
// controller
@Controller()
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('users')
  getAllUsers(req: Request, res: Response, next: NextFunction) {
    return this.usersService.getAllUsers();
  }

  @Get('/:id')
  getUser(
    @Response() res,
    @Param('id') id,
  ) {
    const user = await this.usersService.getUser(id);
    res.status(HttpStatus.OK).json(user);
  }
}
// service
@Injectable()
export class UsersService {
  getAllUsers() {
    return [];
  }
}
// module
@Module({
  controllers: [ UsersController ], // 声明 controllers
  providers: [ UsersService ], // 声明 services，可以被注入
})
export class ApplicationModule {}
```


```ts
// Typeorm 配合 class-validator 做校验
@Entity()
export class Card {
  @PrimaryGeneratedColumn({
    comment: '主键',
  })
  id: number;

  @Column({
    comment: '名称',
    length: 30,
    unique: true,
  })
  name: string = 'nick';

  @Column({
    comment: '配置 JSON',
    length: 5000,
  })
  @Validator.IsString({ message: '必须为字符串' })
  @Validator.Length(0, 5000, { message: '长度在 0~5000' })
  content: string;

  @OneToMany(type => Comment, comment => comment.user)
  comments?: Comment[];
}

@Entity()
export class Comment {
  @PrimaryGeneratedColumn({
    comment: '主键',
  })
  id: number;

  @ManyToOne(type => User, user => user.Comments)
  @JoinColumn()
  user: User;
}
```

```ts
// 新增实体校验全部字段；更新时，只校验相关字段
@EventSubscriber()
export class EverythingSubscriber implements EntitySubscriberInterface<any> {
  // 插入前校验
  async beforeInsert(event: InsertEvent<any>) {
    const validateErrors = await validate(event.entity);
    if (validateErrors.length > 0) {
      throw new HttpException(getErrorMessage(validateErrors), 404);
    }
  }

  // 更新前校验
  async beforeUpdate(event: UpdateEvent<any>) {
    const validateErrors = await validate(event.entity, {
      // 更新操作不会验证没有涉及的字段
      skipMissingProperties: true,
    });
    if (validateErrors.length > 0) {
      throw new HttpException(getErrorMessage(validateErrors), 404);
    }
  }
}
```

> 我们执行任何 CRUD 语句，统一做了错误处理，当校验失败或者数据库操作失败时，会自动终止执行后续代码

## 204.精读《默认、命名导出的区别》

1. 导入和导出都是引用时，最终结果才是引用
2. 导入时，对象解构会导致引用失效，如 `let { ... } = await import './module.js' `
> 参考 JS 中复制对象后再解构
3. `export default ...` 导出是值复制，**对于函数等复杂对象也适用（复制内存而非复制指针）**
4. 对于函数，3 中的值复制相当于重新定义函数，函数声明会被提升

## 205.精读《JS with 语法》

`with` 的作用是改变上下文，strict 模式下是禁止使用的。业务代码不推荐使用
```js
with(console) {
  with(['a', 'b', 'c']) {
    log(join('')); // abc
  }
}
```

非业务领域引用：
1. sandbox，利用 with 限制可访问上下文。
2. 模板引擎中，注入数据


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at October 8, 2024 17:41</small></div>
      