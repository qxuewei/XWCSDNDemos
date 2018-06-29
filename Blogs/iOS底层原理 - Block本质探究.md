#iOS底层原理 - Block本质探究
### 本质
block 本质是一个OC对象，也存在 isa 指针。或者说Block 是封装了函数调用和函数调用环境的OC对象。

### 1.底层实现
编写一段最简单的OC代码顶一个block，代码如：

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int abc = 10086;
        void(^block)(int number) = ^(int number) {
            NSLog(@"%d",number);
        };
    }
    return 0;
}
```
使用 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m` 命令将其OC代码转化为底层的C++代码，观察block的底层结构。

我们打开编译生成的main.cpp代码，会发现上述代码被转化为如下：

```c++
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        int abc = 10086;
        void(*block)(int number) = ((void (*)(int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    }
    return 0;
}
```

block 代码块被定义为 `__main_block_impl_0` 结构体。

``` c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```
结构体中包含两个不同的结构体变量 `__block_impl` 和 `__main_block_desc_0`

#### __block_impl
```c++
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};
```

包含isa指针说明，block本质上也是一个OC对象，FuncPtr 指向block所封装的代码块地址，等执行block时会通过FuncPtr寻找将要执行的代码块，并且调用。

#### __main_block_desc_0

```C++
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
}
```
其中： Block_size 为当前block 占用内存大小。

#### __main_block_func_0
block 封装的代码块被定义为 `__main_block_func_0` 结构体

```c++
static void __main_block_func_0(struct __main_block_impl_0 *__cself, int number) {

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_gf_ct0sq2w17s16j4b1pz5_zx500000gn_T_main_68909d_mi_0,number);
        }
```


### 2. Block 变量捕获 
#### auto 变量
如果我们将main函数改为：

``` objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int abc = 10086;
        void(^block)() = ^() {
            NSLog(@"%d",abc);
        };
        abc = 10010;
        
        block();
    }
    return 0;
}
```

在block内部引用外部变量，我们再看看内部组成结构。同样执行 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m` 命令。
 我们可以看到，较之前，`__main_block_impl_0` 结构体新增一个 int 类型变量abc，用于存储所引用的外部变量的值。因为是值存储，所以在block生成之后，无论外部变量做何更改，abc依然是之前所定义的值。
 
``` c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int abc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _abc, int flags=0) : abc(_abc) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
}
```

#### static 变量
 因为我们所定义的外部变量 abc 之前没有任何修饰符，也就是默认的auto变量，此时block是值捕获。如果将外部变量声明为 static 类型再观察底层实现。
 
 
```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int abc = 10086;
        static int def = 100;
        void(^block)(void) = ^() {
            NSLog(@"abc: %d - def: %d",abc,def);
        };
        abc = 10010;
        def = 200;
        
        block();
    }
    return 0;
}
```

转化为c++底层实现为：

```c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int abc;
  int *def;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _abc, int *_def, int flags=0) : abc(_abc), def(_def) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

使用static 修饰的变量在block内部为指针传递，block直接捕获外部变量的内存地址，此时若外部变量在block声明之后修改，block内部也会同步进行修改。

#### 全局 变量
如果使用全局变量，block不会捕获。因为声明全局变量的类型会在程序的整个声明周期都不会被释放，所以在使用block时，直接会去访问全局变量的值。所以捕获就没有意义了，感兴趣的可以自行查看底层实现。

### 3. Block 的类型

 当我们声明一个block 并且打印他的继承链我们可以看到：
 
``` objective-c
void(^block)(void) = ^() {
            NSLog(@"abc");
        };
        
        NSLog(@"%@",[block class]);
        NSLog(@"%@",[[block class] superclass]);
        NSLog(@"%@",[[[block class] superclass] superclass]);
        NSLog(@"%@",[[[[block class] superclass] superclass] superclass]);
```
输出：

```
2018-06-28 10:37:23.901162+0800 BlockDemo[17574:719984] __NSGlobalBlock__
2018-06-28 10:37:23.901504+0800 BlockDemo[17574:719984] __NSGlobalBlock
2018-06-28 10:37:23.901522+0800 BlockDemo[17574:719984] NSBlock
2018-06-28 10:37:23.901535+0800 BlockDemo[17574:719984] NSObject
Program ended with exit code: 0
```

##### 故我们可得出结论block的继承关系为：__NSGlobalBlock__ ： __NSGlobalBlock ： NSBlock : NSObject

从而也进一步证明了block 本质上为 OC对象。并且，在不引用外部变量的情况下，block为 `NSGlobalBlock` 类型。

我们定义三个不同的block，分别打印他们的实际类型：

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        void(^block1)(void) = ^() {
            NSLog(@"abc");
        };
        NSLog(@"%@",[block1 class]);
        
        int abc = 1;
        void(^block2)(void) = ^() {
            NSLog(@"abc: %d",abc);
        };
        NSLog(@"%@",[block2 class]);
        
        
        NSLog( @"%@", [^(){
            NSLog(@"hello %d",abc);
        } class]);
        
        
    }
    return 0;
}
```

输出：

```
2018-06-28 10:48:32.096859+0800 BlockDemo[17719:728991] __NSGlobalBlock__
2018-06-28 10:48:32.097224+0800 BlockDemo[17719:728991] __NSMallocBlock__
2018-06-28 10:48:32.097243+0800 BlockDemo[17719:728991] __NSStackBlock__
```
我们可以得出结论，
##### block 类型分三种：分别为 `__NSGlobalBlock__` `__NSMallocBlock__` `__NSStackBlock__`

他们在内存中位置分别：

![Snip20180628_6](http://p95ytk0ix.bkt.clouddn.com/2018-06-28-Snip20180628_6.png)

那他们是如何区分的呢？可以使用如下表格来说明:

|Block 类型|条件|
|:----|-----:|
|__NSGlobalBlock__|block 内部没有访问auto变量|
|__NSStackBlock__|block 内部访问了 auto变量|
|__NSMallocBlock__|__NSStackBlock__ 调用了copy|

__NSStackBlock__ 执行 copy 后会将栈区的block 复制到堆区，便于程序员管理，那其他类型的block执行 copy 会有什么变化呢？如下表所示：

|Block 类型|存储域|执行 copy 后效果|
|:----|-----:|-----:|
|__NSGlobalBlock__|程序的数据区域|无任何改变|
|__NSStackBlock__|栈|从栈复制到堆|
|__NSMallocBlock__|堆|引用计数器加1|


### 4. ARC 下某些情况下系统会对 Block 自动执行一次 copy 操作，将 Block 从栈区转移到堆区

#### 1.当 block 作为函数返回值时


```objective-c
typedef void(^MyBlock)(void);

MyBlock testFunc() {
    int a = 10;
    MyBlock myBlock = ^ {
        NSLog(@"test --- %d",a);
    };
    return myBlock;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MyBlock myB = testFunc();
        NSLog(@"%@",[myB class]);
    }
    return 0;
}
```

如果此代码在MRC 环境下，会崩溃。Block访问的变量已被释放。 如果在ARC环境下，在参数的返回值为block时，系统会对block自动执行一次 copy 操作，使其变为 __NSMallocBlock__ 类型。

#### 2.当Block 被强指针引用时会自动执行copy操作

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int abc = 10;
        MyBlock myB = ^ {
            NSLog(@"+++ %d",abc);
        };
        NSLog(@"%@",[myB class]);
    }
    return 0;
}
```
如上代码，在MRC环境输出：`__NSStackBlock__` 。在 ARC环境输出：`__NSMallocBlock__`

#### 3.当 Block 做为cocoa API 或 GCD API 的方法参数时也会自动执行 copy 操作
例如：

```objective-c
   NSArray *array = @[@1];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
        }];
```


```objective-c
  static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
        });
```

所以在 MAC 环境下的block属性必须使用 copy 修饰，而ARC环境下的block属性即可使用 strong 修饰，也可以使用 copy 修饰，两者都会对block自动执行copy操作，故无任何区别。

### 5.Block 内部引用对象
观察如下代码

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        {
            XWPerson *person = [[XWPerson alloc] init];
            person.age = 10;
            ^{
                NSLog(@"person -- %ld",(long)person.age);
            }();
        }
        
        NSLog(@"*******");
    }
    return 0;
}
```

会发现当 函数体内 大括号执行完毕后 XWPerson 即被释放，此时的block 是 栈类型的Block 即 `__NSStackBlock__`. 存储在栈区的block即便引用了对象，也会跟随大括号一并释放。

如果将以上代码改为：

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MyBlock myBlock;
        {
            XWPerson *person = [[XWPerson alloc] init];
            person.age = 10;
            myBlock = ^{
                NSLog(@"person -- %ld",(long)person.age);
            };
            myBlock();
            
        }
        
        NSLog(@"*******");
    }
    return 0;
}
```
我们会发现在执行到 **** 时，person 对象依然没有被释放，此时block 已经对 person 对象进行了强引用。因为 此时 的block 为强指针引用，类型为 堆block `__NSMallocBlock__`.
为什么堆 block 会对外部对象强引用呢？ 

此时 使用 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m` 命令 观察其底层 c++ 实现：

此时block 定义为：

```objective-c
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  XWPerson *__strong person;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, XWPerson *__strong _person, int flags=0) : person(_person) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

其中 main_block_desc_0 定义为：

```objective-c
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} 
```
 
 较之前block引用基本成员类型时，其 main_block_desc_0 多了两个参数分别为 copy 和 dispose。并且传入的都是 `__main_block_impl_0` block 本身。
 
 当 block 执行 copy 操作的时候，执行的是
  
```c++
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->person, (void*)src->person, 3/*BLOCK_FIELD_IS_OBJECT*/);}
```
方法。最终调用的 `_Block_object_assign` 方法会对block引入的对象 person 进行引用计数操作，当所引入的对象使用 strong 修饰则使其引用计数加1，若使用weak修饰则引用计数不变。

当 block 执行完毕的时候会调用 dispose 方法，而dispose 在底层会调用 

```c++
static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->person, 3/*BLOCK_FIELD_IS_OBJECT*/);}
```
方法，将block内部引用的对象成员引用计数减1，如果此时外部对象使用strong 修饰，引用计数在copy加1后 此时再减1.依然会强引用外部对象，不会释放，如果使用weak修饰，此时因为自身以及被释放，所以不会再持有所引用外部对象，然而此时所引用外部对象是否会被释放取决于它的引用计数是否为 0。

### 6. block 内部修改外部变量的值。
我们知道，如果block 内部捕获的外部变量为 auto 类型，在block 内部生成的是该变量的值类型变量，无法通过block内部的值修改外部变量。
如果想在block内部修改外部变量的值有几种方法？

#### 1.外部变量使用 static 修饰
使用 static 修饰的变量block内部会直接获取到变量的内存地址，可以直接修改。

#### 2.使用 __block
若使用 static 变量修饰，该变量的生命周期就会无限延长，这不符合我们的设计思路，故我们可以使用 `__block` 来修饰外部变量，从而达到在block内部修改外部成员变量的目的。
那 `__block` 是如何实现此需求的呢？ 

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block int a = 10;
        MyBlock block = ^{
            a = 20;
            NSLog(@"a --- %d",a);
        };
        block();
    }
    return 0;
}
```

使用 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m` 命令将其转化为c++ 实现：


```c++
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_a_0 *a; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_a_0 *_a, int flags=0) : a(_a->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

我们可知 通过 `__block` 修饰的外部成员变量被定义为 `__Block_byref_a_0` 对象！它的声明为：

```c++
struct __Block_byref_a_0 {
  void *__isa;
__Block_byref_a_0 *__forwarding;
 int __flags;
 int __size;
 int a;
};
```
 此时在main函数内声明 `__block` 类型的变量会以此方式初始化：
 
```c++
     __attribute__((__blocks__(byref))) __Block_byref_a_0 a = {(void*)0,(__Block_byref_a_0 *)&a, 0, sizeof(__Block_byref_a_0), 10};
```
 其中 `__forwarding` 保存的原变量 a 的内存地址，`size` 为当前变量的内存大小，10 保存未原变量的值。
 
 如此，我们在block 内部修改 原变量时：
 
```c++
(a->__forwarding->a) = 20;
```
直接取原变量的地址进行更改，从而实现在block内部更改外部变量。

### 7. __block 和 对象类型的auto变量 的内存管理
对于block内部捕获的对象类型的auto变量和__block修饰的变量。如果block在栈区，不会对他们进行内存管理，即不会强引用外部变量

如果block被复制到堆区，则会调用内部 copy 函数对外部 __block 修饰的变量和对象类型的auto变量进行内存管理。

当block从内存中移除时，同样也会调用dispose函数对所引用的外部变量进行释放。

### 8. 循环引用
使用 block 很容易形成循环引用，如果一个类中定义的block内部引用了该类的外部属性，包括 类本身的 self， 均会导致 self 强引用 block，block 也强引用 self。导致self不会被释放。如下代码就会造成循环引用：

```objective-c
.h
#import <Foundation/Foundation.h>

@interface XWPerson : NSObject

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, copy)  void(^personBlock)(void);

@end
```


```objective-c
.m
#import "XWPerson.h"

@implementation XWPerson

- (void)test {
    self.personBlock = ^{
        NSLog(@"%d",self.age); //此处若即便使用 _age  也会产生循环引用。
    };
}

- (void)dealloc {
    NSLog(@" XWPerson -- dealloc  --  age:%ld",(long)_age);
}
@end
```

产生循环引用的本质原因是，在block内部实现里，会将self 捕获到block内部，并且strong 强引用。如下代码所示：

```c++
struct __XWPerson__test_block_impl_0 {
  struct __block_impl impl;
  struct __XWPerson__test_block_desc_0* Desc;
  XWPerson *const __strong self;
  __XWPerson__test_block_impl_0(void *fp, struct __XWPerson__test_block_desc_0 *desc, XWPerson *const __strong _self, int flags=0) : self(_self) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```


### 9. 避免产生循环引用

#### 1. (ARC 环境下) __weak ： 弱引用对象，指向的对象销毁时，会自动将指针置为nil。因此一般通过__weak来解决问题。

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        XWPerson *person1 = [[XWPerson alloc] init];
        person1.age = 18;
        __weak typeof(person1) weakPerson = person1;
        person1.personBlock = ^{
            NSLog(@"%ld",(long)weakPerson.age);
        };
        person1.personBlock();
    }
    return 0;
}
```
#### 2. (ARC / MRC 环境下) __unsafe_unretained ： 弱引用对象，指向的对象销毁时，不会自动将指针置为nil。再次引用该对象时可能会产生访问僵尸对象的错误，产生崩溃，故不建议使用！
` __unsafe_unretained XWPerson *person1 = [[XWPerson alloc] init];`
#### 3. (ARC / MRC 环境下) __block : 使用__block 修饰对象. 在ARC环境下-前提是一定要调用此block，并且要在block内部将所引用的外部变量手动置nil。因为 MRC 环境下，引用__block 修饰的对象不会使其引用计数加1，所以不需要手动置nil，也不是必需要使用block。

```objective-c
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block XWPerson *person1 = [[XWPerson alloc] init];
        person1.age = 18;
        person1.personBlock = ^{
            NSLog(@"%ld",(long)person1.age);
            person1 = nil;
        };
        person1.personBlock();
    }
    return 0;
}
```


