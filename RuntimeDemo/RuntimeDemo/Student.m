//
//  Student.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2017/2/10.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "Student.h"
#import "Student_XW.h"
@implementation Student
+(void)study:(NSString *)classRoom{
    NSLog(@"study in %@",classRoom);
}
+(BOOL)isGoodStudent{
    return YES;
}

-(void)run:(double)mileage{
    NSLog(@"run %f kilometre",mileage);
}
-(double)totalRunMileage{
    return 123;
}

+(void)eat{
    NSLog(@"EAT");
}

@end
