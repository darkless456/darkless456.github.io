---
sidebar_position: 4
---
    
# Solutions for Crossing Tab Communication

在浏览器中，不同窗口（包括不同标签页、不同浏览器实例）之间进行数据交换的能力。

## 前端实现

只依靠宿主（如浏览器）自身提供的 API 来实现的方案。

为了实现跨窗口通信，应该具备以下的能力：

- 数据传输，数据可以从一个窗口发送到另一个窗口，也可以接受从其他窗口的数据
- 实时性，数据的传输是实时的
- 安全性，通信过程是安全的

### 同域策略限制

#### Broadcast Channel

核心 API：

- Broadcast 对象，每个窗口都需要创建该对象并使用相同的频道名初始化
- postMessage 方法，Broadcast 对象的方法，向拥有相同频道名的其他窗口广播消息
- message 事件，监听 Broadcast 对象的该事件，接收来自同频道名其他窗口的广播消息

示例：

```js
const rootElement = document.getElementById('root');

const testBtn = document.createElement('button');
testBtn.innerText = 'click';
testBtn.setAttribute('id', 'test-btn');
rootElement.appendChild(testBtn);


const broadcastObj = new BroadcastChannel('test-channel');

broadcastObj.onmessage = (e) => {
  console.log(e.data); // test message posted at: 12/8/2023, 11:27:24 AM
}

testBtn.addEventListener('click', () => {
  console.log('clicked');
  broadcastObj.postMessage('test message posted at: ' + new Date().toLocaleString())
})
```

#### SharedWorker

是 HTML5 提供的多线程解决方案，它可以在多个 Tab 之间共享一个后台线程。

示例：

```js
// index.js
const testBtn = document.createElement('button');
testBtn.innerText = 'click';
testBtn.setAttribute('id', 'test-btn');
rootElement.appendChild(testBtn);


const worker = new SharedWorker('./sharedWorker.js', 'testWorker');

worker.port.onmessage = (e) => {
  console.log(e.data); // test message posted at: 12/8/2023, 11:41:24 AM
}

testBtn.addEventListener('click', () => {
  worker.port.postMessage('test message posted at: ' + new Date().toLocaleString());
});

// sharedWorker.js
const connections = [];

onconnect = (e) => {
  const port = e.ports[0];
  connections.push(port);

  port.onmessage = (ev) => {
    connections.forEach((conn) => {
      if (conn !== port) {
        conn.postMessage(ev.data);
      }
    });
  }

  port.start();
}
```

> sharedWorker 是 broadcast channel 的更底层实现？

#### LocalStorage

利用全局的 `storage` 事件，当监听该事件被触发时，触发后续的处理流程。

示例：

```js
const rootElement = document.getElementById('root');

const testBtn = document.createElement('button');
testBtn.innerText = 'click';
testBtn.setAttribute('id', 'test-btn');
rootElement.appendChild(testBtn);


window.addEventListener('storage', (e) => {
  console.log(e.key); // test-data
  console.log(e.newValue); // 12/8/2023, 11:47:09 AM
  console.log(e.oldValue); // 12/8/2023, 11:46:09 AM
})

testBtn.addEventListener('click', () => {
  window.localStorage.setItem('test-data', new Date().toLocaleString());
});
```

### 非同域策略限制

受限于现代浏览器的安全策略，只依靠前端实现的不受同域策略限制的跨窗口通信方案不存在。

## 第三方

通过第三方提供的服务（如 WebSocket）来实现的方案。

实现方式：

1. 服务端创建一个消息转发服务，可以向前端主动地发送消息和接收来自前端的消息，如 Websocket、HTTP/2、自建协议等
2. 所有前端都会连接服务端的消息转发服务
3. 服务端接收来自某个前端的消息后，将该消息转发给其他前端
4. 前端接收到下发的消息后做后续处理

<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at December 8, 2023 14:31</small></div>
      