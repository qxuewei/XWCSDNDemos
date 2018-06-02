# iOS底层原理探究- NSObject 所占内存

## 面向对象的Objective-C

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

也就是说 `NSObject` 最终声明为一个 指向结构体 `objc_class` 的名为 `isa` 的结构体指针。既然是指针，在32位系统中占 4个 字节，在64位系统中占 8 个字节。如何查看自己的Mac是多少位呢？可以在终端 输入 `uname -a ` 若末尾显示 x86_64 则代表是64位系统，如果末尾显示 i686 则代表是32 系统。目前我们所使用的大多都是 64 位。

##### 使用 Runtime 中 `class_getInstanceSize` 输出一个类的实例对象的成员变量的大小

```objective-c
        NSObject *obj = [[NSObject alloc] init];
        NSLog(@"%zd",class_getInstanceSize([obj class]));
```
输出：
![Snip20180529_3](http://p95ytk0ix.bkt.clouddn.com/2018-05-29-Snip20180529_3.png)

由此可见，一个 NSObject 只有一个成员变量 即 isa，它所占 8 个字节的大小。
我们可通过 [objc4源码](https://opensource.apple.com/tarballs/objc4/)得出此结论。

![Snip20180529_4](http://p95ytk0ix.bkt.clouddn.com/2018-05-29-Snip20180529_4.png)

![Snip20180529_5](http://p95ytk0ix.bkt.clouddn.com/2018-05-29-Snip20180529_5.png)

>Class's ivar size rounded up to a pointer-size boundary.
一个类的所有成员变量所占用的空间。

那在 `OC` 中一个 `NSObject` 对象占用8个字节吗？答案是否定的，我们继续分析。

##### 使用 `malloc_size(const void *ptr)` 输出一个类实际分配的内存大小

```objective-c
        NSObject *obj = [[NSObject alloc] init];
        NSLog(@"%zd",malloc_size((__bridge const void *)obj));
```
输出：

```
2018-05-29 07:40:24.270554+0800 XWTest0[25108:1196172] 16
```

##### 此外我们也可以用这种方式来证明一个NSObject对象占 16 个字节
我们知道在 `OC` 的对象实例中， 真正给对象分配内存的方式是

```objective-c
+ (instancetype)allocWithZone:(struct _NSZone *)zone OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
```

我们可以探究 `allocWithZone` 方法的底层实现, 同样查看Apple开源的OC源码 [objc4源码](https://opensource.apple.com/tarballs/objc4/)

![Snip20180602_1](http://p95ytk0ix.bkt.clouddn.com/2018-06-02-Snip20180602_1.png)

![Snip20180602_2](http://p95ytk0ix.bkt.clouddn.com/2018-06-02-Snip20180602_2.png)

![Snip20180602_3](http://p95ytk0ix.bkt.clouddn.com/2018-06-02-Snip20180602_3.png)

![Snip20180602_4](http://p95ytk0ix.bkt.clouddn.com/2018-06-02-Snip20180602_4.png)

#### 所有的OC对象至少为16字节。进一步证明 NSObject类实际所占用的内存空间为 16 个字节





