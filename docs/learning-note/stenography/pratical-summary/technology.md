---
sidebar_position: 5
---
    
# Technology

## React

- 开发模式下，useEffect 首次会 run 两次，检查 return 是否正确
- 开发模式下，child 的 type.name  时函数名，当在生产模式下是随机名称。须用函数的 displayName 代替

## UI

- 卡片显示，如何处理长文本。尤其是有图片和底部 link 的情况
- carousel，如何确定整体高度。尤其是内部元素高度无法统一时

## Render

- SSR 下不加载多媒体文件等静态文件，节省服务器带宽消耗
- SSR 页面首次加载无法使用客户端 API，如 local storage，必要时可用服务端 cache 替代

<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at September 3, 2024 14:39</small></div>
      