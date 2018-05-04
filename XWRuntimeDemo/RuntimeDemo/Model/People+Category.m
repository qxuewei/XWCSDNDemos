//
//  People+Category.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/5/3.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "People+Category.h"
#import <objc/runtime.h>
@implementation People (Category)

#pragma mark - 新增属性
static const char * cPeopleBlogKey = "cPeopleBlogKey";
- (NSString *)blog {
    return objc_getAssociatedObject(self, cPeopleBlogKey);
}
- (void)setBlog:(NSString *)blog {
    objc_setAssociatedObject(self, cPeopleBlogKey, blog, OBJC_ASSOCIATION_COPY);
}
@end
