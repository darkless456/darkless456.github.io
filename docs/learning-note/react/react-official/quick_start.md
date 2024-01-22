---
sidebar_position: 1
---
    
# Quick Start

## How to create and nest components

React apps are made up of components. A component is a piece of the UI that has its own logic and appearance.

```jsx
function MyComponent() {
  return <div>My Component</div>
}

export default App() {
  return (
    <div>
      <h1>Welcome to App Component</h1>
      <MyComponent />
    </div>
  )
}
```

Notice that `<MyComponent />` starts with a capital letter. That's how you know it's a React Component. React component names must always start with a capital letter, while HTML tags must be lowercase.

## How to add makeup and styles

The makeup syntax you've seen above is called JSX. JSX is stricter than HTML. You have to close tags like `<br />`. Your component also can't return multiple JSX tags. You have to wrap them into a shared parent, like a `<div>...</div>` or an empty `<>...</>` wrapper.

```jsx
export default App() {
  return (
    <>
      <h1>Welcome to App Component</h1>
      <MyComponent />
    </>
  )
}
```

In React, you specify a CSS class with `className`. It works the same way as the HTML `class` attribute.

```jsx
<img className="avatar" />
```

```css
.avatar {
  width: 50px;
  height: 50px;
}
```

## How to display data

JSX lets you put makeup into JS. Curly braces let you "escape back" into JS so that you can embed some variables from your code and display it.

```jsx
return (
  <h1>
    {user.name}
  </h1>
)
```

## How to render conditions and lists

In React, there is no special syntax for writing conditions. Instead, you'll use the same techniques as you use when writing regular JS code.

```jsx
let content

if (isLoggedIn) {
  content = <AdminPanel />
} else {
  content = <LoginForm />
}

return (
  <div>
    {content}
  </div>
)
```

If you prefer more compact code, you can use the conditional `?` operator. Unlike `if`, it works inside JSX:

```jsx
<div>
  {isLoggedIn ? (
    <AdminPanel />
  ) : (
    <LoginForm />
  )}
</div>
```

When you don't need the `else` branch, you can also use the shorter logical `&&` syntax:

```jsx
<div>
  {isLoggedIn && <AdminPanel />}
</div>
```

You will rely on JS features like `for` loop and the array `map` method to render lists of components.

```jsx
const products = [
  { title: 'T1', id: 1 },
  { title: 'T2', id: 2 },
  { title: 'T3', id: 3 }
]

const listItems = products.map(product => <li key={product.id}>{product.title}</li>)
```

Notice how `<li>` has a `key` attribute. For each item in a list, you should pass a string or a number that uniquely identifies that item among its siblings. React uses your keys to know what happened if you later insert, delete, or recorder the items.

## How to respond to events and update the screen

You can respond to event by declaring __event handler__ functions inside your components:

```jsx
function MyComponent() {
  const handleClick = () => {
    console.log('clicked!')
  }

  return (
    <button onClick={handleClick}>
      Click me
    </button>
  )
}
```

Often, you'll want your component to "remember" some information and display it. To do this, add state to your component:

```jsx
import { useState } from 'react'

function MyComponent() {
  const [count, setCount] = useState(0)

  const handleClick = () => {
    setCount(count + 1)
  }

  return (
    <button onClick={handleClick}>
      Clicked {count} times
    </button>
  )
}
```

Functions starting with `use` are called __Hooks__, Hooks are more restrictive than other functions. You can only call Hooks at the top of your component or other Hooks. If you want to use Hooks in a condition or a loop, extract a new component and put it there.

## How to share data between components

In React, you can share data between components via passing props.

```jsx
function MyComponent(props) {
  const { count, onClick } = props

  return (
    <button onClick={onClick}>
      Clicked {count} times
    </button>
  )
}

function App() {
  const [count, setCount] = useState(0)

  const handleClick = () => {
    setCount(count + 1)
  }

  return (
    <div>
      <MyComponent count={count} onClick={handleClick} />
      <MyComponent count={count} onClick={handleClick} />
    </div>
  )
}

```

<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at January 22, 2024 15:45</small></div>
      