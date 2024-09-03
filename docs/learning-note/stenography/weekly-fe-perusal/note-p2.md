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


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at September 3, 2024 17:06</small></div>
      