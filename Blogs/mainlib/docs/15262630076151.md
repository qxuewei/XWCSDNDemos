# Block 详解
### Slogan : 可能是最通俗易懂的Block详细解析文章
## 1. 概述
首先解释闭包的概念：
> In programming languages, a closure is a function or reference to a function together with a referencing environment—a table storing a reference to each of the non-local variables (also called free variables or upvalues) of that function.

翻译为：一个函数或指向函数的指针 和 该函数执行的外部的上下文变量也就是自由变量；
Block 是 Objective-C 对于闭包的实现。Block 可以当作匿名函数，可以在两个对象间将语句当做数据来进行传递。具有封闭性closure，方便取得上下文相关状态信息。

关于 Block 的几个特性:
1. 本质是对象，使代码高聚合。
2. 可以嵌套定义，定义Block方法和定义函数方法类似。
3. Block 可以定义在方法内部或外部。
4. 只有调用Block时候，才会执行其 {} 体内的方法。


