//
//  ViewController.m
//  XWThreadDemo
//
//  Created by 邱学伟 on 2018/5/14.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"

@interface XWFindMinAndMaxThread : NSThread
@property (nonatomic, assign) NSUInteger min;
@property (nonatomic, assign) NSUInteger max;
- (instancetype)initWithNumbers:(NSArray <NSNumber *>*)numbers;
@end
@implementation XWFindMinAndMaxThread {
    NSArray <NSNumber *> *_numbers;
}
- (instancetype)initWithNumbers:(NSArray *)numbers {
    if (self = [super init]) {
        _numbers = numbers;
        [self work];
    }
    return self;
}
- (void)work {
    NSUInteger max = 0;
    NSUInteger min = NSUIntegerMax;
    for (NSNumber *number in _numbers) {
        max = MAX(max, number.unsignedIntegerValue);
        min = MIN(min, number.unsignedIntegerValue);
    }
    self.min = min;
    self.max = max;
    NSLog(@"线程:%@",[NSThread currentThread]);
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testGCDGroup];
    
    [self testGCDGroup2];
}

- (void)testGCDGroup2 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    __block NSMutableArray <UIImage *> *images = [NSMutableArray array];
    
    dispatch_group_async(group, queue, ^(){
        // 会处理一会
        [images addObject:[self imageWithUrl:@"https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/sleepForTimeInterval.png"]];
        NSLog(@"图片1线程 - %@",[NSThread currentThread]);
    });
    dispatch_group_async(group, queue, ^(){
        // 处理一会儿
        [images addObject:[self imageWithUrl:@"https://raw.githubusercontent.com/qxuewei/XWResources/master/images/threads.png"]];
        NSLog(@"图片2线程 - %@",[NSThread currentThread]);
    });
    
    // 上面的都搞定后这里会执行一次
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        NSLog(@"image数量:%lu - %@",(unsigned long)images.count,images);
    });
}

- (UIImage *)imageWithUrl:(NSString *)url {
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:imageData];
}

- (void)testGCDGroup {
    NSArray *urls = @[@"https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/sleepForTimeInterval.png",@"https://raw.githubusercontent.com/qxuewei/XWResources/master/images/threads.png",@"https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/sleepForTimeInterval.png"];
    [self downloadImage:urls completion:^(NSArray<UIImage *> *images) {
        NSLog(@"image数量:%lu - %@",(unsigned long)images.count,images);
    }];
}
- (void)downloadImage:(NSArray <NSString *>*)urls completion:(void(^)(NSArray <UIImage *> *images))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *imagesM = [NSMutableArray array];
        dispatch_group_t group = dispatch_group_create();
        for (NSString *url in urls) {
            if (url.length == 0) {
                continue;
            }
            
            // 开启下载线程->
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //dispatch_group_enter是通知dispatch group任务开始了，dispatch_group_enter和dispatch_group_leave是成对调用，不然程序就崩溃了。
                dispatch_group_enter(group);
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    [imagesM addObject:image];
                }
                NSLog(@"当前下载线程:%@",[NSThread currentThread]);
                // 保持和dispatch_group_enter配对。通知任务已经完成
                dispatch_group_leave(group);
            });
        }
        // 保持和dispatch_group_enter配对。通知任务已经完成
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        // 这里可以保证所有图片任务都完成，然后在main queue里加入完成后要处理的闭包，会在main queue里执行。
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(imagesM.copy);
            }
        });
    });
}

- (void)testMinMax {
    NSMutableArray *numberArrayM = [NSMutableArray array];
    NSUInteger count = 100000;
    /// 模拟10000个随机数
    for (NSUInteger i = 0; i < count; i++) {
        [numberArrayM addObject:[NSNumber numberWithUnsignedInteger:arc4random()]];
    }
    
    NSMutableArray <XWFindMinAndMaxThread *> *threads = [NSMutableArray array];
    NSUInteger threadCount = 4;
    NSUInteger numberCount = numberArrayM.count;
    
    for (NSUInteger i = 0; i < threadCount; i++) {
        NSUInteger offset = (numberCount / threadCount) * i;
        NSUInteger count = MIN(numberCount - offset, numberCount / threadCount);
        NSLog(@"offset : %lu ++ count : %lu",(unsigned long)offset,(unsigned long)count);
        NSRange range = NSMakeRange(offset, count);
        NSArray *subSet = [numberArrayM subarrayWithRange:range];
        XWFindMinAndMaxThread *findThread = [[XWFindMinAndMaxThread alloc] initWithNumbers:subSet];
        [threads addObject:findThread];
        [findThread start];
    }
    
    NSUInteger max = 0;
    NSUInteger min = NSUIntegerMax;
    for (NSUInteger i = 0; i < threadCount; i++) {
        max = MAX(max, threads[i].max);
        min = MIN(min, threads[i].min);
    }
    
    NSLog(@"最小值: %lu",(unsigned long)min);
    NSLog(@"最大值: %lu",(unsigned long)max);
}

@end


