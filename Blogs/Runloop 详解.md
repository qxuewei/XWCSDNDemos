# Runloop
## 1. 概述
一般来说，一个线程只能执行一个任务，执行完就会退出，如果我们需要一种机制，让线程能随时处理时间但并不退出，那么 RunLoop 就是这样的一个机制。Runloop是事件接收和分发机制的一个实现。

RunLoop实际上是一个对象，这个对象在循环中用来处理程序运行过程中出现的各种事件（比如说触摸事件、UI刷新事件、定时器事件、Selector事件），从而保持程序的持续运行；而且在没有事件处理的时候，会进入睡眠模式，从而节省CPU资源，提高程序性能。

简单的说run loop是事件驱动的一个大循环，如下代码所示：

```objective-c
int main(int argc, char * argv[]) {
     //程序一直运行状态
     while (AppIsRunning) {
          //睡眠状态，等待唤醒事件
          id whoWakesMe = SleepForWakingUp();
          //得到唤醒事件
          id event = GetEvent(whoWakesMe);
          //开始处理事件
          HandleEvent(event);
     }
     return 0;
}
```

## 2. Runloop 基本作用

### 2.1 保持程序持续运行
程序一启动就会开一个主线程，主线程一开起来就会跑一个主线程对应的Runloop, Runloop保证主线程不会被销毁，也就保证了程序的持续运行。不光iOS，在其他的编程平台，Android, Windows等都有一个类似Runloop的机制保证程序的持续运行。

### 2.2 处理App中的各类事件

#### 系统级别
GCD, mach kernel, block, pthread

#### 应用层
NSTimer, UIEvent, Autorelease, NSObject(NSDelayedPerforming), NSObject(NSThreadPerformAddition), CADisplayLink, CATransition, CAAnimation, dispatch_get_main_queue() (GCD 中dispatch到main queue的block会被dispatch到main Runloop中执行)， NSPort, NSURLConnection, AFNetworking（这个第三方网络请求框架使用在开启新线程中添加自己到Runloop监听事件）

### 2.3 节省CPU资源，提高程序性能
程序运行起来时，当什么操作都没有做的时候，Runloop告诉CPU, 现在没有事情做，我要去休息， 这时CPU就会将资源释放出来去做其他的事情，当有事情做的时候Runloop就会立马起来去做事情。

## 3. Runloop 的开启

#### 程序入口
iOS 程序的入口是 main 函数

``` objective-c
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```
程序主线程一开起来，就会跑一个和主线程对应的Runloop, 那么Runloop一定是在程序的入口main函数中开启。

#### 在main thread 堆栈中所处的位置
堆栈最底层是start(dyld)，往上依次是main，UIApplication(main.m) -> GSEventRunModal(Graphic Services) -> RunLoop(包含CFRunLoopRunSpecific，__CFRunLoopRun，__CFRunLoopDoSouces0，CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION) -> Handle Touch Event

## 4. Runloop 原理

CFRunLoop开源代码：http://opensource.apple.com/source/CF/CF-855.17/

Runloop 源码：

``` objective-c
void CFRunLoopRun(void) {	/* DOES CALLOUT */
    int32_t result;
    do {
        result = CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
        CHECK_FOR_FORK();
    } while (kCFRunLoopRunStopped != result && kCFRunLoopRunFinished != result);
}
```

我们发现RunLoop确实是do while通过判断result的值实现的。因此，我们可以把RunLoop看成一个死循环。如果没有RunLoop，UIApplicationMain函数执行完毕之后将直接返回，也就没有程序持续运行一说了。

执行顺序的伪代码：

```objective-c
int32_t __CFRunLoopRun()
{
    // 通知即将进入runloop
    __CFRunLoopDoObservers(KCFRunLoopEntry);
    
    do
    {
        // 通知将要处理timer和source
        __CFRunLoopDoObservers(kCFRunLoopBeforeTimers);
        __CFRunLoopDoObservers(kCFRunLoopBeforeSources);
        
        // 处理非延迟的主线程调用
        __CFRunLoopDoBlocks();
        // 处理Source0事件
        __CFRunLoopDoSource0();
        
        if (sourceHandledThisLoop) {
            __CFRunLoopDoBlocks();
         }
        /// 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
        if (__Source0DidDispatchPortLastTime) {
            Boolean hasMsg = __CFRunLoopServiceMachPort();
            if (hasMsg) goto handle_msg;
        }
            
        /// 通知 Observers: RunLoop 的线程即将进入休眠(sleep)。
        if (!sourceHandledThisLoop) {
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
        }
            
        // GCD dispatch main queue
        CheckIfExistMessagesInMainDispatchQueue();
        
        // 即将进入休眠
        __CFRunLoopDoObservers(kCFRunLoopBeforeWaiting);
        
        // 等待内核mach_msg事件
        mach_port_t wakeUpPort = SleepAndWaitForWakingUpPorts();
        
        // 等待。。。
        
        // 从等待中醒来
        __CFRunLoopDoObservers(kCFRunLoopAfterWaiting);
        
        // 处理因timer的唤醒
        if (wakeUpPort == timerPort)
            __CFRunLoopDoTimers();
        
        // 处理异步方法唤醒,如dispatch_async
        else if (wakeUpPort == mainDispatchQueuePort)
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__()
            
        // 处理Source1
        else
            __CFRunLoopDoSource1();
        
        // 再次确保是否有同步的方法需要调用
        __CFRunLoopDoBlocks();
        
    } while (!stop && !timeout);
    
    // 通知即将退出runloop
    __CFRunLoopDoObservers(CFRunLoopExit);
}
```

## 5. Runloop 对象

RunLoop对象包括Fundation中的NSRunLoop对象和CoreFoundation中的CFRunLoopRef对象。因为Fundation框架是基于CFRunLoopRef的封装，因此我们学习RunLoop还是要研究CFRunLoopRef 源码。

### 获得Runloop 对象

```objective-c
//Foundation
[NSRunLoop currentRunLoop]; // 获得当前线程的RunLoop对象
[NSRunLoop mainRunLoop]; // 获得主线程的RunLoop对象
 
//Core Foundation
CFRunLoopGetCurrent(); // 获得当前线程的RunLoop对象
CFRunLoopGetMain(); // 获得主线程的RunLoop对象
```

值的注意的是子线程中的runloop不是默认开启的，需要手动开启，当调用 [NSRunLoop currentRunLoop] 时，若已存在当前线程的runloop返回，若不存在创建一个新的runloop对象再返回。

## 6. Runloop 和 线程
### 6.1 Runloop 和 线程 之间的关系

1. 每条线程都有唯一的一个与之对应的Runloop 对象
2. 主线程的Runloop已经自动创建好了，子线程的Runloop需要手动创建
3. Runloop在第一次获取时创建，在线程结束时销毁
4. Thread 包含一个CFRunloop, 一个CFRunloop 包含一种CFRunloopMode, model 包含 CFRunloopSource, CFRunloopTimer, CFRunloopObserver.

![RunloopModels](https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/runloopmodels.png)

### 6.2 主线程想关联的Runloop创建

CFRunloopRef 源码

```objective-c
// 创建字典
 CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks);

// 创建主线程 根据传入的主线程创建主线程对应的RunLoop
 CFRunLoopRef mainLoop = __CFRunLoopCreate(pthread_main_thread_np());

// 保存主线程 将主线程-key和RunLoop-Value保存到字典中
 CFDictionarySetValue(dict, pthreadPointer(pthread_main_thread_np()), mainLoop);
```

### 6.3 创建与子线程想关联的Runloop
Apple 不允许直接创建Runloop, 它只提供了两个自动获取的函数： CFRunLoopGetMain() 和 CFRunLoopGetCurrent()。
CFRunLoopRef源码:

``` objective-c
/// 用DefaultMode启动
void CFRunLoopRun(void) {
    CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
}
 
/// 用指定的Mode启动，允许设置RunLoop超时时间
int CFRunLoopRunInMode(CFStringRef modeName, CFTimeInterval seconds, Boolean stopAfterHandle) {
    return CFRunLoopRunSpecific(CFRunLoopGetCurrent(), modeName, seconds, returnAfterSourceHandled);
}
 
/// RunLoop的实现
int CFRunLoopRunSpecific(runloop, modeName, seconds, stopAfterHandle) {
    
    /// 首先根据modeName找到对应mode
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(runloop, modeName, false);
    /// 如果mode里没有source/timer/observer, 直接返回。
    if (__CFRunLoopModeIsEmpty(currentMode)) return;
    
    /// 1. 通知 Observers: RunLoop 即将进入 loop。
    __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);
    
    /// 内部函数，进入loop
    __CFRunLoopRun(runloop, currentMode, seconds, returnAfterSourceHandled) {
        
        Boolean sourceHandledThisLoop = NO;
        int retVal = 0;
        do {
 
            /// 2. 通知 Observers: RunLoop 即将触发 Timer 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
            /// 3. 通知 Observers: RunLoop 即将触发 Source0 (非port) 回调。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
            /// 4. RunLoop 触发 Source0 (非port) 回调。
            sourceHandledThisLoop = __CFRunLoopDoSources0(runloop, currentMode, stopAfterHandle);
            /// 执行被加入的block
            __CFRunLoopDoBlocks(runloop, currentMode);
 
            /// 5. 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
            if (__Source0DidDispatchPortLastTime) {
                Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
                if (hasMsg) goto handle_msg;
            }
            
            /// 通知 Observers: RunLoop 的线程即将进入休眠(sleep)。
            if (!sourceHandledThisLoop) {
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
            }
            
            /// 7. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
            /// • 一个基于 port 的Source 的事件。
            /// • 一个 Timer 到时间了
            /// • RunLoop 自身的超时时间到了
            /// • 被其他什么调用者手动唤醒
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
                mach_msg(msg, MACH_RCV_MSG, port); // thread wait for receive msg
            }
 
            /// 8. 通知 Observers: RunLoop 的线程刚刚被唤醒了。
            __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);
            
            /// 收到消息，处理消息。
            handle_msg:
 
            /// 9.1 如果一个 Timer 到时间了，触发这个Timer的回调。
            if (msg_is_timer) {
                __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
            } 
 
            /// 9.2 如果有dispatch到main_queue的block，执行block。
            else if (msg_is_dispatch) {
                __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            } 
 
            /// 9.3 如果一个 Source1 (基于port) 发出事件了，处理这个事件
            else {
                CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
                sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
                if (sourceHandledThisLoop) {
                    mach_msg(reply, MACH_SEND_MSG, reply);
                }
            }
            
            /// 执行加入到Loop的block
            __CFRunLoopDoBlocks(runloop, currentMode);
            
 
            if (sourceHandledThisLoop && stopAfterHandle) {
                /// 进入loop时参数说处理完事件就返回。
                retVal = kCFRunLoopRunHandledSource;
            } else if (timeout) {
                /// 超出传入参数标记的超时时间了
                retVal = kCFRunLoopRunTimedOut;
            } else if (__CFRunLoopIsStopped(runloop)) {
                /// 被外部调用者强制停止了
                retVal = kCFRunLoopRunStopped;
            } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
                /// source/timer/observer一个都没有了
                retVal = kCFRunLoopRunFinished;
            }
            
            /// 如果没超时，mode里没空，loop也没被停止，那继续loop。
        } while (retVal == 0);
    }
    
    /// 10. 通知 Observers: RunLoop 即将退出。
    __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
}
```
可以看出，线程和 RunLoop 之间是一一对应的，其关系是保存在一个全局的 Dictionary 里。线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。你只能在一个线程的内部获取其 RunLoop（主线程除外）。

[NSRunLoop currentRunLoop];方法调用时，会先看一下字典里有没有存子线程相对用的RunLoop，如果有则直接返回RunLoop，如果没有则会创建一个，并将与之对应的子线程存入字典中。

## 7. Runloop 相关类

 Core Foundation中关于RunLoop的5个类：
 
```
CFRunLoopRef  //获得当前RunLoop和主RunLoop
CFRunLoopModeRef  //运行模式，只能选择一种，在不同模式中做不同的操作
CFRunLoopSourceRef  //事件源，输入源
CFRunLoopTimerRef //定时器时间
CFRunLoopObserverRef //观察者
```

### 7.1 CFRunLoopModeRef  

 一个Runloop包含若干个Mode, 每个Mode又包含若干个Source / Timer / Observer. 每次调用Runloop 的主函数时，只能指定其中一个Mode, 这个Mode被称作 CurrentMode. 如果需要切换Mode, 只能退出Loop, 再重新指定一个Mode进入。这样做主要是为了分隔开不同组的 Source/Timer/Observer, 让其互不影响。
 
 系统默认注册了 5 个Mode, 其中常见的有第 1，2 种：
 
``` objective-c
1. kCFRunLoopDefaultMode：App的默认Mode，通常主线程是在这个Mode下运行
2. UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
3. UIInitializationRunLoopMode: 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用
4. GSEventReceiveRunLoopMode: 接受系统事件的内部 Mode，通常用不到
5. kCFRunLoopCommonModes: 这是一个占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode
```

上面的Source/Timer/Observer 被统称为 model item， 一个item 可以被同时加入多个 Mode. 但一个item被重复加入同一个mode时是不会有效果的。如果一个mode中一个item都没有，则Runloop会直接退出，不进入循环。

Mode 间切换
我们平时在开发中一定遇到过，当我们使用NSTimer每一段时间执行一些事情时滑动UIScrollView，NSTimer就会暂停，当我们停止滑动以后，NSTimer又会重新恢复的情况，我们通过一段代码来看一下：

```objective-c
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
    // 加入到RunLoop中才可以运行
    // 1. 把定时器添加到RunLoop中，并且选择默认运行模式NSDefaultRunLoopMode = kCFRunLoopDefaultMode
    // [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    // 当textFiled滑动的时候，timer失效，停止滑动时，timer恢复
    // 原因：当textFiled滑动的时候，RunLoop的Mode会自动切换成UITrackingRunLoopMode模式，因此timer失效，当停止滑动，RunLoop又会切换回NSDefaultRunLoopMode模式，因此timer又会重新启动了

    // 2. 当我们将timer添加到UITrackingRunLoopMode模式中，此时只有我们在滑动textField时timer才会运行
    // [[NSRunLoop mainRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];

    // 3. 那个如何让timer在两个模式下都可以运行呢？
    // 3.1 在两个模式下都添加timer 是可以的，但是timer添加了两次，并不是同一个timer
    // 3.2 使用站位的运行模式 NSRunLoopCommonModes标记，凡是被打上NSRunLoopCommonModes标记的都可以运行，下面两种模式被打上标签
    //0 : <CFString 0x10b7fe210 [0x10a8c7a40]>{contents = "UITrackingRunLoopMode"}
    //2 : <CFString 0x10a8e85e0 [0x10a8c7a40]>{contents = "kCFRunLoopDefaultMode"}
    // 因此也就是说如果我们使用NSRunLoopCommonModes，timer可以在UITrackingRunLoopMode，kCFRunLoopDefaultMode两种模式下运行
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    NSLog(@"%@",[NSRunLoop mainRunLoop]);
}
-(void)show
{
    NSLog(@"-------");
}
```

由上述代码可以看出，NSTimer不管用是因为Mode的切换，因为如果我们在主线程使用定时器，此时RunLoop的Mode为kCFRunLoopDefaultMode，即定时器属于kCFRunLoopDefaultMode，那么此时我们滑动ScrollView时，RunLoop的Mode会切换到UITrackingRunLoopMode，因此在主线程的定时器就不在管用了，调用的方法也就不再执行了，当我们停止滑动时，RunLoop的Mode切换回kCFRunLoopDefaultMode，所有NSTimer就又管用了。

使用GCD也可以创建计时器，而且更为精确：

```objective-c
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    //1.创建一个GCD定时器
    /*
     第一个参数:表明创建的是一个定时器
     第四个参数:队列
     */
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 需要对timer进行强引用，保证其不会被释放掉，才会按时调用block块
    // 局部变量，让指针强引用
    self.timer = timer;
    //2.设置定时器的开始时间,间隔时间,精准度
    /*
     第1个参数:要给哪个定时器设置
     第2个参数:开始时间
     第3个参数:间隔时间
     第4个参数:精准度 一般为0 在允许范围内增加误差可提高程序的性能
     GCD的单位是纳秒 所以要*NSEC_PER_SEC
     */
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);

    //3.设置定时器要执行的事情
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"---%@--",[NSThread currentThread]);
    });
    // 启动
    dispatch_resume(timer);
}
```

### 7.2 CFRunLoopSourceRef

Source分为两种：

Source0：非基于Port的 用于用户主动触发的事件（点击button 或点击屏幕）
Source1：基于Port的 通过内核和其他线程相互发送消息（与内核相关）
注意：Source1在处理的时候会分发一些操作给Source0去处理


### 7.3 CFRunLoopTimer
NSTimer是对RunLoopTimer的封装


```objective-c
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

- (void)performSelector:(SEL)aSelector withObject:(id)anArgument afterDelay:(NSTimeInterval)delay inModes:(NSArray *)modes;

+ (CADisplayLink *)displayLinkWithTarget:(id)target selector:(SEL)sel;
- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSString *)mode;

```

### 7.4 CFRunLoopObserverRef

CFRunLoopObserverRef是观察者，能够监听RunLoop的状态改变。
我们直接来看代码，给RunLoop添加监听者，监听其运行状态：


``` objective-c
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
     //创建监听者
     /*
     第一个参数 CFAllocatorRef allocator：分配存储空间 CFAllocatorGetDefault()默认分配
     第二个参数 CFOptionFlags activities：要监听的状态 kCFRunLoopAllActivities 监听所有状态
     第三个参数 Boolean repeats：YES:持续监听 NO:不持续
     第四个参数 CFIndex order：优先级，一般填0即可
     第五个参数 ：回调 两个参数observer:监听者 activity:监听的事件
     */
     /*
     所有事件
     typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
     kCFRunLoopEntry = (1UL << 0),   //   即将进入RunLoop
     kCFRunLoopBeforeTimers = (1UL << 1), // 即将处理Timer
     kCFRunLoopBeforeSources = (1UL << 2), // 即将处理Source
     kCFRunLoopBeforeWaiting = (1UL << 5), //即将进入休眠
     kCFRunLoopAfterWaiting = (1UL << 6),// 刚从休眠中唤醒
     kCFRunLoopExit = (1UL << 7),// 即将退出RunLoop
     kCFRunLoopAllActivities = 0x0FFFFFFFU
     };
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"RunLoop进入");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"RunLoop要处理Timers了");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"RunLoop要处理Sources了");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"RunLoop要休息了");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"RunLoop醒来了");
                break;
            case kCFRunLoopExit:
                NSLog(@"RunLoop退出了");
                break;

            default:
                break;
        }
    });

    // 给RunLoop添加监听者
    /*
     第一个参数 CFRunLoopRef rl：要监听哪个RunLoop,这里监听的是主线程的RunLoop
     第二个参数 CFRunLoopObserverRef observer 监听者
     第三个参数 CFStringRef mode 要监听RunLoop在哪种运行模式下的状态
     */
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
     /*
     CF的内存管理（Core Foundation）
     凡是带有Create、Copy、Retain等字眼的函数，创建出来的对象，都需要在最后做一次release
     GCD本来在iOS6.0之前也是需要我们释放的，6.0之后GCD已经纳入到了ARC中，所以我们不需要管了
     */
    CFRelease(observer);
}
```
 运行结果：
 ![结果](https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/runloop2.png)

## 8. Runloop 退出

1. 主线程销魂Runloop退出
2. Mode中有一些Timer, Source, Observer, 这些保证Mode不为空时保证Runloop没有空转并且是在运行的，当Mode中为空的时候，Runloop会立刻退出。
3. 我们在启动Runloop的时候可以设置什么时候停止。


``` objective-c
[NSRunLoop currentRunLoop]runUntilDate:<#(nonnull NSDate *)#>
[NSRunLoop currentRunLoop]runMode:<#(nonnull NSString *)#> beforeDate:<#(nonnull NSDate *)#>
```

## 9. 一些有关Runloop的问题

### 9.1 基于NSTimer的轮播器什么情况下会被页面滚动暂停，怎样可以不被暂停，为什么？

NSTimer不管用是因为Mode的切换，因为如果我们在主线程使用定时器，此时RunLoop的Mode为kCFRunLoopDefaultMode，即定时器属于kCFRunLoopDefaultMode，那么此时我们滑动ScrollView时，RunLoop的Mode会切换到UITrackingRunLoopMode，因此在主线程的定时器就不在管用了，调用的方法也就不再执行了，当我们停止滑动时，RunLoop的Mode切换回kCFRunLoopDefaultMode，所有NSTimer就又管用了。若想定时器继续执行，需要将NSTimer 注册为 kCFRunLoopCommonModes 。

### 9.2 延迟执行performSelecter相关方法是怎样被执行的？在子线程中也是一样的吗？

当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。
当调用 performSelector:onThread: 时，实际上其会创建一个 Timer 加到对应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效。


### 9.3 事件响应和手势识别底层处理是一致的吗，为什么？

事件响应：
苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，其回调函数为 __IOHIDEventSystemClientQueueCallback()。
当一个硬件事件(触摸/锁屏/摇晃等)发生后，首先由 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收。SpringBoard 只接收按键(锁屏/静音等)，触摸，加速，接近传感器等几种 Event，随后用 mach port 转发给需要的App进程。随后苹果注册的那个 Source1 就会触发回调，并调用 _UIApplicationHandleEventQueue() 进行应用内部的分发。
_UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的。

手势识别：
当上面的 _UIApplicationHandleEventQueue() 识别了一个手势时，其首先会调用 Cancel 将当前的 touchesBegin/Move/End 系列回调打断。随后系统将对应的 UIGestureRecognizer 标记为待处理。
苹果注册了一个 Observer 监测 BeforeWaiting (Loop即将进入休眠) 事件，这个Observer的回调函数是 _UIGestureRecognizerUpdateObserver()，其内部会获取所有刚被标记为待处理的 GestureRecognizer，并执行GestureRecognizer的回调。
当有 UIGestureRecognizer 的变化(创建/销毁/状态改变)时，这个回调都会进行相应处理。

### 9.4 界面刷新时，是在什么时候会真正执行刷新，为什么会刷新不及时？

当在操作 UI 时，比如改变了 Frame、更新了 UIView/CALayer 的层次时，或者手动调用了 UIView/CALayer 的 setNeedsLayout/setNeedsDisplay方法后，这个 UIView/CALayer 就被标记为待处理，并被提交到一个全局的容器去。

苹果注册了一个 Observer 监听 BeforeWaiting(即将进入休眠) 和 Exit (即将退出Loop) 事件，回调去执行一个很长的函数：_ZN2CA11Transaction17observer_callbackEP19__CFRunLoopObservermPv()。这个函数里会遍历所有待处理的 UIView/CAlayer 以执行实际的绘制和调整，并更新 UI 界面。所以说界面刷新并不一定是在setNeedsLayout相关的代码执行后立刻进行的。

### 9.5 项目程序运行中，总是伴随着多次自动释放池的创建和销毁，这些是在什么时候发生的呢？

系统就是通过@autoreleasepool {}这种方式来为我们创建自动释放池的，一个线程对应一个runloop，系统会为每一个runloop隐式的创建一个自动释放池，所有的autoreleasePool构成一个栈式结构，在每个runloop结束时，当前栈顶的autoreleasePool会被销毁，而且会对其中的每一个对象做一次release（严格来说，是你对这个对象做了几次autorelease就会做几次release，不一定是一次)，特别指出，使用容器的block版本的枚举器的时候，系统会自动添加一个autoreleasePool 

```objective-c
[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { 
// 这里被一个局部@autoreleasepool包围着 
}];
```

### 9.6 当我们在子线程上需要执行代理方法或者回调时，怎么确保当前线程没有被销毁？

首先引入一个概念：Event_loop，一般一个线程执行完任务后就会退出，当需要保证该线程不退出，可以通过类似以下方式：

```objective-c
function do_loop() {
    initialize();
    do {
        var message = get_next_message();
        process_message(message);
    } while (message != quit);
}
```
开启一个循环，保证线程不退出，这就是Event_loop模型。这是在很多操作系统中都使用的模型，例如OS/iOS中的RunLoop。这种模型最大的作用就是管理事件/消息，在有新消息到来时立刻唤醒处理，没有待处理消息时线程休眠，避免资源浪费。

## 10 Runloop 使用

### 10.1 AFNetworking
使用NSOperation+NSURLConnection并发模型都会面临NSURLConnection下载完成前线程退出导致NSOperation对象接收不到回调的问题。AFNetWorking解决这个问题的方法是按照官方的guid [NSURLConnection](https://developer.apple.com/documentation/foundation/nsurlconnection#//apple_ref/occ/instm/NSURLConnection/initWithRequest:delegate:startImmediately:) 上写的NSURLConnection的delegate方法需要在connection发起的线程runloop中调用，于是AFNetWorking直接借鉴了Apple自己的一个Demo的实现方法单独起一个global thread，内置一个runloop，所有的connection都由这个runloop发起，回调也是它接收，不占用主线程，也不耗CPU资源。

```objective-c
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
     @autoreleasepool {
          [[NSThread currentThread] setName:@"AFNetworking"];
          NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
          [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
          [runLoop run];
     }
}

+ (NSThread *)networkRequestThread {
     static NSThread *_networkRequestThread = nil;
     static dispatch_once_t oncePredicate;
     dispatch_once(&oncePredicate, ^{
          _networkRequestThread =
          [[NSThread alloc] initWithTarget:self
               selector:@selector(networkRequestThreadEntryPoint:)
               object:nil];
          [_networkRequestThread start];
     });

     return _networkRequestThread;
}
```
类似的可以用这个方法创建一个常驻服务的线程。

### 10.2 TableView中实现平滑滚动延迟加载图片

利用CFRunLoopMode的特性，可以将图片的加载放到NSDefaultRunLoopMode的mode里，这样在滚动UITrackingRunLoopMode这个mode时不会被加载而影响到。


```objective-c
UIImage *downloadedImage = ...;
[self.imageView performSelector:@selector(setImage:)
     withObject:downloadedImage
     afterDelay:0
     inModes:@[NSDefaultRunLoopMode]];
```

### 10.3 接到程序崩溃时的信号进行自主处理例如弹出提示等


```objective-c
CFRunLoopRef runLoop = CFRunLoopGetCurrent();
NSArray *allModes = CFBridgingRelease(CFRunLoopCopyAllModes(runLoop));
while (1) {
     for (NSString *mode in allModes) {
          CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
     }
}
```

### 10.4 异步测试


```objective-c
- (BOOL)runUntilBlock:(BOOL(^)())block timeout:(NSTimeInterval)timeout
{
     __block Boolean fulfilled = NO;
     void (^beforeWaiting) (CFRunLoopObserverRef observer, CFRunLoopActivity activity) =
     ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
          fulfilled = block();
          if (fulfilled) {
               CFRunLoopStop(CFRunLoopGetCurrent());
          }
     };

     CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, true, 0, beforeWaiting);
     CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);

     // Run!
     CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout, false);

     CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
     CFRelease(observer);

     return fulfilled;
}
```



