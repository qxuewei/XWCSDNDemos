# iOS 多线程详解
### Slogan : 可能是最通俗易懂的 iOS多线程 详细解析文章
## 1. 基础概念

### 1.1 进程
进程是计算机中已运行程序的实体，是线程的容器[维基百科-进程](https://zh.wikipedia.org/wiki/%E8%A1%8C%E7%A8%8B)。每个进程之间是相互独立的，每个进程均运行在器专用且收保护的内存空间内。
把工厂作为一个系统，进程类似于车间。

### 1.2 线程
线程是操作系统能够进行运算调度的最小单位[维基百科-线程](https://zh.wikipedia.org/wiki/%E7%BA%BF%E7%A8%8B)。一个进程的所有任务都在线程中执行。一个线程中执行的任务是串行的，同一时间内1个线程只能执行一个任务。
把工厂作为一个系统，线程类似于车间里干活的工人。

### 1.3 进程和线程之间关系
1. 线程是CPU调用的最小单位
2. 进程手机CPU分配资源的最小单位
3. 一个进程中至少有一个线程
4. 同一个进程内的线程共享进程的资源

### 1.4 多线程
一个进程可以开启多条线程，每条线程可以同时执行不同的任务，多线程技术可以提高程序的执行效率。同一时间内，CPU只能处理1条线程，只有1条线程在工作，多线程并发执行，其实是CPU快速的在多条线程之间调度，如果CPU调度线程的时间足够快，就造成了多线程并发执行的假象。CPU在多条线程之间调度会消耗大量的CPU资源，同时每条线程被调度的频次会降低，因此我们只开辟3-5条线程。

### 1.5 多线程优缺点
优点：1、能适当提高程序的执行效率；2、能适当提高资源利用率（CPU,内存利用率）
缺点: 1、创建线程的开销，在iOS中，内核数据结构（大约1kb）、栈空间（子线程512kb，主线程1MB）创建线程大约需要90毫秒的创建时间，如果开启大量线程会降低程序性能，线程越多，CPU在调度线程上的开销就越大。

### 1.6 线程的状态

![线程的状态](https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/sleepForTimeInterval.png)

1. 创建：实例化对象
2. 就绪：向线程对象发送start消息，线程对象被加入 “可调度线程池”，等待CPU调度，detach 方法 和 performSelectorInBackground 方法会直接实例化一个线程对象并加入 “可调度线程池”
3. 运行：CPU 负责调度 “可调度线程池”中线程的执行，线程执行完成之前，状态可能会在 “就绪” 和 “运行” 之间来回切换，此过程CPU控制。
4. 阻塞：当满足某个预定条件时，可以使用休眠或锁阻塞线程执行，影响的方法有：sleepForTimeInterval, sleepUntilDate, @synchronized(self) 线程锁。线程对象进入阻塞状态后，会被“可调度线程池” 中移除，CPU不再调度。
5. 死亡：死亡后线程对象的 isFinished 属性为YES;如果发送cancel消息，线程对象的 isCanceled 属性为YES;死亡后 stackSize == 0, 内存空间被释放。

### 1.7 线程锁的几种方案

![线程锁效率](https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/%E7%BA%BF%E7%A8%8B%E9%94%81%E6%95%88%E7%8E%87.png)
加解锁速度不表示锁的效率，只表示加解锁操作在执行时的复杂程度。

#### 1.7.1 互斥锁 

```object
@synchronized(锁对象) { 
    // 需要锁定的代码  
}
```
使用互斥锁，在同一个时间，只允许一条线程执行锁中的代码。因为互斥锁的代价非常昂贵，所以锁定的代码范围应该尽可能小，只要锁住资源读写部分的代码即可。使用互斥锁也会影响并发的目的。

#### 1.7.2 NSLock

```object
- (void)testNSLock {
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    // 需要锁定的代码
    [lock unlock];
}
```

#### 1.7.3 atomic 原子属性
OC在定义属性时有nonatomic和atomic两种选择。
atomic：原子属性，为setter方法加锁（默认就是atomic）
nonatomic：非原子属性，不会为setter方法加锁。
atomic加锁原理：

```object
 @property (assign, atomic) int age;
 - (void)setAge:(int)age
 { 
     @synchronized(self) { 
        _age = age;
     }
 }
```
atomic：线程安全，需要消耗大量的资源
nonatomic：非线程安全，适合内存小的移动设备=
iOS开发的建议:
（1）所有属性都声明为nonatomic
（2）尽量避免多线程抢夺同一块资源
（3）尽量将加锁、资源抢夺的业务逻辑交给服务器端处理，减小移动客户端的压力

#### 1.7.4 `dispatch_semaphore_t` 信号量


```object
- (void)testSemaphone {
    dispatch_semaphore_t semaphore_t = dispatch_semaphore_create(1);
    /// 线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /// 进入等待状态!
        dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
        sleep(7);
        dispatch_semaphore_signal(semaphore_t);
    });
}

```

其他的不常用的加锁操作不再赘述。

### 1.8 线程间通信


```object
//在主线程上执行操作，例如给UIImageVIew设置图片
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait
//在指定线程上执行操作
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thread withObject:(id)arg waitUntilDone:(BOOL)wait
```

## 2. 多线程实现方案

![多线程实现方案](https://raw.githubusercontent.com/qxuewei/XWResources/master/images/threads.png)

### 2.1 NSThread

```object
- (void)testNSThread {
    /// 获取当前线程
    NSThread *currentThread = [NSThread currentThread];
    
    /// 创建需要自己启动的线程
    NSThread *creatThread = [[NSThread alloc] initWithTarget:self selector:@selector(runMethod) object:nil];
    [creatThread start];

    /// 创建自动启动的线程
    [NSThread detachNewThreadSelector:@selector(runMethod2) toTarget:self withObject:nil];
}
- (void)runMethod {
    NSLog(@"runMethod ++ %@",[NSThread currentThread]);
}
- (void)runMethod2 {
    NSLog(@"runMethod2 ++ %@",[NSThread currentThread]);
}
``` 

```object
// 获取当前线程
 + (NSThread *)currentThread;
 // 创建启动线程
 + (void)detachNewThreadSelector:(SEL)selector toTarget:(id)target withObject:(id)argument;
 // 判断是否是多线程
 + (BOOL)isMultiThreaded;
 // 线程休眠 NSDate 休眠到什么时候
 + (void)sleepUntilDate:(NSDate *)date;
 // 线程休眠时间
 + (void)sleepForTimeInterval:(NSTimeInterval)ti;
 // 结束/退出当前线程
 + (void)exit;
 // 获取当前线程优先级
 + (double)threadPriority;
 // 设置线程优先级 默认为0.5 取值范围为0.0 - 1.0 
 // 1.0优先级最高
 // 设置优先级
 + (BOOL)setThreadPriority:(double)p;
 // 获取指定线程的优先级
 - (double)threadPriority NS_AVAILABLE(10_6, 4_0);
 - (void)setThreadPriority:(double)p NS_AVAILABLE(10_6, 4_0);
 // 设置线程的名字
 - (void)setName:(NSString *)n NS_AVAILABLE(10_5, 2_0);
 - (NSString *)name NS_AVAILABLE(10_5, 2_0);
 // 判断指定的线程是否是 主线程
 - (BOOL)isMainThread NS_AVAILABLE(10_5, 2_0);
 // 判断当前线程是否是主线程
 + (BOOL)isMainThread NS_AVAILABLE(10_5, 2_0); // reports whether current thread is main
 // 获取主线程
 + (NSThread *)mainThread NS_AVAILABLE(10_5, 2_0);
 - (id)init NS_AVAILABLE(10_5, 2_0);    // designated initializer
 // 创建线程
 - (id)initWithTarget:(id)target selector:(SEL)selector object:(id)argument NS_AVAILABLE(10_5, 2_0);
 // 指定线程是否在执行
 - (BOOL)isExecuting NS_AVAILABLE(10_5, 2_0);
 // 线程是否完成
 - (BOOL)isFinished NS_AVAILABLE(10_5, 2_0);
 // 线程是否被取消 (是否给当前线程发过取消信号)
 - (BOOL)isCancelled NS_AVAILABLE(10_5, 2_0);
 // 发送线程取消信号的 最终线程是否结束 由 线程本身决定
 - (void)cancel NS_AVAILABLE(10_5, 2_0);
 // 启动线程
 - (void)start NS_AVAILABLE(10_5, 2_0);
 // 线程主函数  在线程中执行的函数 都要在-main函数中调用，自定义线程中重写-main方法
 - (void)main NS_AVAILABLE(10_5, 2_0);    // thread body metho
```

### 2.2 GCD
首先关于同步，异步，并行，串行，一张图便可说清楚。
![同步异步](https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/%E5%90%8C%E6%AD%A5%E5%BC%82%E6%AD%A5%E8%AF%B4%E6%98%8E.png)

文字版：

```object
dispatch :派遣/调度
queue:队列
    用来存放任务的先进先出（FIFO）的容器
sync:同步
    只是在当前线程中执行任务，不具备开启新线程的能力
async:异步
    可以在新的线程中执行任务，具备开启新线程的能力
concurrent:并发
    多个任务并发（同时）执行
串行：
    一个任务执行完毕后，再执行下一个任务
```

#### 2.2.1 任务


```object
 - queue：队列
 - block：任务
// 1.用同步的方式执行任务
dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);

// 2.用异步的方式执行任务
dispatch_async(dispatch_queue_t queue, dispatch_block_t block);

// 3.GCD中还有个用来执行任务的函数
// 在前面的任务执行结束后它才执行，而且它后面的任务等它执行完成之后才会执行
dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
```

#### 2.2.2 队列
 * 串行队列：串行队列一次只调度一个任务，一个任务完成后再调度下一个任务。
 
```object
// 1.使用dispatch_queue_create函数创建串行队列
// 创建串行队列（队列类型传递NULL或者DISPATCH_QUEUE_SERIAL）
dispatch_queue_t queue = dispatch_queue_create("队列名称", NULL);

// 2.使用dispatch_get_main_queue()获得主队列
dispatch_queue_t queue = dispatch_get_main_queue();
注意：主队列是GCD自带的一种特殊的串行队列，放在主队列中的任务，都会放到主线程中执行。
```

* 并发队列：并发队列可以同时调度多个任务，调度任务的方式，取决于执行任务的函数；并发功能只有在异步的（dispatch_async）函数下才有效；异步状态下，开启的线程上线由GCD底层决定。

```object
// 1.使用dispatch_queue_create函数创建队列
dispatch_queue_t

//参数一： 队列名称,该名称可以协助开发调试以及崩溃分析报告 
//参数二： 队列的类型
dispatch_queue_create(const char * _Nullable label, dispatch_queue_attr_t  _Nullable attr)；

// 2.创建并发队列
dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);

// 线程中通讯常用：
dispatch_async(dispatch_get_global_queue(0, 0), ^{
    // 耗时操作
    // ...
    //放回主线程的函数
    dispatch_async(dispatch_get_main_queue(), ^{
        // 在主线程更新 UI
    });
});
```
* 全局并发队列

```object
//使用dispatch_get_global_queue函数获得全局的并发队列
dispatch_queue_t dispatch_get_global_queue(dispatch_queue_priority_t priority, unsigned long flags);
// dispatch_queue_priority_t priority(队列的优先级 )
// unsigned long flags( 此参数暂时无用，用0即可 )

//获得全局并发队列
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
```

全局并发队列的优先级：

```object
//全局并发队列的优先级
#define DISPATCH_QUEUE_PRIORITY_HIGH 2 // 高优先级
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0 // 默认（中）优先级
//注意，自定义队列的优先级都是默认优先级
#define DISPATCH_QUEUE_PRIORITY_LOW (-2) // 低优先级
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN // 后台优先级
```

#### 2.2.3 GCD 的其他用法
* 延时执行

```objective-c
dispatch_after(3.0, dispatch_get_main_queue(), ^{
   /// 延时3秒执行的操作!
});
```

* 一次性执行

```objective-c
// 使用dispatch_once函数能保证某段代码在程序运行过程中只被执行1次
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    // 只执行1次的代码(这里面默认是线程安全的)
});
```
* 调度组（队列组）

```objective-c
//创建调度组
dispatch_group_t group = dispatch_group_create();
//将调度组添加到队列，执行 block 任务
dispatch_group_async(group, queue, block);
//当调度组中的所有任务执行结束后，获得通知，统一做后续操作
dispatch_group_notify(group, dispatch_get_main_queue(), block);
```
例如：

```objective
// 分别异步执行2个耗时的操作、2个异步操作都执行完毕后，再回到主线程执行操作
dispatch_group_t group =  dispatch_group_create();
dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});
dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});
dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 等前面的异步操作都执行完毕后，回到主线程...
});
```

##### 附：参考文章：
[深入理解iOS开发中的锁](https://bestswifter.com/ios-lock/)
[iOS 中几种常用的锁总结](https://www.jianshu.com/p/1e59f0970bf5)
[iOS多线程-各种线程锁的简单介绍](https://www.jianshu.com/p/35dd92bcfe8c)


