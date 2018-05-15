//
//  main.m
//  XWThreadDemo
//
//  Created by 邱学伟 on 2018/5/14.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <pthread.h>

struct threadInfo {
    uint32_t * inputValues;
    size_t count;
};

struct threadResult {
    uint32_t min;
    uint32_t max;
};

void * findMinAndMax(void *arg) {
    struct threadInfo const * const info = (struct threadInfo *) arg;
    uint32_t min = UINT32_MAX;
    uint32_t max = 0;
    for (size_t i = 0; i < info -> count; i++) {
        uint32_t value = info -> inputValues[i];
        min = MIN(min, value);
        max = MAX(max, value);
    }
    free(arg);
    struct threadResult * const result = (struct threadResult *) malloc(sizeof( * result));
    result -> min = min;
    result -> max = max;
    return result;
}

int main(int argc, char * argv[]) {
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    
        size_t const count = 100000;
        uint32_t inputValues[count];
        // 填充随机数字
        for (size_t i = 0; i < count; i++) {
            inputValues[i] = arc4random();
        }
        
        // 开启4个寻找最大最小值的线程
        size_t threadCount = 4;
        pthread_t threads[threadCount];
        for (size_t i = 0; i < threadCount; i++) {
            struct threadInfo * const info = (struct threadInfo *)malloc(sizeof(*info));
            size_t offset = (count / threadCount) * i;
            info -> inputValues = inputValues + offset;
            info -> count = MIN(count - offset, count / threadCount);
            int error = pthread_create(threads + i, NULL, &findMinAndMax, info);
            NSCAssert(error == 0, @"pthread_create() failed: %d", error);
        }
        
        // 等待线程退出
        struct threadResult * results[threadCount];
        for (size_t i = 0; i < threadCount; i++) {
            int error = pthread_join(threads[i], (void **) &(results[i]));
            NSCAssert(error == 0, @"pthread_join() failed: %d", error);
        }
        
        // 寻找min 和 max
        uint32_t min = UINT32_MAX;
        uint32_t max = 0;
        for (size_t i = 0; i < threadCount; i++) {
            min = MIN(min, results[i] -> min);
            max = MAX(max, results[i] -> max);
            free(results[i]);
            results[i] = NULL;
        }
        NSLog(@"最小值: %u",min);
        NSLog(@"最大值: %u",max);
    return 0;
}
