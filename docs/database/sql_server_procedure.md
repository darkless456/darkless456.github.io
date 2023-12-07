---
sidebar_position: 2
---
    
<small style="color: #ccc;">last modified at 2023/12/7 8:54:31</small>
# The SQL Server Procedure

## 规范

- `USE` 设置当前数据库
- `DECLARE` 声明变量，可以`,`分隔多个变量。`DECLARE @variable_name1 variable_type, @variable_name2 variable_type`

- 变量赋值，`SET` 或 `SELECT`
  - 当知道具体的值时，使用 SET `SET @test=10`
  - 当基于一个查询时，使用 SELECT `SELECT @test=MAX(age) FROM user`

- `AS` 给参数赋值
  - AS 存储过程语法的一部分，AS 之前是存储过程的参数和属性定义， AS 之后表述存储过程的内容定义

- `BEGIN` 和 `END`，如果存储过程中有多条语句，需要加 BEGIN/END 块

- 启用 `ANSI_NULLS`，所有与空值的比较运算结果为 UNKNOWN，否则空值与空值比较结果为 TRUE

- 启用 `QUOTED_IDENTIFIER` 表示使用双引号 `""` 作为分隔符（当标示符不符合 SQL Server的命名规则时可以使用 `""` 或者 `[]` 作为分隔符）

- `CAST` 用来构造语句的

## 示例

```sql

USE [PRODUCTION]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE [dbo].[users]

```
      