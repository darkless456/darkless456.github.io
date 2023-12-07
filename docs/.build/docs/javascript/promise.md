---
sidebar_position: 5
---
    
# JavaScript Promise

## Callback 方式

传统的回调函数，嵌套多层后维护困难（callback hell）

```javascript
const ajaxWithCallback = function(callback) {
  // ... code
  if(typeof callback === 'function') {
    callback();
  }
}

ajax(function() {
  console.log('invoke callback')
})
```

## Promise 方式

Promise 标准-状态变化（Pending - Fulfilled/Rejected），then 函数不明文指定返回实例，则返回本身的 Promise 实例

- resolve：执行下一步操作
- reject：中断当前操作
- then：Promise 返回的对象，可接受两个参数，第一个表示 resolved，第二个表示 rejected

- catch：捕获多个实例串行操作中出现的错误
- finally：执行结束后指定的回调

### Promise.all 并行执行

Promise.all 以数组形式接收多个实例，同步执行这些实例。一旦其中一个或多个实例发生 reject，就会触发 catch 函数

```javascript
Promise.all([promise1, promise2, ...])
  .then(()=>{
    // ...code
  })
  .catch((error)=>{
    // ...error code
  })
```

## Promise.race 竞争执行

Promise.race 只要其中一个实例发生状态改变，Promise.race 也将改变，不再响应其他实例

```javascript
Promise.race([promise1, promise2, ...])
  .then(()=>{
    // ...code
  })
  .catch((error)=>{
    // ... error code
  })
```

## 错误捕获

提供两种错误捕获方式

- then 函数的第二个参数
- catch 函数

### then 方式

就近捕获原则，不影响后续 then 的执行

```javascript
const ajax = function(){
  console.log('promise开始执行');
  return new Promise(function(resolve,reject){
    setTimeout(function(){
      reject(`There's a mistake`);
    },1000);
  });
}

ajax()
  .then(function(){
    console.log('then1');
    return Promise.resolve();
  }, err => {
    console.log('then1里面捕获的err: ', err);
  })
  .then(function(){
    console.log('then2');
    return Promise.reject(`There's a then mistake`);
  })
  .catch(err => {
    console.log('catch里面捕获的err: ', err);
  });

// 输出
// promise开始执行
// then1里面捕获的err:  There's a mistake
// then2
// catch里面捕获的err:  There's a then mistake
```

### catch 方式

Promise 抛出的错误具有冒泡机制，能够不断传递，可使用 catch 统一处理

```javascript
const ajax = function(){
  console.log('promise开始执行');
  return new Promise(function(resolve,reject){
    setTimeout(function(){
      reject(`There's a mistake`);
    },1000);
  });
}

ajax()
  .then(function(){
    console.log('then1');
    return Promise.resolve();
  })
  .then(function(){
    console.log('then2');
    return Promise.reject(`There's a then mistake`);
  })
  .catch(err => {
    console.log('catch里面捕获的err: ', err);
  })

// 输出
// promise开始执行
// catch里面捕获的err:  There's a mistake
```

## 手写 Promise

<!-- [源码](./promise.js) -->
[Promises/A+](https://promisesaplus.com/)

验证：

```javascript
  npm i -g promises-aplus-tests
  promises-aplus-tests promise.js
```

      