# iOS底层原理探究-OC对象的本质

## 前言
以三个底层的面试题开篇，这也是我在面试公司iOS的时候经常问的问题，文章末尾会结合网上大神分享和我的理解给出答案。
>1. OC 中对象的本质是什么？
2. OC中类与结构体的区别是什么？
3. 一个NSObject对象占多少内存？

## 1. 面向对象的Objective-C

我们平时写的 `OC` 代码底层实现为 `C/C++` 代码，因为 `Runtime` 让 `OC` 具备了面向对象的特点，而后底层的 `C/C++` 会转换成底层的 汇编 代码，最终被被解析成计算机能识别的 机器语言 。而    `OC` 中的类，正是正是基于 `C/C++` 的结构体实现的。我们可以通过 `clang` 命令将我们平时所写的 `OC` 代码转换为 `C/C++` 代码。这是转换代码：

``` objective-c
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc 源文件名 -o 目标文件名
```
如果需要链接其他框架，使用 `-framework参数` 比如 `-framework UIKit`

如： 我们进入源文件所在的目录，执行 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main.cpp` 会在当前目录生成一个main.cpp的文件，这就是一个最简单的OC文件的 `C++` 实现。

通过转换之后我们很容易找到 `NSObject` 类的真正实现：
 
```objective-c
struct NSObject_IMPL {
	Class isa;
};
```
只有一个 名为 `isa` 的 `Class` 实例。继续探寻 `Class` 的声明：

```objective-c
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;
```
发现 `Class` 实际上是一个指向 `objc_class` 的结构体指针。

也就是说 `NSObject` 最终声明为一个 指向结构体 `objc_class` 的名为 `isa` 的结构体指针。既然是指针，在32位系统中占 4个 字节，在64位系统中占 8 个字节。如何查看自己的Mac是多少位呢？可以在终端 输入 `uname -a ` 若末尾显示 x86_64 则代表是64位系统，如果末尾显示 i686 则代表是32 系统。目前我们所使用的大多都是 64 位。那在 `OC` 中一个 `NSObject` 对象占用8个字节吗？答案是否定的，我们继续分析。

我们知道在 `OC` 的对象实例中， 真正给对象分配内存的方式是

```objective-c
+ (instancetype)allocWithZone:(struct _NSZone *)zone OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
```

而 `OC` 中调用方法最终是通过 `Runtime` 运行时机制实现的，而 `Runtime` 的源码 Apple 已经开源，我们可以通过源码进行分析。 [Runtime源码下载链接](https://opensource.apple.com/source/objc4/), 
注： 更多 `Runtime` 的分析文章可参考本人的另一篇分享文章 [iOS底层原理探究-Runtime](https://juejin.im/post/5aec1d676fb9a07aa11411fe)


