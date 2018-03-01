//
//  main.m
//  XWTest0
//
//  Created by 邱学伟 on 2018/3/1.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWTest.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        XWTest *test = [[XWTest alloc] init];
//        [test foo];
        
        [test unrecognizedTest];
    }
    return 0;
}
