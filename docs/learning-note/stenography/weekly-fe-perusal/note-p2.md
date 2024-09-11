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



<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at September 11, 2024 17:46</small></div>
      