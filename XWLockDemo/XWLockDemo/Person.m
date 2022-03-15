//
//  Person.m
//  XWLockDemo
//
//  Created by qiuxuewei on 2020/12/22.
//  Copyright © 2020 qiuxuewei. All rights reserved.
//

#import "Person.h"

@interface Person ()
@property (nonatomic, strong) NSMutableArray *girlFriends;
@end

@implementation Person
- (instancetype)init {
    self = [super init];
    if (self) {
        self.girlFriends = [NSMutableArray array];
    }
    return self;
}
@end
