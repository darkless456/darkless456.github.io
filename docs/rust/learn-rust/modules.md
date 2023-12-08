---
sidebar_position: 7
---
    
<small style={{color: '#cccccc'}}>last modified at December 7, 2023 8:56 AM</small>
# Modules

## 概述

模块系统是可以用来控制作用域和私有性。

- 模块，一种组织代码和控制私有性的方式

- 路径，命名项的方式

- `use`，将路径引入作用域

- `pub`，使项变为公有

- `as`，引入作用域时重命名

- 将不同模块分割到单独的文件/文件夹

## 模块

### 什么是 crate

crate 是一个二进制的可执行程序或库。 Rust 的编译器以 crate root 源文件为起始点，构建一个 crate 的根模块。

> 通常，一个 crate 会将一个作用域内相关的功能分组到一起，方便多个项目共享。

### 什么是 package

package 包括是一个或多个 crates。会包含一个 Cargo.toml 文件，描述项目的元数据。

> 一个 package 至少一个 crate，可以是 lib 或者 bin。 包括的 lib 至多一个，bin 任意多个。

### 如何定义模块

基本语法格式：

```rs
mod <name> {
  // ...
}
```

`<name>` 是模块名，模块可以嵌套。

### 模块树

```rs
mod voice {
  mod device {
    mod earphone {
      fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // ...
      }
    }
  }

  mod software {

  }
}
```

上述示例组成了一个模块树：

```text
crate
 |- voice
   |- device
     |- earphone
       |- member_fn   
     |- audio
       |- member_fn
   |- software
```

这个树展示了模块的嵌套关系，整个树在名为 `crate` 的隐式模块下。

这种结构非常像文件系统的目录，与文件系统目录相似的是为了引用模块数的项需要使用路径（path）。

## 路径

在模块树中，想要调用某个函数，就需要知道其`路径`。

路径有两中形式：

- 绝对路径，从 crate 根开始，以 crate 开头。

- 相对路径，从当前模块开始，以 self、super 或当前模块标识符开头。

```rs
// mod code ...

fn main() {
  // 绝对路径
  crate::voice::device::earphone::member_fn();

  // 相对路径
  voice::device::earphone::member_fn();
}
```

此时程序并不能通过编译，尽管 `voice` 对于 `main` 函数是公开的，但 `voice` 的子模块 `device` 和 `software` 默认是私有的，即外界不能直接使用。

在 Rust 中，模块是作为私有性的边界，如果希望函数或结构体等项是私有的，需要将其放入模块。

私有性规则：

- 所有项（函数、方法、结构体、枚举、常量...）默认是私有的。

- 使用 `pub` 关键字可以使项变为公有，即外界可以使用。

- 不允许直接使用定义于当前模块的子模块中的私有代码。

- 允许直接使用定义于父模块或当前模块的代码，无论是公有还是私有。

## `pub` 关键字

`pub` 关键字可以使模块中私有项变为公有项，供外界使用。是某项公有并不意味着其内容也是公有的。

```rs
```rs
mod voice {
  pub mod device {
    mod earphone {
      fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // ...
      }
    }
  }

// ...
}
```

上述代码使用 pub 关键字将 device 模块变为公有。我们可以使用 crate::voice::device 或 voice::device 来直接引用，但如果想直接引用子模块 earphone 中的 member_fn 函数，依然不可以。

如果需要使用 earphone 的 member_fn 函数，应该在 earphone 模块 和 member_fn 函数前增加 pub 关键字

```rs
mod voice {
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // ...
      }
    }
  }

// ...
}
```

这样程序可以顺利通过编译！

接下来如果我们希望在 audio 模块的 member_fn 函数中使用父级模块的子模块 earphone 的 member_fn 函数，应该怎么办？

一种是使用绝对路径的方式。

```rs
mod voice {
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // 绝对路径
        crate::voice::device::earphone::member_fn()
      }
    }
  }

// ...
}
```

另一种是使用相对路径和 `super` 关键字。

```rs
mod voice {
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // 相对路径并使用 super 关键字
        super::earphone::member_fn()
      }
    }
  }

// ...
}
```

<!-- 我们可以`结构体`和`枚举`中使用 `pub`。 -->
对于公有的结构体和枚举，我们可以按照与函数相同的方式设计，不过有一些额外的细节值得注意：

- 对结构体定义使用 pub，可以使结构体公有，但其里面的字段仍然是私有的。

- 对枚举的定义使用 pub，枚举和其里面字段都是公有的。

```rs
pub struct User { // 公有结构体 User
  id: i32, // id 依然是私有
  pub name: String, // name 在加上 pub 之后变为公有
}

pub enum Gender { // 公有枚举 Gender
  male, // 其每个成员将自动变为公有。因为枚举是公有的但成员是私有的，对于这个枚举来说是没有意义的。
  female,
}
```

## `use` 关键字

上述一些代码示例中，函数的调用需要非常冗长和重复的路径。例如：`crate::voice::device::earphone::member_fn()`。

我们希望有一种方式可以把路径一次性的引入作用域中，是我们可以像调用本地函数一样使用外部函数。使用 `user` 关键字可以帮助我们实现。

```rs
mod voice {
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // ...
      }
    }
  }
}

use crate::voice::device::earphone; 
// 也可以使用相对路径引入，如：use self::voice::device::earphone;

fn main() {
  earphone::member_fn();
  earphone::member_fn();
}
```

对于使用 `use` 关键字将项引入作用域，有一些习惯用法：

- 对于函数，我们一般习惯于引入函数的父模块，以父模块调用函数的方式使用。

- 对于结构体、枚举和其他项，我们倾向于引入项的全路径。但是当两个项存在命名冲突时，只能引入他们各自的父模块或者使用下面的 `as` 关键字重命名。

```rs
// 对于上面的 earphone 模块中的 member_fn 函数，通常引入父模块到作用域
use crate::voice::device::earphone; 

// 对于不存在命名冲突的其他项，则倾向于引入全路径
use std::collections::HashMap;
```

关于 use 关键字，还有一种常用的方式是利用 `pub use` 重导出项。

```rs
mod voice {
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    pub mod audio {
      pub use super::earphone; // 重导出 earphone 模块

      fn member_fn() {
        // ...
      }
    }
  }

use crate::voice::device::earphone; 
use crate::voice::device::audio;

fn main() {
  earphone::member_fn();
  audio::earphone::member_fn();
}
```

> `pub use` 可以将路径较深的模块或者项重新导出到浅层模块中，将模块的公有部分与实际的代码结构分离，从而方便外界使用。

`use` 关键字还有一些细节方便我们引入项到作用域，例如 嵌套路径、glob 运算符

```rs
use std::cmp::Ordering;
use std::io;
// 跟上述效果相同
use std::{cmp::Ordering, io};

use std::io;
use std::io::Write;
// 跟上述效果相同
use std::io::{self, Write};

// 引入所有的公有定义，glob 运算符（*）
use std::collections::*;

```

## `as` 关键字

`as` 关键字用于解决引入作用域的项存在命名冲突的情况。

```rs
use std::fmt::Result;
use std::io::Result as IoResult; // 为避免与上面的 Result 重名，使用 as 关键字指定作用域中新的名称

fn function1() -> Result {
#     Ok(())
}
fn function2() -> IoResult<()> {
#     Ok(())
}
```

## 使用第三方模块

在实际的项目中，经常需要使用到第三方的包或者模块。例如 `rand` 来生成随机数。

我们需要在 `Cargo.toml` 中添加依赖，并将其引入作用域。

```toml
[dependencies]
rand = "0.8.0"
```

```rs
use rand::Rng;

fn main() {
  rand::thread_rng().gen_range(1..100);
}
```

> rust 中不需要明确声明第三方模块

## 按文件/文件夹分割不同模块

当模块的代码规模变得很大时，你可能希望将他们的定义移动到单独的文件或文件夹中，是代码的层次分明，更容易阅读理解。

文件名：src/voice.rs

```rs
// mod voice { // 不需要显示声明 mod voice
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // ...
      }
    }
  }
// }
```

文件名：src/main.rs

```rs
mod voice; // mod voice { include!("voice.rs"); }

fn main() {
    voice::device::earphone::member_fn();
}
```

对于按文件夹分割代码，我们需要在文件夹中创建 `mod.rs` 文件，其他效果与按文件相同

文件名：src/voice/mod.rs

```rs
  pub mod device {
    pub mod earphone {
      pub fn member_fn() {
        // ...
      }
    }

    mod audio {
      fn member_fn() {
        // ...
      }
    }
  }
```

> 如果使用过 Node.js，`mod.rs` 类似于 `index.js`

## 总结

- 模块是私有性边界

- `pub` 关键字是项由私有变为公开

- 我们需要明确地将函数、结构体等项声明为 pub，这样它们才可以被其他模块使用

- `use` 关键字将项引入到作用域中

- `pub use` 将公开的模块项与实际的模块代码结构解耦

- `as` 关键字用于重命名项在作用域中的名称

- 不需要明确声明第三方模块

- 按文件分割代码，我们应该在一个文件的`父级`中声明模块，而不是文件本身

      