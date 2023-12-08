---
sidebar_position: 5
---
    
<small style={{color: '#cccccc'}}>last modified at December 8, 2023 7:10 AM</small>
# JavaScript Prototype

## 概述

JavaScript 中的继承只有一种结构：对象。

每个实例对象（object）都有一个私有属性（__proto__）指向其构造函数的原型对象（prototype）。该原型对象也有一个自己的原型对象（__proto__），层层向上直到一个对象的原型对象为**null**。

> **null** 没有自己的原型对象，作为原型链的最顶端。

> 大部分 JS 对象都是原型链顶 **Object** 的实例，除 **{} 字面量**、**Symbol**、**BigInt** 等少数例外。

## 继承

### 原型对象

每个 JS 对象（null 除外）在创建的时候就会与之关联的另一个对象，JS 对象会从该对象**”继承“**属性方法。

```js
const oneObj = new Object();
// 根据 ES 标准
// oneObj.[[Prototype]]
// 等价于非标准但被许多浏览器实现的 __proto__
// oneObj.__proto__ = oneObj.prototype
// 从 ES6 开始，Object.getPrototypeOf() 和 Object.setPrototypeOf() 可以分别访问和设置 Object 对象的原型

// prototype 是函数才有的属性
new Function().prototype; // {}
Object.prototype; // {}
new String().prototype; // undefined
new String().prototype.constructor; // String
```

### 原型链

```js
// Chrome 96
function doSomething() {} // === let doSomething = function() {};
console.log(doSomething.prototype); // 对于非函数对象，prototype 需要替换为 __proto__
// {
//   constructor: ƒ ()  // 构造函数
//   [[Prototype]]: {
//     constructor: ƒ Object() // 原型对象的 constructor 指向其构造函数
//     ...snip
//     __proto__: Object // 非标准对象，用于访问对象的原型，等价于 [[Prototype]]
//     get __proto__: ƒ __proto__()
//     set __proto__: ƒ __proto__()
//   }
// }

doSomething.prototype.foo = 'bar';
console.log(doSomething.prototype);
// {
//   foo: "bar", // 原型对象上的属性
//   constructor: ƒ ()  // 构造函数
//   [[Prototype]]: { ...snip }
// }

doSomething.prop = 'some prop';
console.log(doSomething.prototype.prop); // undefined

const doSomethingInstance = new doSomething();
doSomethingInstance.instanceProp = 'instance prop';
console.log(doSomething.prototype === doSomethingInstance.prototype); // true
console.log(doSomethingInstance.prototype.instanceProp); // undefined
console.log(doSomethingInstance.instanceProp); // 'instance prop'
console.log(doSomethingInstance.foo); // 'bar'
// 属性查找规则：
// 1. 在 doSomethingInstance 中查找是否存在 foo 属性，如不存在则继续下面的查找。
// 2. 继续在 doSomethingInstance.prototype 中查找 foo 属性，如不存在则继续下面的查找。
// 3. 继续在 doSomethingInstance.prototype.prototype 即 doSomething.prototype.prototype 中查找 foo 属性。
// 4. 当前示例，doSomething.prototype.prototype 默认情况会是 window.Object.prototype。
// 5. 在 window.Object.prototype 中仍然没有找到 foo 属性，则会向上查找到 window.Object.prototype.prototype, 即 null。
// 6. null 是没有自己的原型对象，即不存在 null.prototype。
// 7. 此时，查找结果会返回 undefined，本次查找结束。

// null === window.Object.prototype.prototype
// window.Object.prototype === doSomething.prototype.prototype
// doSomething.prototype === doSomethingInstance.prototype
// doSomethingInstance
```

上述查找过程中，由 `prototype`(__proto__) 所串连形成的一条链，称之为原型链。

> 沿着原型链，属性/方法被自上而下地继承，自下而上地查找属性/方法

## 创建对象

### `new`

```js
function Foo(test) {
  this.test = test;
}

// 不建议直接使用 Foo.prototype = { add: function() {...} }，会整个覆盖原有的原型对象
Foo.prototype.add = function(newTest) {
  this.test += newTest;
}

let foo = new Foo('a');
console.log(foo.test); // 'a'
foo.add(' b');
console.log(foo.test); // 'a b'
```

### `Object.create`

```js
let a = { a: 1 }; // prototype chain: a -> Object.prototype -> null

let b = Object.create(a); // chain: b -> a -> Object.prototype -> null

let c = Object.create(b); // chain: c -> b -> a -> ...

let d = Object.create(null); // chain: d -> null，不会继承 Object.prototype 的一系列属性方法
```

### `class`

```js
class SuperClass {
  constructor(length) {
    this.length = length;
  }
}

class ChildClass {
  constructor(sideLength) {
    super(sideLength);
  }

  get area() {
    return this.length * this.length;
  }
}

new ChildClass(5);
```

### 对象字面量

```js
let a = {}; // === new Object()
let b = []; // === new Array()
let c = /abc/; // === new RegExp('abc')
```

## 扩展原型对象

```js
function Foo() {}

let foo = new Foo();
```

修改 foo 的原型对象有以下方法：

- 设置对象的 `prototype`，优点：快速，可被 JIT 优化；缺点：可能产生冗余的属性方法。

- `Object.create`，优点：可创建原型对象是 null 的对象，可被解释器优化；缺点：当第二个参数对象过大时，性能开销大。

- `Object.setPrototypeOf`，优点：可动态增减原型；缺点：干扰解释器的优化

- 设置对象非标准的 `__proto__`，优点：新的原型不是对象时会失败，不报错；缺点：同上，干扰解释器优化

      