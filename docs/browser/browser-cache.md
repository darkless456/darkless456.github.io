---
sidebar_position: 2
---
    
<small style={{color: '#cccccc'}}>last modified at December 8, 2023 7:24 AM</small>
# Cache In Modern Browser

## **HTTP 文件缓存**

- 基于 HTTP 协议的文件级缓存机制
- 浏览器针对重复请求（有缓存情况下）
  - 本地：判断 Cache-Control/Expires 是否过期
  - 本地-远程：如有 ETag，带 If-None-Match 一起向服务器发送请求
    - 服务端判断 ETag 未修改 - return 304
    - 服务端判断 ETag 已修改 - return 200
  - 本地-远程：如有 Last-Modified，带 If-Modified-Since 一起向服务器发送请求
    - 服务端判断 Last-Modified 未失效 - return 304
    - 服务端判断 Last-Modified 已失效 - return 200
  - 以上都不存在则直接发起请求

## **LocalStorage**

- H5 的本地缓存方案
- 较大容量数据持久化存储（MB 级别）
- 在不同浏览器中，其单个域名下的长度限制不同
- 只支持简单数据类型
- 多个标签打开同一个域名时，内容共享
- 域名级

## **SessionStorage**

- 与 LocalStorage 相似
- 标签关闭后，自动清空

## **Cookie**

- 一般随 HTTP 请求发送到服务端
- 属性：key，value，domain，expire，size
- 域名级
- document.cookie 获取非 Http-Only 的 cookie
- session cookie（无过期时间）、持久型 Cookie（设置有过期时间，保存在本地文件）
- 大小一般限制在 4096KB

## IndexDB

- 大容量结构化数据存储（MB 级别）
- 保存在本地

## WebSQL

- 非 H5 规范
- 大容量
- 只有在新版本的 Chrome 支持，并以独立形式支持
- 允许 SQL 语句查询
- 小型 NoSQL 数据库
- openDatabase（打开/创建）、transaction（执行事务/回滚）、executeSql（执行 SQL 语句）

## *CacheStorage*

- Service Worker 的规范
  - Service Worker 在浏览器后台以独立线程运行，提供并行计算和数据处理能力
  - 兼容性待定
- 通过 window 全局对象 caches 访问
- open，match，has，delete，keys；返回都是 promise

## Application Cache

- 通过 manifest 配置文件选择性缓存静态资源的文件级缓存
- 默认优先从 Application Cache 读取资源，然后向远端检查缓存的文件是否更新
- 如有更新，需下次访问时才会生效
- window.applicationCache 访问 API
- 支持手动更新
- 缺点：必须同域，同域其他页面没有 manifest 也会触发缓存，兼容性差，单个文件更新失败导致全局更新失败
- 正在被 Service Worker 替换

## Flash 缓存

- 网页端 Flash 具有读写本地文件能力
- JS 可以调用 Flash 提供的 API

      