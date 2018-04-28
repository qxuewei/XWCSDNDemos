//
//  RuntimeDemoTests.m
//  RuntimeDemoTests
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "People.h"
#import <objc/runtime.h>

@interface RuntimeDemoTests : XCTestCase

@end

@implementation RuntimeDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//成员变量
- (void)testIvar {
    BOOL isSuccessAddIvar = class_addIvar([NSString class], "_phone", sizeof(id), log2(sizeof(id)), "@");
    if (isSuccessAddIvar) {
        NSLog(@"Add Ivar success");
    }else{
        NSLog(@"Add Ivar error");
    }
    unsigned int outCount;
    Ivar *ivarList = class_copyIvarList([People class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivarList[i];
        const char *ivarName = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        NSLog(@"ivar:%s, offset:%zd, type:%s", ivarName, offset, type);
    }
}

@end
