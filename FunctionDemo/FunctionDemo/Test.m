//
//  Test.m
//  FunctionDemo
//
//  Created by 邱学伟 on 2018/7/2.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "Test.h"

@implementation Test

///GUNSTEP NSArray indexOfObject: 方法的实现
- (BOOL)containsObject:(id)anObject {
    return [self indexOfObject:anObject] != NSNotFound;
}

- (NSUInteger) indexOfObject: (id)anObject
{
    unsigned  c = [self count];
    
    if (c > 0 && anObject != nil)
    {
        unsigned  i;
        IMP   get = [self methodForSelector: oaiSel];
        BOOL  (*eq)(id, SEL, id)
        = (BOOL (*)(id, SEL, id))[anObject methodForSelector: eqSel];
        
        for (i = 0; i < c; i++)
            if ((*eq)(anObject, eqSel, (*get)(self, oaiSel, i)) == YES)
                return i;
    }
    return NSNotFound;
}
@end
