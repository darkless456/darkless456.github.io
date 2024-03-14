---
sidebar_position: 3
---
    
# React Hooks

## useState

`useState` is a React Hook that lets you add a state variable to your component.

```js
const [state, setState] = useState(initialState)
```

- `initialState`, the value you want the state to be initially. If you pass a function as `initialState`, it will be treated as an initializer function.
- `useState` returns an array with exactly two values:
  1. the current state.
  2. the `set function` that lets you update the state to a different value and trigger a re-render.

`set` function, like setState

`setState(nextState)`

- `nextState`, the value you want the state to be. If you pass a function as `nextState`, it will be treated as a updater function.

### Updating state based on the previous state

```js
function handleClick() {
  setAge(age + 1); // setAge(42 + 1)
  setAge(age + 1); // setAge(42 + 1)
  setAge(age + 1); // setAge(42 + 1)
}

// To solve it, you may pass a updater function

function handleClick() {
  setAge((prev) => prev + 1); // setAge((42) => 42 + 1)
  setAge((prev) => prev + 1); // setAge((43) => 43 + 1)
  setAge((prev) => prev + 1); // setAge((44) => 44 + 1)
}

// React puts your updater functions in a queue. Then, during the next render, it will call them in the same order.
```

### Storing information from previous renders

```jsx
import { useState } from 'react';

export default function CountLabel({ count }) {
  const [prevCount, setPrevCount] = useState(count);
  const [trend, setTrend] = useState(null);
  if (prevCount !== count) {
    setPrevCount(count);
    setTrend(count > prevCount ? 'increasing' : 'decreasing');
  }
  return (
    <>
      <h1>{count}</h1>
      {trend && <p>The count is {trend}</p>}
    </>
  );
}
```

Note that if you call a `set` function while rendering, it must be inside a condition like `prevCount !== count`, and there must be a call like `setPrevCount(count)` inside of the condition. Otherwise, your component would re-render in a loop until it crashes. Also, you can only update the state of the currently rendering component. Calling a `set` function of another component during rendering is an error.

This pattern is better than updating state in an effect. When you call the `set` function during render, React will re-render that component immediately after your component exits with a `return` statement, and before rendering the children. This way, children don't need to render twice. The rest of your component function will still execute (and the result will be thrown away). If your condition is below all the Hook calls, you may add an early `return` to restart rendering earlier.

## useEffect

`useEffect` is a React Hook that lets you synchronize a component with an external system.

> _Here, external system means any piece of code that's not controlled by React, such as:_
> - A timer managed with `setInterval()` and `clearInterval()`.
> - An event subscription using `window.addEventListener()` and `window.removeEventListener()`.
> - A third-party animation library with an API like `animation.start()` and `animation.reset()`.

### Reference

```js
useEffect(setup, dependencies?)
```

**Parameters**

- `setup`, the function with your Effect's logic. Your setup function may also optionally return a _cleanup_ function. When your component is added to the DOM, React will run your setup function. After every re-render with changed dependencies, React will first run the cleanup function(if provided) with the old values, and then run your setup function with the new value. After your component is removed from the DOM, React will run your cleanup function.
- optional `dependencies`, the list of all reactive values referenced inside of the setup code. Reactive values include props, state, and all the variables and functions declared directly inside your component body. The list of dependencies must have a constant number of items and be written inline like `[dep1, dep2, dep3]`. React will compare each dependency with its previous value using the `Object.is` comparison. If you omit this argument, your Effect will re-run after every re-render of the component. 

To help you find bugs, in development React runs setup and cleanup on extra time before the setup. This is a stress-test that verifies your Effect's logic is implemented correctly. If this causes visible issues, your cleanup function is missing some logic. The cleanup function should stop or undo whatever the setup function was doing.

> **Fetching data on a component mounted, there are significant downsides:**
> - Effect don't run on the server.
> - Fetching directly in Effects makes it easy to create "network waterfall". If you render the parent component, and if it fetches some data and renders children, it might cause child components start fetching their self data.
> - Fetching directly in Effects usually means you don't preload or cache data.
> - It's not very ergonomic. There's quite a bit of boilerplate code involved when writing fetch call in a way that doesn't suffer from bugs like race condition.

### Reading the latest props and state from an Effect (experimental API: useEffectEvent)

```js
// By default, when you read a reactive value from an Effect, you have to add it as a dependency

function Page({ url, shoppingCart }) {
  useEffect(() => {
    logVisit(url, shoppingCart.length);
  }, [url, shoppingCart]);
}
```

However, sometimes you'll want to read the latest props and state from an Effect without "reacting" to them.

**What if you want to log a new page visit after every url change, but not if only the shoppingCart changes?**

```js
// Effect event are not reactive and must be always be omitted from dependencies of your Effect

function Page({ url, shoppingCart }) {
  const onVisit = useEffectEvent(visitedUrl => {
    logVisit(visitedUrl, shoppingCart.length);
  })

  useEffect(() => {
    onVisit(url);
  }, [url]);
}

```

_`useEffectEvent` is a React Hook that lets you extract non-reactive logic into an Effect event._

### Displaying different content on the server and the client

```js
function MyComponent() {
  const [didMount, setDidMount] = useState(false);

  useEffect(() => {
    setDidMount(true);
  }, []);

  if (didMount) {
    // ... return client-only JSX ...
  }  else {
    // ... return initial JSX ...
  }
}
```

## useLayoutEffect

`useLayoutEffect` is a version of `useEffect` that fires before the browser repaints the screen.

> _`useLayoutEffect` can hurt performance. Prefer `useEffect` when possible._


- `useLayoutEffect` blocks the browser from repainting
- `useEffect` does not block the browser


## useContext

`useContext` is a React Hook that lets you read and subscribe to context from your component.

`useContext` returns the context value for the context you passed. To determine the context value, React searches the component tree and finds the closest context value provider above for that particular context.

```js
import { createContext, useContext, useReducer } from 'react';

const TasksContext = createContext(null);

const TasksDispatchContext = createContext(null);

export function TasksProvider({ children }) {
  const [tasks, dispatch] = useReducer(
    tasksReducer,
    initialTasks
  );

  return (
    <TasksContext.Provider value={tasks}>
      <TasksDispatchContext.Provider value={dispatch}>
        {children}
      </TasksDispatchContext.Provider>
    </TasksContext.Provider>
  );
}

export function useTasks() {
  return useContext(TasksContext);
}

export function useTasksDispatch() {
  return useContext(TasksDispatchContext);
}

function tasksReducer(tasks, action) {
  //...
}

const initialTasks = [/* ... */];
```

### Optimizing re-renders when passing objects and functions

```jsx
import { useCallback, useMemo } from 'react';

function MyApp() {
  const [currentUser, setCurrentUser] = useState(null);

  const login = useCallback((response) => {
    storeCredentials(response.credentials);
    setCurrentUser(response.user);
  }, []);

  const contextValue = useMemo(() => ({
    currentUser,
    login
  }), [currentUser, login]);

  return (
    <AuthContext.Provider value={contextValue}>
      <Page />
    </AuthContext.Provider>
  );
}
```

## useRef

`useRef` is a React Hook that lets you reference a value that's not need for rendering.

```js
useRef(initialValue)
```

- `initialValue`, the value you want the ref object's `current` property to be initially. This argument is ignored after the initial render.
- `useRef` returns an object with a single property `current`. Initially, it's set to the initialValue you have passed. If you pass the ref object to React as a `ref` attribute to a JSX node, React will set its `current` property.
- On the next renders, `useRef` will return the _same object_.
- React will set the `current` property back to null when the node is removed from the screen.
 
**Do not write or read `ref.current` during rendering, except for initialization. This makes your component's behavior unpredictable.**

React expects that that body of your component behaves like a pure function:

- If the input(props, state, and context) are the same, it should return exactly the same JSX.
- Calling it in a different order or different arguments should not affect the results of other calls.

Reading or writing a ref during rendering breaks these expectations. You can read or write refs from event handlers or effects instead. If you have to do it, use state instead.

### Exposing a ref to your own component

```jsx
import { forwardRef, useRef } from 'react';


export default function Form() {
  const inputRef = useRef(null);

  function handleClick() {
    inputRef.current.focus();
  }

  return (
    <>
      <MyInput ref={inputRef} />
      <button onClick={handleClick}>
        Click
      </button>
    </>
  )
}

const MyInput = forwardRef((props, ref) => {
  return <input {...props} ref={ref}>;
});
```

### Avoiding recreating the ref contents

```js

// Although the result of `new VideoPlayer()` is only used for the initial render, you're still calling it on next every render.
function Video() {
  const playerRef = useRef(new VideoPlayer());
}

// To solve above problem.
function Video() {
  const playerRef = useRef(null);

  if (playerRef.current === null) {
    playerRef.current = new VideoPlayer();
  }
}
```

## useReducer

`useReducer` is a React Hook that lets you add a reducer to your component.

`userReducer(reducer, initialArg, init?)`

- `reducer`, the reducer function that specifies how the state gets updated. It must be pure, should take the state and action as arguments, and should return the next state.
- `initialArg`, the value from which the initial state is calculated
- `init?`, the initializer function that should return the initial state. If it's not specified, it's set to `initialArg`. Otherwise, the initial state is set to the result of `init(initialArg)`.

### Avoiding recreating the initial state

React saves the initial state once and ignores it on the next renders.

```js
function createInitialState(username) {
  // ...
}

function App() {
  // ...
  const [state, dispatch] = useReducer(reducer, createInitialState(username));
  // ...
}
```

Although the result of `createInitialState(username)` is only used for the initial render, you're still calling this function on next every render.

To solve this, you may pass it as an initializer function:

```js
// ...

function App() {
  // ...
  const [state, dispatch] = useReducer(reducer, username, createInitialState);
  // ...
}
```

In above example, it passes `createInitialState` as a initializer function to `useReducer`, so the `createInitialState` function only runs during initialization.

## useCallback

`useCallback` is a React Hook that lets you cache a function definition between re-renders. 

Caching a function with `useCallback` is only valuable in a few cases:

- You pass it as a prop to a component wrapped in `memo`. You want to skip re-rendering if the value hasn't changed.
- The function you're passing is later used as a dependency of some Hook. For example, another function wrapped in `useCallback` depends on it, or you depend on this function from `useEffect`

Note that `useCallback` does not prevent creating the function. You're always creating a function, but React ignores it and gives you back a cached function if nothing changed.

## useMemo

`useMemo` is a React Hook that lets you cache the result of a calculation between re-renders.

### How to tell if a calculation is expensive

Add a console log to measure the time spent in a piece of code:

```js
console.time('filter todo items');
const results = filterTodoItems(todoItems, tabName);
console.timeEnd('filter todo items');
```

Perform the interaction you're measuring. You will then see logs like `filter todo items: 0.15ms` in your console. If the overall logged time adds up to a significant amount(e.g 1ms or more), it might make sense to memorize that calculation.

Optimizing with `useMemo` is only valuable in few cases:

- The calculation you're putting in `useMemo` is noticeably slow, and its dependencies rarely change.
- You pass it as a prop to a component wrapped in `memo`. You want to skip re-rendering if the value hasn't changed.
- The value you're passing is later used as a dependency of some Hook. Such as, maybe another `useMemo` calculation value depends on it.

## useTransition

`useTransition` is a React Hook that lets you update the state without blocking the UI.

```js
const [isPending, startTransition] = useTransition();
```

- The `isPending` flag that tells you whether there is a pending transition.
- The `startTransition` function that lets you mark a state update as a transition.

### Updating the parent component in a transition

```jsx
export default function TabButton({ children, isActive, onClick }) {
  const [isPending, startTransition] = useTransition();
  if (isActive) {
    return <b>{children}</b>
  }
  return (
    <button onClick={() => {
      startTransition(() => {
        onClick();
      });
    }}>
      {children}
    </button>
  );
}
```

The parent component updates its state inside the `onClick` event handler, that state update gets marked as a transition. Updating the selected tab is marked as a transition, so it does not block UI.

### Building a Suspense-enabled router

```js
// The benefit for this way is transitions are interruptible, which lets the user click away without waiting for the re-render to complete.
function Router() {
  const [page, setPage] = useState('/');
  const [isPending, startTransition] = useTransition();

  function navigate(url) {
    startTransition(() => {
      setPage(url);
    });
  }
}
```

### Displaying an error to users with an error boundary (experimental)

```jsx
function AddCommentContainer() {
  return (
    <ErrorBoundary fallback={<p>Something went wrong!</p>}>
      <AddCommentButton />
    </ErrorBoundary>
  );
}

function addComment() {
  throw new Error('Error occurs in addComment');
}

function AddCommentButton() {
  const [isPending, startTransition] = useTransition();

  return (
    <button
      disabled={isPending}
      onClick={() => {
        startTransition(() => {
          addComment();
        });
      }}
    >
      Click
    </button>
  );
}

```

## other Hooks

### use (experimental)

`use` is a React Hook that lets you read the value of a resource like Promise or context.

```js
import { use } from 'react';

function MessageComponent( { messagePromise }) {
  const message = use(messagePromise);
  const theme = use(ThemeContext);
}
```

Unlike all other React Hooks, `use` can be called within loops and conditional statements like `if`. Like other React Hooks, the function that call `use` must be a Component or Hook.

#### Streaming data from the server to the client

```jsx
// App.js (server component)

import { fetchMessage } from '...';
import Message from './message.js';

export default function App() {
  const messagePromise = fetchMessage();

  return (
    <Suspense fallback={<p>loading for message ...</p>}>
      <Message messagePromise={messagePromise} />
    </Suspense>
  )
}
```

```jsx
// message.js (client component)

'use client';

import { use, Suspense } from 'react';
impot { ErrorBoundary } from 'react-error-boundary';

function Message({ messagePromise }) {
  const message = use(messagePromise);
  return <p>Here is the message: {message}</p>
}

export default function MessageContainer({ messagePromise }) {
  <ErrorBoundary fallback={<p>something went wrong!</p>}>
    <Suspense fallback={<p>downloading for message ...</p>}>
      <Message messagePromise={messagePromise} />
    </Suspense>
  </ErrorBoundary>
}

```

### useDebugValue

`useDebugValue` is a React Hook that lets you add a label to a custom Hook in React DevTools.

```js
import { useDebugValue } from 'react';

function useOnlineStatus() {
  // ...
  useDebugValue(isOnline? 'Online': 'Offline');
  // ...
}
```

This gives components calling `useOnlineStatus` a label like `OnlineStatus` when you inspect them:

![useDebugValue](./assets/react-devtools-usedebugvalue.png)

### useDeferredValue

`useDeferredValue` is a React Hook that lets you defer updating a part of the UI.

There is no fixed delay caused by `useDeferredValue` itself. As soon as React finishes the original re-render, React will immediately start working on the background re-render with the new deferred value. Any updates caused by event (e.g typing) will interrupt the background re-render process and get prioritized over it. In other words, if you type again, React will abandon it and restart with the new value. React will always use the latest provided value.

#### How is deferring a value different from debouncing and throttling?

- Debouncing means you'd wait for the user to stop typing before updating the list.
- Throttling means you'd update the list every once in a while.

Unlike debouncing and throttling, `useDeferredValue` doesn't require choosing any fixed delay. If the user's device is fast, the deferred re-render would happen almost immediately and wouldn't be noticeable. If the user's device is slow, the list would "lag behind" the input proportionally to how slow the device is.

Also, unlike with debouncing and throttling, deferred re-renders done by `useDeferredValue` are interruptive by default. This means that if React is in the middle of re-rendering a large list, but the user makes another keystroke, React will abandon that re-render, handle the keystroke, and then start rendering in background again.

**If the work you're optimizing doesn't happen during rendering, debouncing and throttling are still useful.** For example, they can let you fire fewer network request.

```jsx
// indicating the content is stale

<div style={{
  opacity: query !== deferredQuery ? 0.5 : 1,
}}>
  <SearchResults query={deferredQuery} />
</div>
```

### useId

`useId` is a React Hook for generating unique IDs that can be passed to accessibility attributes.

`useId` returns a unique ID string associated with this particular useId call in this particular component.

```jsx
// general usage

function PasswordField() {
  const passwordHintId = useId();
  return (
    <>
      <label>
        Password:
        <input
          type="password"
          aria-describedby={passwordHintId}
        />
      </label>
      <p id={passwordHintId}>
        The password should contain at least 18 characters
      </p>
    </>
  )
}
```

_Inside React, `useId` is generated from the "parent path" of the calling component. This is why, if the client and the server tree are the same, the "parent path" will match up regardless of rendering order._

### useImperativeHandle

`useImperativeHandle` is a React Hook that lets you customize the handle exposed as a ref.

```js
import { forwardRef, useImperativeHandle } from 'react';

const MyInput = forwardRef(function MyInput(props, ref) {
  useImperativeHandle(ref, () => {
    return {
      // ... your methods
    }
  }, []);

  // ...
});
```

#### Exposing your own imperative methods

```js
// App.js

import { useRef } from 'react';
import MyInput from './MyInput.js';

export default function Form() {
  const ref = useRef(null);

  function handleClick() {
    ref.current.focus();
    // This won't work because the DOM node isn't exposed:
    // ref.current.style.opacity = 0.5;
  }

  return (
    <form>
      <MyInput placeholder="Enter your name" ref={ref} />
      <button type="button" onClick={handleClick}>
        Edit
      </button>
    </form>
  );
}
```

```jsx
// MyInput.js

import { forwardRef, useRef, useImperativeHandle } from 'react';

const MyInput = forwardRef(function MyInput(props, ref) {
  const inputRef = useRef(null);

  useImperativeHandle(ref, () => {
    return {
      focus() {
        inputRef.current.focus();
      },
      scrollIntoView() {
        inputRef.current.scrollIntoView();
      },
    };
  }, []);

  return <input {...props} ref={inputRef} />;
});

export default MyInput;
```

### useInsertionEffect

`useInsertionEffect` allows inserting elements into the DOM before any layout effect fire.

> `userInsertionEffect` is for CSS-in-JS library authors. Unless you are working on a CSS-in-JS library and need a place to inject the styles, you probably want `useEffect` or `useLayoutEffect` instead.

We don't recommend runtime `<style>` tag injection for 2 reasons:

1. Runtime injection forces the browser to recalculate the styles a lot more often.
2. Runtime injection can be very slow if it happens at the wrong time in the React lifecycle.

The first problem is not solvable, but `useInsertionEffect` helps you solve the second problem.

Call `useInsertionEffect` to insert the styles before any layout effects fire:

```jsx
// Inside your CSS-in-JS library

const isInserted = new Set();

function useCSS(rule) {
  useInsertionEffect(() => {
    if (!isInserted.has(rule)) {
      isInserted.add(rule);
      document.head.appendChild(getStyleForRule(rule));
    }
  });
  return rule;
}

function Button() {
  const className = useCSS('...');
  return <div> className={className} />
}
```

### useOptimistic (experimental)

`useOptimistic` is a React Hook that lets you optimistically update the UI.

```js
import { useOptimistic } from 'react';

function AppContainer() {
  const [optimisticState, addOptimistic] = useOptimistic(
    state,
    // updateFn
    (currentState, optimisticValue) => {
      // merge and return new state
      // with optimistic value
    }
  );
}
```

#### Optimistically updating form

```jsx

function Thread({ messages, sendMessage }) {
  const formRef = useRef();

  const [optimisticMessages, addOptimisticMessage] = useOptimistic(
    messages,
    (state, newMessage) => {
      ...state,
      {
        text: newMessage,
        sending: true,
        key: state[state.length - 1].key + 1
      }
    }
  );

  async function formAction(formData) {
    addOptimisticMessage(formData.get('message'));
    formRef.current.reset();
    await sendMessage(formMessage);
  }

  return (
    <>
    {
      optimisticMessages.map((message, index) => (
        <div key={message.index}>
          {message.text}
          {!!message.sending && <small> (Sending...)</small>}
        </div>
      ))
    }
      <form action={formAction} ref={formRef}>
        <input type='text' name='message' />
        <button type='submit'>Send</button>
      </form>
    </>
  );
}


export default function App() {
  const [messages, setMessages] = useState([
    { text: 'hello react!', sending: false, key: 1 }
  ])

  async function sendMessage(formData) {
    const sentMessage = await deliverMessage(formData.get('message'));
    setMessages((messages) => [ ...messages, { text: sentMessage, sending: false, key: messages[message.length - 1].key + 1 }]);
  }

  return <Thread messages={messages} sendMessage={sendMessage} />
}

async function deliverMessage(message) {
  await new Promise((resolve) => setTimeout(resolve, 1000));
  return message;
}
```

### useSyncExternalStore

`useSyncExternalStore` is a React Hook that lets you subscribe to an external store.

```js
const snapshot = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot?)
```

- `subscribe`, a function that takes a single `callback` argument and subscribes it to the store.
- `getSnapshot`, a function that returns a snapshot of the data in the store.
- `getServerSnapshot?`, a function that returns the initial snapshot of the data in the store. It will be used only during server rendering and during hydration of server-rendered content on the client. There would be an error if omit this argument in SSR.
- Returns the current snapshot of the store.

#### Subscribing to a browser API

```jsx
const store = (function customStore() {
  function getSnapshot() {
    return navigator.online;
  }

  function subscribe(cb) {
    window.addEventListener('online', callback);
    window.addEventListener('offline', callback);

    return () => {
      window.removeEventListener('online', callback);
      window.removeEventListener('offline', callback);
    }
  }

  return {
    getSnapshot,
    subscribe
  }
}())


function App() {
  const snapshot = useSyncExternalStore(store.subscribe, store.getSnapshot);
}

```

#### Extracting the logic to a custom Hook

Usually you won't write `useSyncExternalStore` directly in your component. Instead, you'll typically call it from your own custom Hook. This lets you use the same external store from different components.

```js
export function useOnlineStatus() {
  const isOnline = useSyncExternalStore(subscribe, getSnapshot);
  return isOnline;
}

function getSnapshot() {
  // ...
}

function subscribe() {
  // ...
}
```

#### Adding support for server rendering

```js
export function useOnlineStatus() {
  const isOnline = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}

function getSnapshot() {
  // ...
}

// will run on the server when generating the HTML
// will run on the client during hydration.
function getServerSnapshot() {
  return true;
}

function subscribe() {
  // ...
}
```

> Make sure that `getServerSnapshot` returns the same exact data on the initial client render as it returned on the server. One way to do this is to emit a `<script>` tag during server rendering that sets a global like `window.MY_STORE_DATA`, and read from that global on the client in `getServerSnapshot`.

### useFormState (experimental)

`useFormState` is a Hook that allows you to update state based on the result of a form action.

```js
const [formState, formAction] = useFormState(fn, initialState, permalink?);
```

- `fn`, the function to be called when the form is submitted or button pressed. When the function is called, it will receive the previous state of the form as its initial argument, followed by the arguments that a form action normally receives.
- `initialState`, the value you want the state to be initially.
- `permalink`, a string containing the unique page URL that this form modifies.

#### Using information returned by a form action

```jsx
function MyComponent() {
  const [formState, formAction] = useFormState(action, null);

  // ...

  return (
    <form action={formAction}>
      {/* ... */}
    </form>
  )
}

function action(prevState, formData) {
  // ...
  return 'new state';
}
```

### useFormStatus (experimental)

`useFormStatus` is a Hook that gives you status information of the last form submission.

```js
const { pending, data, method, action } = useFormStatus();
```

- `pending`, if true, this means the parent `form` is pending submission.
- `data`, the data from the parent `form` that is submitting. If there's no active submission, it will be null.
- `method`, a string value of either `get` or `post`.
- `action`, a reference to the function passed to the `action` prop on the parent `form`. If there is no parent `form`, a URL provided to `action` props, or no `action` prop specified, it will be null.

Note that:

- The `useFormStatus` must be called from a component that is rendered inside a `form`
- `useFormStatus` will only return status information for a parent `form`.

#### Display a pending state during form submission

```jsx
function Submit() {
  const { pending } = useFormStatus();
  return (
    <button type='submit' disabled={pending}>
      {pending ? 'Submitting' : 'Submit'}
    </button>
  )
}

function Form({ action }) {
  return (
    <form action={action}>
      <Submit />
    </form>
  )
}
```

## Caveats

1. When fetching data in a Server Component, prefer `async` and `await` over `use`. `async` and `await` pick up rendering from the point where `await` was invoked, whereas `use` re-renders the component after the data is resolved.
2. Prefer creating Promises in Server Components and passing them to Client Components over creating Promises in Client Components. Promises created in Client Components are recreated on every render. Promises passed from a Server Component to a Client Component are stable across re-renders.
3. React will not throw away the cached function unless there is a specific reason to do that. For example, in dev, React throws away the cache when you edit the file.
4. By default, when a component re-renders, React re-renders all of its children recursively.
5. React automatically re-renders all the children that use a particular context starting from the provider that receives a different value. The previous and the next values are compared with the `Object.is` comparison. Skipping re-renders with `memo` does not prevent the children receiving fresh context values.
6. If you're not trying to synchronize with some external system, you probable don't need an Effect.
7. If your Effect wasn't caused by an interaction(like a click), React will generally let the browser paint the updated screen first before running your Effect. If your Effect is doing something visual(like positioning a tooltip), and the delay is noticeable, replace `useEffect` with `useLayoutEffect`. 
8. Even if your Effect was caused by an interaction, the browser may repaint the screen before processing the state updates inside your Effect. However, if you must block the browser from repainting the screen, you need to replace `useEffect` with `useLayoutEffect`.
9. Effects only run on the client. They don't run during server rendering.
10. You can't update state from inside `useInsertionEffect`.
11. By the time `useInsertionEffect` runs, refs are not attached yet.
12. `useInsertionEffect` may run either before or after the DOM has been updated.
13. Unlike other types of Effects, which fire clean for every Effect and then setup for every Effect, `useInsertionEffect` will fire both cleanup and setup on component at a time. This results in an "interleaving" of the cleanup and setup functions.
14. You can mutate the `ref.current` property. Unlike state, it's mutable. However, if it holds an object that is used for rendering (like, a piece of state), then you shouldn't mutate that object.
15. When you change the `ref.current` property, React does not re-render your component. Because a ref is a plain JavaScript object.
16. The `set` function only updates the state variable for the next render.
17. If the new value you provide is identical to the current `state`, as determined by an `Object.is` comparison, React will skip re-rendering the component and its children.
18. Calling the `set` function during rendering is only allowed from within the currently rendering component. React will discard its output and immediately attempt to render it again with the new state.
19. You can wrap an update into a transition only if you have access to the `set` function of that state.
20. The function you pass to `startTransition` must be synchronous. React immediately executes this function, marking all state updates that happen while it executes as transitions.
21. A state update marked as a transition will be interrupted by other state updates.
22. Transition updates can't be used to control text inputs.
23. If there are multiple ongoing transitions, React currently batches them together. This is a limitation that will likely be removed in a future release.


## Principles

### Memoization

**In practice, you can make a lot of memoization unnecessary by following a few principles:**

1. __When a component visually wraps other components, let it accept JSX as children.__ Then, if the wrapper component updates its own state, React knows that its children don't need to re-render.
2. __Prefer local state and don't lift state up any further than necessary.__ Don't keep transient state like forms and whether an item is hovered at the top of your tree or in a global state library.
3. __Keep your rendering logic pure.__ If re-rendering a component causes a problem or produces some noticeable visual artifact, it's a bug in your component.
4. Avoid unnecessary Effects that update state. Most performance problems in React apps are caused by chains of updates originating from Effects that cause your components to render over and over.
5. Try to remove unnecessary dependencies from your Effects. For example, instead of memoization, it's often simpler to move some object or a function inside an Effect or outside the component.

## Recommendations

### CSS-in-JS

If you use CSS-in-JS, we recommend a combination of the first 2 approaches (CSS files for static styles, inline styles for dynamic styles.).

If you insert styles during rendering and React is processing a non-blocking update, the browser will recalculate the styles every single frame while rendering a component tree, which can be extremely slow.

`useInsertionEffect` is better than inserting styles during `useLayoutEffect` or `useEffect` because it ensures that by the time other Effects run in your component, the `<style>` tags have already been inserted. Otherwise, layout calculations in regular Effects would be wrong due to outdated styles.

## References

- [React Hook 系列(一)：彻底搞懂react-hooks 用法](https://segmentfault.com/a/1190000021261588)


<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at March 14, 2024 14:24</small></div>
      