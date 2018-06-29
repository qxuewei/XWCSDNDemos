//
//  XWPerson.h
//  BlockDemo
//
//  Created by 邱学伟 on 2018/6/28.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWPerson : NSObject

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, copy)  void(^personBlock)(void);

@end
