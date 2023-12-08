---
sidebar_position: 4
---
    
<small style={{color: '#cccccc'}}>last modified at December 8, 2023 7:21 AM</small>
# Shadow DOM

![Shadow dom](./assets/shadow-dom.png)

> Shadow DOM 允许将隐藏的 DOM 树附加到常规的 DOM 树中——它以 shadow root 节点为起始根节点，在这个根节点的下方，可以是任意元素，和普通的 DOM 元素一样。

- Shadow host：一个常规 DOM 节点，Shadow DOM 会被附加到这个节点上。
- Shadow tree：Shadow DOM 内部的 DOM 树。
- Shadow boundary：Shadow DOM 结束的地方，也是常规 DOM 开始的地方。
- Shadow root: Shadow tree 的根节点。

> 你可以使用同样的方式来操作 Shadow DOM，就和操作常规 DOM 一样，例如添加子节点、设置属性，以及为节点添加自己的样式（例如通过 element.style 属性），或者为整个 Shadow DOM 添加样式（例如在 \<style\> 元素内添加样式）。不同的是，Shadow DOM 内部的元素始终不会影响到它外部的元素（除了 :focus-within），这为封装提供了便利。

## [Using custom elements](https://developer.mozilla.org/zh-CN/docs/Web/Web_Components/Using_custom_elements)

共有两种 custom elements：

- **Autonomous custom elements** 是*独立的元素*，它不继承其他内建的 HTML 元素。你可以直接把它们写成 HTML 标签的形式，来在页面上使用。例如 `<popup-info>`，或者是 `document.createElement("popup-info")` 这样。

- **Customized built-in elements** _继承自基本的 HTML 元素_。在创建时，你必须指定所需扩展的元素（正如上面例子所示），使用时，需要先写出基本的元素标签，并通过 is 属性指定 custom element 的名称。例如 `<p is="word-count">`, 或者 `document.createElement("p", { is: "word-count" })`。

### [Autonomous custom elements](https://developer.mozilla.org/zh-CN/docs/Web/Web_Components/Using_custom_elements#autonomous_custom_elements)

```javascript
// Autonomous custom elements 总是继承自 HTMLElement
class PopUpInfo extends HTMLElement {
  constructor() {
    super();

    // create a shadow root, open mode declare it can be found by outer javascript method
    const shadow = this.attachShadow({ mode: "open" });

    // create shadow tree
    const wrapper = document.createElement("span");
    wrapper.setAttribute("class", "wrapper");

    const icon = document.createElement("span");
    icon.setAttribute("class", "icon");
    icon.setAttribute("tabindex", 0);

    const info = document.createElement("span");
    info.setAttribute("class", "info");

    // put inside the info text
    const text = this.getAttribute("data-text");
    info.textContent = text;

    const img = document.createElement("img");
    img.src = this.getAttribute("img") || "";

    icon.appendChild(img);

    // create CSS
    const style = document.createElement("style");
    style.textContent = `
      .wrapper {
        positive: relative;
      }
      ...
    `;

    // attach the created elements to the shadow dom
    shadow.appendChild(style);
    shadow.appendChild(wrapper);
    wrapper.appendChild(icon);
    wrapper.appendChild(info);
  }
}

// define the new element
customElements.define("popup-info", PopUpInfo);
```

> 已废弃注册 custom element 旧 API <del>`document.registerElement('x-image', { prototype: XImage });`</del>

```html
<popup-info
  img="img/alt.png"
  text="Your card validation code (CVC)
  is an extra security feature — it is the last 3 or 4 numbers on the
  back of your card."
></popup-info>
```

> 提示: 在 Chrome 版本 76.0.3809.132（正式版本）（64 位）中测试发现，`customElements.define()` 必须在 js 文件中调用，且引用此 js 文件时必须在 `script` 标签上添加 `defer` 属性，否则 `this.getAttribute('属性名称')` 无法获取到值。

### [Customized built-in elements](https://developer.mozilla.org/zh-CN/docs/Web/Web_Components/Using_custom_elements#customized_built-in_elements)

```javascript
class ExpandingList extends HTMLUListElement {
  constructor() {
    // return value from super() is a reference to this element
    self = super();
    // ... feature code
  }
}

customElements.define("expanding-list", ExpandingList, { extends: "ul" });
```

```html
<ul is="expanding-list">
  ...
</ul>
```

[完整源码](https://github.com/mdn/web-components-examples/blob/master/expanding-list-web-component/main.js)

### [Life cycle callbacks](https://developer.mozilla.org/zh-CN/docs/Web/Web_Components/Using_custom_elements#%E4%BD%BF%E7%94%A8%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F%E5%9B%9E%E8%B0%83%E5%87%BD%E6%95%B0)

- `connectedCallback：当` custom element 首次被插入文档 DOM 时，被调用。
- `disconnectedCallback：当` custom element 从文档 DOM 中删除时，被调用。
- `adoptedCallback`：当 custom element 被移动到新的文档时，被调用。
- `attributeChangedCallback`: 当 custom element 增加、删除、修改自身属性时，被调用。

需要注意的是，如果需要在元素属性变化后，触发 attributeChangedCallback() 回调函数，你必须监听这个属性。这可以通过定义 observedAttributes() get 函数来实现，observedAttributes() 函数体内包含一个 return 语句，返回一个数组，包含了需要监听的属性名称：

```javascript
static get observedAttributes() {return ['属性名称1', '属性名称2']; }
```

[完整源码](https://github.com/mdn/web-components-examples/blob/master/life-cycle-callbacks/main.js)

## [Using templates and slots](https://github.com/mdn/web-components-examples/tree/master/element-details)

### \<template\>：内容模板元素

```text
HTML 内容模板（<template>）元素是一种用于保存客户端内容机制，该内容在加载页面时不会呈现，但随后可以在运行时使用 JavaScript 实例化。

将模板视为一个可存储在文档中以便后续使用的内容片段。虽然解析器在加载页面时确实会处理 <template> 元素的内容，但这样做只是为了确保这些内容有效；但元素内容不会被渲染。

此元素仅包含全局属性。

但，HTMLTemplateElement 有个属性：content, 这个属性是只读的 DocumentFragment 包含了模板所表示的DOM树。

```

```html
<table id="table">
  <thead>
    <tr>
      <td>UPC_Code</td>
      <td>Product_Name</td>
    </tr>
  </thead>
  <tbody>
    <!-- 现有数据可以可选地包括在这里 -->
  </tbody>
</table>

<template id="row">
  <tr>
    <td class="record"></td>
    <td></td>
  </tr>
</template>

<script>
  // 通过检查来测试浏览器是否支持HTML模板元素
  if ("content" in document.createElement("template")) {
    // 找到 template by id
    const tpl = document.querySelector("#row").content;
    const content = tpl.content;

    const newNode = content.cloneNode(true); // or document.importNode(content, true)

    const tds = newNode.querySelectorAll("td");
    tds[0].textContent = "test tds[0]";
    tds[1].textContent = "test tds[1]";

    // 克隆新行并将其插入表中
    const tbodys = document.getElementsByTagName("tbody");
    tbodys[0].appendChild(newNode);

    // ...
  } else {
    // 找到另一种方法来添加行到表，因为不支持HTML模板元素。
  }
</script>
```

### \<slot\>：插槽/占位符

```html
<!DOCTYPE html>
<html>
  <head>
    <!-- head code -->
  </head>
  <body>
    <!-- html code -->
    <template id="element-details-template">
      <style>
        /* template inner styles */
      </style>
      <details>
        <summary>
          <span>
            <code class="name"
              >&lt;
              <!-- 需要被替换的具名 slot -->
              <slot name="element-name">NEED NAME</slot>
              &gt;</code
            >
            <i class="desc">
              <!-- 需要被替换的具名 slot -->
              <slot name="description">NEED DESCRIPTION</slot>
            </i>
          </span>
        </summary>
        <div class="attributes">
          <h4><span>Attributes</span></h4>
          <!-- 需要被替换的具名 slot -->
          <slot name="attributes"><p>None</p></slot>
        </div>
      </details>
      <!-- html code -->
    </template>

    <element-details>
      <!-- 替换 name="element-name" 的 slot -->
      <span slot="element-name">slot</span>
      <!-- 替换 name="description" 的 slot -->
      <span slot="description"
        >A placeholder inside a web component that users can fill with their own
        markup, with the effect of composing different DOM trees together.</span
      >
      <!-- 替换 name="attributes" 的 slot -->
      <dl slot="attributes">
        <dt>name</dt>
        <dd>The name of the slot.</dd>
      </dl>
    </element-details>
    <!-- html code -->

    <script>
      customElements.define(
        "element-details",
        class extends HTMLElement {
          constructor() {
            super();
            // 找到 template
            const template = document.getElementById("element-details-template")
              .content;
            // 深复制 template 的 node 并挂载到 root
            const shadowRoot = this.attachShadow({ mode: "open" }).appendChild(
              template.cloneNode(true)
            );
          }
        }
      );
    </script>
  </body>
</html>
```

> ~~HTML Imports 已经被放弃~~

> 示例参考 [MDN](https://github.com/mdn/web-components-examples)

      