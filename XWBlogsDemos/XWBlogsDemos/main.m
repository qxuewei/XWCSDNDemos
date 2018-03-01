//
//  main.m
//  XWBlogsDemos
//
//  Created by 邱学伟 on 2018/2/28.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "XWTest.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        XWTest *test = [[XWTest alloc] init];
        [test unrecognized];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
