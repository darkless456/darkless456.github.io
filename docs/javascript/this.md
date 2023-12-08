---
sidebar_position: 7
---
    
<small style={{color: '#cccccc'}}>last modified at December 8, 2023 7:24 AM</small>
# Explain `this` with Rules

## Reference

`ECMAScript` 分为 语言类型 和 规范类型。

- 语言类型是程序员可以直接操作的，例如 基本数据类型。

- 规范类型是用来用算法描述 ECMAScript 语言结构和语言类型的。

> 规范类型包括：Reference(引用), List(列表), Completion(完结), Property Descriptor(属性描述符), Property Identifier(属性标识符), Lexical Environment(词法环境), Environment Record(环境记录)

### `Reference` 组成

`Reference` 有三部分组成：

- base value，基值。
  - any ECMAScript 语言值，除 undefined 和 null。
  - 例如：Object, Boolean, String, Number, Environment Record ...
  - ES6 之前还包括 undefined。
  - GetBase(V) 返回引用值 V 的基值组件，返回是具体的值。
  - 基值是 undefined 表示此引用可以不解决一个绑定。
  - HasPrimitiveBase(V) 如果基值是 Boolean, String, Number, 返回 true。
  - IsPropertyReference(V) 如果基值是个对象或 HasPrimitiveBase(V) 是 true，返回 true。
  - IsUnresolvableReference(V) 如果基值是 undefined，返回 true。

- reference name，引用名称。
  - 一个字符串
  - GetReferencedName(V) 返回引用值 V 的引用名称组件。

- strict reference，布尔值严格引用标志。
  - IsStrictReference(V) 返回引用值 V 的严格引用组件。

例子：

```js
var foo = 1;
// Reference:
var fooReference = {
  base: EnvironmentRecord,
  name: 'foo',
  strict: false
}
GetValue(fooReference)

var foo = {
  bar: function() {
    return this;
  }
}
foo.bar(); // foo
// Reference for bar
var BarReference = {
  base: foo,
  propertyName: 'bar',
  strict: false
}
```

## 函数如何确定 `this` 的值

步骤有：

1. 计算 `MemberExpression` 的结果并赋值给 ref

2. 判断 ref 是不是一个 Reference 类型
  2.1 如果 ref 是 Reference 并且基值是 `对象`、`Boolean`、`String`、`Number`，那么 this 值为 GetBase(ref)。
  2.2 如果 ref 是 Reference，并且基值是 `Environment Record`，那么 this 值为 ImplicitThisValue(ref)。
  2.3 如果 ref 不是 Reference，那么 this 值为 undefined。

### 什么是 `MemberExpression`

- PrimaryExpression // 原始表达式

- FunctionExpression // 函数定义

- MemberExpression[ Expression ] // 使用 `[]` 访问属性

- MemberExpression.IdentifierName // 使用 `.` 访问属性

- new MemberExpression Arguments // 使用 `new` 关键字创建对象

例子：

```js
function foo() {
  console.log(this);
}
foo(); // MemberExpression => foo

function foo() {
  return function() {
    console.log(this);
  }
}
foo()(); // MemberExpression => foo()

var foo = {
  bar: function() {
    return this;
  }
}
foo.bar(); // MemberExpression => foo.bar
```

> 简单点理解 `MemberExpression` 就是 `()` 左边的部分。

### 判断 `MemberExpression` 是不是个 `Reference`

```js
var value = 1;
var foo = {
  value: 2,
  bar: function() {
    return this.value;
  }
}

foo.bar();
// 1. MemberExpression => foo.bar
// 2. GetValue(foo.bar) => foo
// 3. foo is one of (object, string, number, boolean)
// 4. this => foo

(foo.bar)();
// () 不会进行计算，与上面结果一致

// 下面三种方式是先计算后调用，this 指向全局
(foo.bar = foo.bar)();

(false || foo.bar)();

(foo.bar, foo.bar)();
```

      