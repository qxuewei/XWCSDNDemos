//
//  main.m
//  BlockDemo
//
//  Created by 邱学伟 on 2018/6/28.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWPerson.h"

typedef void(^MyBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block XWPerson *person1 = [[XWPerson alloc] init];
        person1.age = 18;
        person1.personBlock = ^{
            NSLog(@"%ld",(long)person1.age);
            person1 = nil;
        };
        person1.personBlock();
    }
    return 0;
}

//void testObject() {
//    MyBlock myBlock;
//    {
//        XWPerson *person = [[XWPerson alloc] init];
//        person.age = 10;
//        myBlock = ^{
//            NSLog(@"person -- %ld",(long)person.age);
//        };
//        myBlock();
//
//    }
//
//    NSLog(@"*******");
//}



//MyBlock testFunc() {
//    int a = 10;
//    MyBlock myBlock = ^ {
//        NSLog(@"test --- %d",a);
//    };
//    return myBlock;
//}
//void testBlockCopy() {
//    int abc = 10;
//    MyBlock myB = ^ {
//        NSLog(@"+++ %d",abc);
//    };
//    NSLog(@"%@",[myB class]);
//
//    NSArray *array = @[@1];
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//    }];
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//    });
//}
//
//void testBlockType() {
//    void(^block1)(void) = ^() {
//        NSLog(@"abc");
//    };
//    NSLog(@"%@",[block1 class]);
//
//    int abc = 1;
//    void(^block2)(void) = ^() {
//        NSLog(@"abc: %d",abc);
//    };
//    NSLog(@"%@",[block2 class]);
//
//
//    NSLog( @"%@", [^(){
//        NSLog(@"hello %d",abc);
//    } class]);
//}
//
//
//void testClass() {
//    void(^block)(void) = ^() {
//        NSLog(@"abc");
//    };
//
//    NSLog(@"%@",[block class]);
//    NSLog(@"%@",[[block class] superclass]);
//    NSLog(@"%@",[[[block class] superclass] superclass]);
//    NSLog(@"%@",[[[[block class] superclass] superclass] superclass]);
//}
