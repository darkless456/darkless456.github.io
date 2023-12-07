---
sidebar_position: 6
---
    
<small color="#ccc">last modified at 2023/12/7 8:44:3</small>
# JavaScript Secret Garden

## 对象

### 对象的使用

JavaScript 中所有的变量都可以当作**对象**使用，除了 `null` 和 `undefined`。

```js
false.toString(); // 'false'
[1,2,3].toString(); // '1,2,3'

function Foo() {}
Foo.bar = 1;
Foo.bar; // 1
```

因为 JavaScript 解析器的规则问题，dot 操作符（.）解析行为会在某些情况下产生奇特的行为。

```js
// 例如 数字的字面值
2.toString(); // SyntaxError，解析器试图将 . 操作符解释为字面值的一部分，即 2.(=== 2)

// 一些变通的方法
2..toString(); // 2. => 2 => 2.toString()
2 .toString(); // 点号前有空格
(2).toString();
new Number(2).toString();
Number(2).toString();
parseInt(2, 10).toString();
```

### 创建属性

对象的属性名可以使用字符串或普通字符声明。

```js
let obj = {
  'case': 'I\'m a keyword so I must be notated as a string',
  delete: 'I\'m also a key word', // SyntaxError
}
```

`delete` 是一个关键字，在 `ES5` 之前会抛出错误。

创建动态属性应使用 `[]` 操作符。

```js
// 动态属性
let my_key = 'name';
{ [my_key]: 'tom' }; // { name: 'tom' }
```

### 访问属性

访问对象属性的两种方式：`.` 和 `[]`。

```js
let foo = { name: 'tom' };
foo.name === foo['name']
```

两种方式在大多数情况下是等价的，但以下情况只可使用 `[]`：

- 属性名不符合变量的命名规则，例如 含有空格、与关键字冲突、非英字母等。

```js
let my_obj = { 'my-name': 'tom' };
my_obj.my-name; // 报错，错误类型不确定，如当前可能是 reference error
my_obj['my-name']; // 'tom'
```

### 删除属性

删除属性唯一的方法是 `delete` 操作符；设置属性为 `undefined` 或 `null` 仅仅是移除属性与值的关联。

```js
let obj = {
  name: 'tom',
  sex: 'm',
  age: 22,
}

obj.name = undefined;
obj.sex = null;
delete obj.age; // 真正的从 obj 中删除 age
```

### hasOwnProperty

判断对象是否包含*自定义属性*而不是原型链上的属性。

`hasOwnProperty` 不会查找原型链（和 `Object.keys` 相同），从而在必要时排除原型链上属性的干扰。

```js
Object.prototype.bar = 1;
let foo = { goo: undefined };

foo.bar; // 1
'bar' in foo; // true

foo.hasOwnProperty('bar'); // false
foo.hasOwnProperty('goo'); // true
```

在不能保证 `hasOwnProperty` 不会被意外改写时，建议使用 `Object.prototype.hasOwnProperty` 代替。

`for ... in` 在遍历对象的属性时，跟 `in` 操作符一样，也会查找原型链。所以如果不希望原型链的属性干扰，需要使用 `hasOwnProperty` 过滤。

`for ... in` 不会遍历 `enumerable` 为 false 的属性，例如 数组的 length

## 函数

### 函数声明和表达式

```js
// 声明
foo(); // 正常运行。在预编译阶段，foo 已经被 hoist 到代码顶部。
function foo() {}

// 表达式
foo; // undefined，预编译时变量 hoisting
foo(); // TypeError，匿名函数还未赋值给 foo
let foo = function() {};

// 命名函数的赋值表达式
let foo = function bar() {
  bar(); // 正常运行，函数内部始终可见 bar
}
bar(); // ReferenceError，在IE8及以下外部可见但解析有问题
foo(); // 正常运行，但如果不加限制会有爆栈的问题
// 说明：浏览器对命名函数的赋值表达式的解析有问题，解析成两个函数 foo 和 bar
```

### `this`

JavaScript 跟有些语言对 `this` 指针处理机制不同，是动态的。

#### 默认行为：

```js
// 全局范围内
this; // 全局对象，例如 global(node.js), window(browser), undefined(browser strict mode)

// 函数声明
function foo() {
  this; // 全局对象
}
foo();

// 命名函数的赋值表达式
let bar = function foo() {
  console.log(this);
}
bar(); // 全局对象

// 方法调用
let obj = {
  test: function() {
    this;
  }
}
obj.test(); // obj 对象

// new 关键字
function Foo() {
  this.name = 'name'; // 新创建的实例对象
}

// 方法的赋值表达式
let obj = {
  test: function() {
    console.log(this);
  }
}
let test = obj.test;
test(); // 全局对象

// 对象的属性是函数
let obj = {};
obj.bar = function foo() {
  console.log(this);
}
obj.bar(); // obj 对象

let bar = obj.bar;
bar(); // 全局对象
```

#### 显式设置：

```js
function foo(a, b, c) {}

let bar = {};

foo.apply(bar, [1, 2, 3]);

foo.call(bar, 1, 2, 3);

foo.bind(bar)(1, 2, 3);
```

[更多关于 this 指针](./this.md)

### 闭包

#### 模拟私有变量

```js
function Counter(start) {
  let count = start;
  return {
    increment: function() {
      count++;
    },
    get: function() {
      return count;
    }
  }
}
let foo = Counter(0);
foo.increment();
foo.get(); // 1
// count 变量只存在于 Counter 作用域内
```

#### 循环中的闭包

```js
for(var i = 0; i < 10; i++) { // i 变量会被 hoist 至循环之外
  setTimeout(function() {
    console.log(i); // 输出 10 个 10
  }, 500)
}
// console.log 调用时是引用外部变量 i（同一个作用域）。此例中 for 循环结束后，setTimeout 中的回调才会调用，此时 i 已经被修改成 10。
// 等价于
let i; // i 在外部作用域
for(i = 0; i < 10; i++) {
  setTimeout(function() {
    console.log(i);
  }, 500);
}

// 让每个 i 拥有单独的作用域
// 利用函数的参数对基本数据类型是值赋值的特性，将 i 的值所在作用域变为函数内部。
let i;
for(i = 0; i < 10; i++) {
  function(i) { // 此时 i 如果是基本数据类型，会 copy 外部 i 的值到函数作用域，从而脱离原有作用域。
    setTimeout(function() {
      console.log(i);
    }, 500);
  }
}
// 或者匿名包装器
let i;
for(i = 0; i < 10; i++) {
  setTimeout((function(e) {
    return function() {
      console.log(e);
    }
  })(i), 500);
}

// 块级作用域
for(let i = 0: i < 10; i++) {
  // 当前循环的 i 值进入该块级作用域，相当于 let i = i
  setTimeout(function() {
    console.log(i); // 引用的 i 是当前循环所在作用域，与其他 i 不是同一作用域
  }, 500);
}
```

### `arguments`

JavaScript 的函数会在内部创建一个特殊变量 `arguments`，维护着传入函数运行时的实际参数列表。

> 箭头函数不存在 `arguments` 特殊变量。

普通函数内可以对 `arguments` 进行覆盖定义，导致默认 `arguments` 不被创建。

```js
function foo() {
    console.log(arguments); // ReferenceError: Cannot access 'arguments' before initialization
    let arguments = 'args';
    console.log(arguments);
}
```

#### 自动更新（非 strict mode）**

`arguments` 对象会为其内部属性和函数形参创建 *getter* 和 *setter* 方法（非 strict mode）。

改变形参的值会影响 `arguments` 对象。

```js
function foo(a, b, c) {
  arguments[0] = 2;
  a; // 2

  b = 4;
  arguments[1]; // 4

  let d = c; // 简单类型的值 copy 
  d = 9;
  c; // 3
}
foo(1, 2, 3);
```

#### 严格模式下 `arguments` 的行为

```js
function foo(a, b) {
  'use strict';

  a = 42;
  return [a, arguments[0]];
}
let result = foo(1, 2); // 42, 1  改变形参的值不会影响 arguments 对象
```

#### `arguments.callee`

`callee` 是 `arguments` 对象的属性，它可以用于引用该函数的函数体内当前正在运行的函数。该属性在 ES5 之后的 `strict mode` 模式下被**禁用**。

**为什么会有 `callee`**

早于 ES3 版本的 JavaScript 不允许使用命名函数表达式，这样就不能创建递归函数表达式。

```js
let array = [1, 11, 2, 12, 13];

// 以下代码可以运行
function foo(n) {
  return n < 10 ? 1 : foo(n-1) * n;
}
array.map(foo);

// 当使用匿名函数时
array.map(function(n) {
  return n < 10 ? 1 : arguments.callee(n-1) * n; // 引入 callee 作为当前执行函数的引用。
})

// ES3 支持命名函数表达式后
array.map(function foo(n) {
  return n < 10 ? 1 : foo(n-1) * n;
})
// 好处：
// 函数可以像代码内部其他函数一样被调用
// 不会在外部作用域中创建一个变量（除了 IE8 及以下）
// 比访问 arguments 对象有更好的性能
```

**为什么废弃这个 API**

- 通常情况，不可能实现内联和尾递归。

- 当递归调用时会获取到不同的 this 值

**没有替代方案的情况**

```js
function createPerson(id) {
  let person = new Function("alert(arguments.callee.identity);"); // 使用 Function 构造函数
  person.identity = id;
  return person
}

let tom = createPerson("Tom Ham");
tom();
```

### `call/apply`

#### 解绑定包装器

```js
function Foo() {}

Foo.prototype.method = function(a, b, c) {
  console.log(this, a, b, c);
}

Foo.method = function() {
  Function.call.apply(Foo.prototype.method, arguments);
}
// 等价于
Foo.method = function() {
  let args = Array.prototype.slice.call(arguments);
  Foo.prototype.method.apply(args[0], args.slice(1));
}


Foo.method = function(context, arg0, arg1, ...) {
  // arguments = [context, arg0, arg1, ...]
  Foo.prototype.method.call(context, arg0, arg1 ...);
  // Foo.prototype.method.call 实际是调用原型链的 call 方法，等价于 Function/Function.prototype.call
  // call 方法本质上也是函数，故有 apply 的方法
  // 改写为：call函数.apply(Foo.prototype.method, arguments)
  // 此时 call 函数的 this 指向 Foo.prototype.method 可以等价于 Foo.prototype.method.call
  // 又因 apply 会将 arguments 展开成参数列表，即：Foo.prototype.method.call(...arguments)
  // arguments 的第一个参数是 context，故 Foo.prototype.method 的 this 指向该 context 参数
  // ===
  [Function/Function.prototype/xxxFunc].call.apply(Foo.prototype.method, arguments);
}
```

### 构造函数

#### `new`

```js
function Foo() {
  this.name = 'tom'; // this 指向新创建的对象
  // 这个新创建的对象的 prototype 会指向构造函数的 prototype
  // 如果没有显式的 return 一个对象，默认返回 this 对象，即新创建的对象
}

Foo.prototype.test = function() {
  console.log(this.name);
}

let test = new Foo();
// 1. let obj = new Object();
// 2. Foo.bind(obj)
// 3. obj.prototype = Foo.prototype
// 4. return obj if not return object obviously
```

显式返回一个**对象**（非简单类型），会影响返回结果。

```js
function Bar() {
  return 2;
}
new Bar(); // 返回新创建的对象

function Test() {
  this.value = 2;
  let obj = {
    foo: 3,
  }
  return obj;
}
new Test(); // 返回对象 obj，不是新创建的对象。注意原型和 this 指针还是关联新创建的对象
```

显示指定返回对象时，注意 constructor 的变化

```js
function Bar() {
  return new Number(2);
}
new Bar().constructor === Number
```

#### 工厂模式

```js
function Bar() {
  let value = 1;
  return {
    method: function() {
      return value;
    }
  }
}

Bar.prototype = {
  foo: function() {}
}

new Bar();
Bar();
```

上面例子中，使用或不使用 `new` 关键字，对返回对象的功能性没有区别，且都不能访问 `Bar` 原型链上的属性或方法。

```js
let bar1 = new Bar();
typeof(bar1.method); // function
typeof(bar1.foo); // undefined

let bar2 = Bar();
typeof(bar2.method); // function
typeof(bar2.foo); // undefined
```

- 闭包、私有变量等会占用更多的内存，因为新建对象不能共享原型链上的属性或方法。

- 为了实现继承，工厂方法需要从另一个对象拷贝所有的属性方法，或者把一个对象作为新创建对象的原型。

- 放弃原型链，和语言本身的思维可能相违背。

### 作用域和命名空间

在 ES6(2015) 之后，JavaScript 在作用域和命名空间上发生了很大的变化

#### 隐式全局变量

```js
function foo() {
  bar = 42; // 会意外创建隐式的全局变量，作用域超出函数

  var test = 36; // 创建局部变量，作用域为函数内
}
foo();
console.log(bar); // 42
console.log(test); // Uncaught ReferenceError: test is not defined
```

#### 局部变量和变量提升

```js
console.log(foo); // undefined
console.log(bar); // Uncaught ReferenceError: Cannot access 'bar' before initialization
console.log(t); // undefined
var foo = 1; // var 关键字将变量声明提升到作用域顶部，但未进行赋值
let bar = 2; // let 关键字不会将变量提升到作用域顶
let p = 3;

{
  let s = 's'; // let 关键字支持块级作用域
  var t = 't'; // var 关键字不支持块级作用域，并会变量提升
}

function test(p) {
  p = 4; // 这个 p 是函数参数 p
  var foo = 5; // 函数内部作用域内的变量 foo，声明被提升到作用域顶
  bar = 6; // 外部作用域的变量 bar
}

test(7);
console.log(p); // 3
console.log(foo); // 1
console.log(bar); // 6
console.log(s); // Uncaught ReferenceError: s is not defined
console.log(t); // 't'
```

总结：

- `var` 和 `function` 会把声明提升到当前作用域顶，不支持块级作用域

- `let`、`const` 不会声明提升，并支持块级作用域

- 都支持函数级别作用域

- 名称解析按照 `当前作用域`(最近的声明，作用域顶的声明，函数参数) -> `上级作用域` 顺序查找

#### 匿名函数

匿名函数是表达式。

```js
(
  function(){}
) // 返回函数对象
() // 执行上面返回的函数对象

// 其它方式
+function(){}();
(function(){}());
```

## 数组

### 遍历

需要注意：

- `for ... in` 循环会枚举原型链上的属性，因此会比普通 `for` 循环慢

#### `length` 属性

```js
let foo = [1, 2, 3, 4, 5];

console.log(foo.length); // 5

foo.length = 3; // setter，设置更小的值会截断数组，改变原数组
console.log(foo); // [1, 2, 3]

foo.length = 6; // setter，设置更大的值会增大 capacity
console.log(foo); // [1, 2, 3] // 未赋值的区域默认为 empty
console.log(foo[5]) // undefined，这个 undefined 为变量不是关键字，不代表被赋值
console.log(5 in foo); // false, 
foo[5] = undefined
console.log(5 in foo); // true
```

#### `Array` 构造函数

```js
[1, 2, 3]; // [1, 2, 3]
new Array(1, 2, 3); // [1, 2, 3]
new Array(3); // [],  length = 3
new Array('3'); // ['3']

var arr = new Array(3);
arr[1]; // undefined 是变量
1 in arr; // false，数组还为生成
```

## 类型

### 比较

- `==`，比较时会进行强制类型转换

- `===`，不会进行强制类型转换，比较对象时是比较内存的地址是否相同，即同一个实例

### `typeof` 和 `instanceof`

[typeof](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/typeof) 操作符返回一个字符串，表示未经计算的操作数的类型。

[instanceof](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/instanceof) 用于检测某个构造函数的 `prototype` 属性是否存在于一个实例对象的原型链上。

看下面表格，`class` 代表 `instanceof` 默认的构造函数，`type` 代表 `typeof` 的返回值。

|value|class|type|
|--|--|--|
|'foo'||string|
|new String('foo')|String|object|
|1.2||number|
|new Number(1.2)|Number|object|
|true||boolean|
|new Boolean(true)|Boolean|object|
|new Date()|Date|object|
|new Error()|Error|object|
|[1,2,3]|Array|object|
|new Array(1, 2, 3)|Array|object|
|new Function('')|Function|function|
|/abc/g|RegExp|object|
|new RegExp('m')|RegExp|object|
|{}|Object|object|
|new Object()|Object|object|
|Object.create(null)||object|
|undefined||undefined|
|null||object|
|symbol(5)||symbol|
|9007199254740995n||bigint|
|BigInt("9007199254740995")||bigint|

> 由于 `typeof` 可以像 `typeof(obj)` 这样调用，类似函数的调用，但这并不是函数调用，`()` 是代表里面表达式计算的结果，将该结果作为 `typeof` 的操作数，并不存在 `typeof` 函数。

> 如果表达式 `obj instanceof Foo` 返回 true，则并不意味着该表达式会永远返回 true，因为 Foo.prototype 属性的值有可能会改变，改变之后的值很有可能不存在于 obj 的原型链上，这时原表达式的值就会成为 false。另外一种情况下，原表达式的值也会改变，就是改变对象 obj 的原型链的情况，虽然在目前的 ES 规范中，我们只能读取对象的原型而不能改变它，但借助于非标准的 `__proto__` 伪属性，是可以实现的。比如执行 `obj.__proto__ = {}` 之后，obj instanceof Foo 就会返回 false 了。

#### 对象的类定义 `[[Class]]`

每个对象都有一个 `toString()` 方法，当该对象被表示为一个文本值时，或者一个对象以预期的字符串方式引用时自动调用。默认情况下，toString() 方法被每个 `Object` 对象继承。如果此方法在自定义对象中未被覆盖，toString() 返回 `"[object type]"`，其中 `type` 是对象的类型。

JavaScript 标准文档中定义了 `[[Class]]` 的可能值：
`Arguments`, `Array`, `Boolean`, `Date`, `Error`, `Function`, `JSON`, `Math`, `Number`, `Object`, `RegExp`, `String`, `Symbol`, `BigInt`, `Undefined`。

### 类型转换

#### 内置类型的构造函数

```js
new Number(10) === 10; // false, 对象与数字比较
Number(10) === 10; // true
new Number(10) + 0 === 10; // true，隐式类型转换
```

#### 类型转换的 trick

```js
'' + 10 === '10'; // true
+'10' === 10; // true
!!'foo'; // true
!{}; // false
```

## 核心

### `eval`

#### 参数

`eval` 是全局对象的函数属性。

其参数类型不同，作用不同：

- 参数是字符串，且是表达式，会对该表达式求值。

- 参数是字符串，且是语句，会尝试执行这些语句。

- 参数不是字符串，会将参数**原封不动**的返回。

```js
eval(new String("2 + 2")); // 返回了包含"2 + 2"的字符串对象
eval("2 + 2");             // returns 4

// 可以绕过该限制
var expression = new String("2 + 2");
eval(expression.toString());
```

#### 作用域

`eval` 在直接调用和间接调用时具有不同的作用域，需要特别注意。

```js
function test() {
  var x = 2, y = 4;
  console.log(eval('x + y'));  // 直接调用，使用本地作用域，结果是 6
  var geval = eval; // 等价于在全局作用域调用
  console.log(geval('x + y')); // 间接调用，使用全局作用域，throws ReferenceError 因为`x`未定义
  (0, eval)('x + y'); // 另一个间接调用的例子
​}
```

[参考链接](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/eval)

### `void`

对给定的表达式进行求值，并返回 **`undefined`**。

```js
void function life() { // 利用 void 将函数声明识别为表达式，达到和匿名函数相同的效果
    var bar = function () {};
    var baz = function () {};
    var foo = function () {
        bar();
        baz();
     };
    var biz = function () {};

    foo();
    biz();
}();

button.onclick = () => void doSomething(); // 右边箭头函数的返回值始终是 undefined，避免泄漏。
```

## 原型

[JavaScript 原型](./prototype.md)

## 其他

### setTimeout 和 setInterval

使用注意：

- 第 1 个参数是字符串时，会**隐式调用 `eval`**。

- 在 JS 线程阻塞时，`setInterval` 依然会继续添加回调事件到队列。

- 由于 JS 单线程的运行方式，`setTimeout` 无法保证在指定的时刻运行代码。

      