---
sidebar_position: 2
---
    
# Go Live

## env

- 对于使用 shell 脚本在构建过程中向环境变量文件动态写入变量，应注意添加换行符，与其他变量区分
- 对于云平台，构建或修改环境参数的操作，可自动化和手动部分，最好有文档可供参考。后续维护更简便易行
- 对于发布，核对代码分支、版本等参数，避免错误发布

## 以 CMS 为后端的网站静态化

- build 时生成静态页面，作为基础版本
- 动态增减或修改页面后，针对变化的页面进行更新
  - 事件触发/定时触发，使用事件队列避免事件冲突
  - 远程调用静态网页生成服务
  - 更新 sitemap
  - 更行 cdn
  - 。。。
- 动态 sitemap
  - 查询所有公开页面的数据，获取 sitemap 的页面列表

## go live 前的准备

- 准备 go live 前所有工作的 check list
  - 提前确认第三方依赖的运行情况
  - 分析并列出潜在的 risk
  - 其他的例行检查

- API 集成工作
  - 一定要留有buffer应对不可控的情况
  - 将要超期前，及时更新情况，获得客户谅解，争取主动

- 与其被动由他人更新，不如主动向他人了解





<div style={{textAlign: 'right'}}><small style={{color: 'grey'}}>last modified at September 3, 2024 14:39</small></div>
      