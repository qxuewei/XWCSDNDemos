# iOS 中常见的几种锁介绍-示例

#### 常用的各类锁性能比较

![常用的各类锁性能比较](http://p95ytk0ix.bkt.clouddn.com/2018-07-15-suo.png)

### 1. iOS中的互斥锁
> 在编程中，引入对象互斥锁的概念，来保证共享数据操作的完整性。每个对象都对应于一个可称为“互斥锁”的标记，这个标记用来保证在任一时刻，只能有一个线程访问对象。

#### 1.1 `@synchronized (self)`

```objective-c
- (void)lock1 {
    @synchronized (self) {
        // 加锁操作
    }
}
```
#### 1.2 `NSLock`

```objective-c
- (void)lock2 {
    NSLock *xwlock = [[NSLock alloc] init];
    XWLogBlock logBlock = ^ (NSArray *array) {
        [xwlock lock];
        for (id obj in array) {
            NSLog(@"%@",obj);
        }
        [xwlock unlock];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = @[@1,@2,@3];
        logBlock(array);
    });
}
```
#### 1.3 `pthread`
> pthread除了创建互斥锁，还可以创建递归锁、读写锁、once等锁

```objective-c

    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"+++++ 线程1 start");
        pthread_mutex_lock(&mutex);
        sleep(2);
        pthread_mutex_unlock(&mutex);
        NSLog(@"+++++ 线程1 end");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"----- 线程2 start");
        pthread_mutex_lock(&mutex);
        sleep(3);
        pthread_mutex_unlock(&mutex);
        NSLog(@"----- 线程2 end");
    });
}
```
### 2. iOS中的递归锁
> 同一个线程可以多次加锁，不会造成死锁


##### 死锁->
```objective-c
- (void)lock5 {
    NSLock *commonLock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^XWRecursiveBlock)(int);
        
        XWRecursiveBlock = ^(int  value) {
            [commonLock lock];
            if (value > 0) {
                NSLog(@"加锁层数: %d",value);
                sleep(1);
                XWRecursiveBlock(--value);
            }
            NSLog(@"程序退出!");
            [commonLock unlock];
        };
        
        XWRecursiveBlock(3);
    });
}
```
##### <-死锁

#### 2.1 `NSRecursiveLock`

```objective-c
- (void)lock4 {
    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^XWRecursiveBlock)(int);
        
        XWRecursiveBlock = ^(int  value) {
            [recursiveLock lock];
            if (value > 0) {
                NSLog(@"加锁层数: %d",value);
                sleep(1);
                XWRecursiveBlock(--value);
            }
            NSLog(@"程序退出!");
            [recursiveLock unlock];
        };
        
        XWRecursiveBlock(3);
    });
}
```

#### 2.2 `pthread`

```objective-c
- (void)lock6 {
    __block pthread_mutex_t recursiveMutex;
    pthread_mutexattr_t recursiveMutexattr;
    
    pthread_mutexattr_init(&recursiveMutexattr);
    pthread_mutexattr_settype(&recursiveMutexattr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&recursiveMutex, &recursiveMutexattr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^XWRecursiveBlock)(int);
        
        XWRecursiveBlock = ^(int  value) {
            pthread_mutex_lock(&recursiveMutex);
            if (value > 0) {
                NSLog(@"加锁层数: %d",value);
                sleep(1);
                XWRecursiveBlock(--value);
            }
            NSLog(@"程序退出!");
            pthread_mutex_unlock(&recursiveMutex);
        };
        
        XWRecursiveBlock(3);
    });
}
```

### 3. 信号量
> 信号量(Semaphore)，有时被称为信号灯，是在多线程环境下使用的一种设施，是可以用来保证两个或多个关键代码段不被并发调用。在进入一个关键代码段之前，线程必须获取一个信号量；一旦该关键代码段完成了，那么该线程必须释放信号量。其它想进入该关键代码段的线程必须等待直到第一个线程释放信号量

#### 3.1 `dispatch_semaphore_t`

##### 实现 GCD 下同步
```objective-c
- (void)lock7 {
//    dispatch_semaphore_create //创建一个信号量 semaphore
//    dispatch_semaphore_signal //发送一个信号 信号量+1
//    dispatch_semaphore_wait   // 等待信号 信号量-1
    
    /// 需求: 异步线程的两个操作同步执行
    
    dispatch_semaphore_t semaphone = dispatch_semaphore_create(0);
    NSLog(@"start");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"async .... ");
        sleep(5);
        /// 线程资源 + 1
        dispatch_semaphore_signal(semaphone);//信号量+1
    });
    /// 当前线程资源数量为 0 ,等待激活
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    NSLog(@"end");
}
```

#### 3.2 `pthread`

```objective-c
- (void)lock8 {
    __block pthread_mutex_t semaphore = PTHREAD_MUTEX_INITIALIZER;
    __block pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
    
    NSLog(@"start");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&semaphore);
        NSLog(@"async...");
        sleep(5);
        pthread_cond_signal(&cond);
        pthread_mutex_unlock(&semaphore);
    });
    
    pthread_cond_wait(&cond, &semaphore);
    NSLog(@"end");
}
```

### 4. 条件锁
#### 4.1 `NSCondition`
> `NSCondition` 的对象实际上是作为一个锁和线程检查器，锁主要是为了检测条件时保护数据源，执行条件引发的任务。线程检查器主要是根据条件决定是否继续运行线程，即线程是否被阻塞。

* NSCondition同样实现了NSLocking协议，所以它和NSLock一样，也有NSLocking协议的lock和unlock方法，可以当做NSLock来使用解决线程同步问题，用法完全一样。

```objective-c
- (NSMutableArray *)removeLastImage:(NSMutableArray *)images {
    if (images.count > 0) {
        NSCondition *condition = [[NSCondition alloc] init];
        [condition lock];
        [images removeLastObject];
        [condition unlock];
        NSLog(@"removeLastImage %@",images);
        return images;
    }else{
        return NULL;
    }
}
```

* 同时，NSCondition提供更高级的用法。wait和signal，和条件信号量类似。

* NSCondition和NSLock、@synchronized等是不同的是，NSCondition可以给每个线程分别加锁，加锁后不影响其他线程进入临界区。这是非常强大。


```objective-c
- (void)lock10 {
    self.conditionArray = [NSMutableArray array];
    self.xwCondition = [[NSCondition alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.xwCondition lock];
        if (self.conditionArray.count == 0) {
            NSLog(@"等待制作数组");
            [self.xwCondition wait];
        }
        id obj = self.conditionArray[0];
        NSLog(@"获取对象进行操作:%@",obj);
        [self.xwCondition unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.xwCondition lock];
        id obj = @"极客学伟";
        [self.conditionArray addObject:obj];
        NSLog(@"创建了一个对象:%@",obj);
        [self.xwCondition signal];
        [self.xwCondition unlock];
    });
}
```


#### 4.2 `NSConditionLock`


```objective-c
- (void)lock11 {
    NSConditionLock *conditionLock = [[NSConditionLock alloc] init];
    NSMutableArray *arrayM = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [conditionLock lock];
        
        for (int i = 0; i < 6; i++) {
            [arrayM addObject:@(i)];
            NSLog(@"异步下载第 %d 张图片",i);
            sleep(1);
            if (arrayM.count == 4) {
                [conditionLock unlockWithCondition:4];
            }
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [conditionLock lockWhenCondition:4];
        NSLog(@"已经获取到4张图片->主线程渲染");
        [conditionLock unlock];
    });
}
```

#### 4.2 `pthread` POSIX Conditions

```objective-c
- (void)lock12 {
    __block pthread_mutex_t mutex;
    __block pthread_cond_t condition;
    
    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&condition, NULL);
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&mutex);
        
        for (int i = 0; i < 6; i++) {
            [arrayM addObject:@(i)];
            NSLog(@"异步下载第 %d 张图片",i);
            sleep(1);
            if (arrayM.count == 4) {
                pthread_cond_signal(&condition);
            }
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        pthread_cond_wait(&condition, &mutex);
        NSLog(@"已经获取到4张图片->主线程渲染");
        pthread_mutex_unlock(&mutex);
    });
}
```

### 5. 读写锁
> 读写锁实际是一种特殊的自旋锁，它把对共享资源的访问者划分成读者和写者，读者只对共享资源进行读访问，写者则需要对共享资源进行写操作。这种锁相对于自旋锁而言，能提高并发性，因为在多处理器系统中，它允许同时有多个读者来访问共享资源，最大可能的读者数为实际的逻辑CPU数。写者是排他性的，一个读写锁同时只能有一个写者或多个读者（与CPU数相关），但不能同时既有读者又有写者。

#### 5.1 `dispatch_barrier_async / dispatch_barrier_sync`

有一个需求，如图：

![barrierdemo](http://p95ytk0ix.bkt.clouddn.com/2018-07-14-barrierdemo.png)

###### 任务1，2，3 均执行完毕执行任务0，然后执行任务4，5，6.
 
 
```objective-c
- (void)lock13 {
    dispatch_queue_t queue = dispatch_queue_create("com.qiuxuewei.brrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"任务1 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3 -- %@",[NSThread currentThread]);
    });
    dispatch_barrier_sync(queue, ^{
        NSLog(@"任务0 -- %@",[NSThread currentThread]);
        for (int i = 0; i < 100; i++) {
            if (i % 30 == 0) {
                NSLog(@"任务0 --- log:%d -- %@",i,[NSThread currentThread]);
            }
        }
    });
    NSLog(@"dispatch_barrier_sync  down!!!");
    dispatch_async(queue, ^{
        NSLog(@"任务4 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务5 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务6 -- %@",[NSThread currentThread]);
    });
}
```

##### `dispatch_barrier_async` 和 `dispatch_barrier_sync` 的异同
###### 共同点
* 等待它前面的执行完才执行自己的任务
* 等待自己任务执行结束才执行后面的任务

###### 不同点
* `dispatch_barrier_async` 将自己的任务插入到队列之后会继续将后面的操作插入到队列，按照规则先执行前面队列的任务，等自己队列执行完毕，再执行后面队列的任务
* `dispatch_barrier_sync`  将自己的任务插入到队列之后，先等待自己的任务执行完毕才会执行后面操作插入到队列，再执行后面队列的任务。

#### 5.2 `pthread`


```objective-c
- (void)lock14 {
    __block pthread_rwlock_t rwlock;
    pthread_rwlock_init(&rwlock, NULL);
    __block NSMutableArray *arrayM = [NSMutableArray array];
    
    XWBlock writeBlock = ^ (NSString *str) {
        NSLog(@"开启写操作");
        pthread_rwlock_wrlock(&rwlock);
        [arrayM addObject:str];
        sleep(2);
        pthread_rwlock_unlock(&rwlock);
    };
    
    XWVoidBlock readBlock = ^ {
        NSLog(@"开启读操作");
        pthread_rwlock_rdlock(&rwlock);
        sleep(1);
        NSLog(@"读取数据:%@",arrayM);
        pthread_rwlock_unlock(&rwlock);
    };
    
    for (int i = 0; i < 5; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            writeBlock([NSString stringWithFormat:@"%d",i]);
        });
    }
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            readBlock();
        });
    }
}
```

### 6.自旋锁

```objective-c
bool lock = false; // 一开始没有锁上，任何线程都可以申请锁  
do {  
    while(lock); // 如果 lock 为 true 就一直死循环，相当于申请锁
    lock = true; // 挂上锁，这样别的线程就无法获得锁
        Critical section  // 临界区
    lock = false; // 相当于释放锁，这样别的线程可以进入临界区
        Reminder section // 不需要锁保护的代码        
}

```

#### 6.1 OSSpinLock

>  [YYKit](https://github.com/ibireme/YYKit)作者的文章 [不再安全的 OSSpinLock](https://blog.ibireme.com/2016/01/16/spinlock_is_unsafe_in_ios/?utm_source=tuicool&utm_medium=referral)有说到这个自旋锁存在优先级反转的问题。

#### 6.2 os_unfair_lock

>自旋锁已经不再安全，然后苹果又整出来个 os_unfair_lock_t ,这个锁解决了优先级反转的问题。

```objective-c
    os_unfair_lock_t unfairLock;
    unfairLock = &(OS_UNFAIR_LOCK_INIT);
    os_unfair_lock_lock(unfairLock);
    os_unfair_lock_unlock(unfairLock);
```

### 7. property - atomic / nonatomic

> atomic 修饰的对象，系统会保证在其自动生成的 getter/setter 方法中的操作是完整的，不受其他线程的影响。例如 A 线程在执行 getter 方法时，B线程执行了 setter 方法，此时 A 线程依然会得到一个完整无损的对象。

###### atomic
> 默认修饰符
> 会保证CPU能在别的线程访问这个属性之前先执行完当前操作
> 读写速度慢
> 线程不安全 - 如果有另一个线程 D 同时在调[name release]，那可能就会crash，因为 release 不受 getter/setter 操作的限制。也就是说，这个属性只能说是读/写安全的，但并不是线程安全的，因为别的线程还能进行读写之外的其他操作。线程安全需要开发者自己来保证。

###### nonatomic
> 不默认
> 速度更快
> 线程不安全
> 如果两个线程同时访问会出现不可预料的结果。

### 8. Once 原子操作
#### 8.1 `GCD`

```objective-c

- (id)lock15 {
    static id shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareInstance) {
            shareInstance = [[NSObject alloc] init];
        }
    });
    return shareInstance;
}
```

#### 8.2 `pthread`

```objective-c
- (void)lock16 {
    pthread_once_t once = PTHREAD_ONCE_INIT;
    pthread_once(&once, lock16Func);
}
void lock16Func() {
     static id shareInstance;
    shareInstance = [[NSObject alloc] init];
}
```

