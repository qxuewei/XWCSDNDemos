//
//  main.m
//  XWTest0
//
//  Created by 邱学伟 on 2018/3/1.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "XWTest.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *str = [NSString stringWithFormat:@"123"];
        XWTest *test = [XWTest new];
        test.copyStrxxxx = str;
        NSLog(@"str:%p --- copyStrxxxx:%p",str,test.copyStrxxxx);
    }
    return 0;
}

//- (void)test{
//    @autoreleasepool {
//        NSObject *obj = [[NSObject alloc] init];
//        NSLog(@"%zd",malloc_size((__bridge const void *)obj));
//    }
//    NSLog(@"%zd",class_getInstanceSize([obj class]));
//    return 0;
//}
