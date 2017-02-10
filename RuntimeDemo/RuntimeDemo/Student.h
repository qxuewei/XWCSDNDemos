//
//  Student.h
//  RuntimeDemo
//
//  Created by 邱学伟 on 2017/2/10.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Student : NSObject
{
    NSString *school;
    int age;
}

@property (nonatomic, assign) NSUInteger stuNum;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat height;

+(void)study:(NSString *)classRoom;
+(BOOL)isGoodStudent;

-(void)run:(double)mileage;
-(double)totalRunMileage;
@end
