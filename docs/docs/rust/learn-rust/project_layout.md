---
sidebar_position: 12
---
    
# Project Layout

## 目录组成

```sh
▾ src/           # 包含源文件的目录
  lib.rs         # 库和包的主要入口点
  main.rs        # 包生成可执行文件的主要入口点
  ▾ bin/         # （可选）包含其他可执行文件的目录
    *.rs
  ▾ */           # （可选）包含多文件可执行文件的目录
    main.rs
▾ examples/      # （可选）示例
  *.rs
  ▾ */           # （可选）包含多文件示例的目录
    main.rs
▾ tests/         # （可选）集成测试
  *.rs
  ▾ */           # （可选）包含多文件测试的目录
    main.rs
▾ benches/       # （可选）基准
  *.rs
  ▾ */           # （可选）包含多文件基准的目录
    main.rs
```
      