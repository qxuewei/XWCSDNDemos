//
//  XWPerson.m
//  BlockDemo
//
//  Created by 邱学伟 on 2018/6/28.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "XWPerson.h"

@implementation XWPerson

- (void)test {
    
//    self.personBlock = ^{
//        NSLog(@"%d",self.age);
//    };
}

- (void)dealloc {
    NSLog(@" XWPerson -- dealloc  --  age:%ld",(long)_age);
}
@end
