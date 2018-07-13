# iOS 中常见的几种锁介绍-示例

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
    /// 信号资源池数量 1
    dispatch_semaphore_t semaphone = dispatch_semaphore_create(1);
    NSLog(@"start");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"async .... ");
        sleep(2);
        dispatch_semaphore_signal(semaphone);//信号量+1
    });
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

