//
//  People.h
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface People : NSObject {
    int uid;
    NSNumber *weight;
    double height;
}
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, assign) NSUInteger sex;
@property (nonatomic, copy) NSString *address;
@end
