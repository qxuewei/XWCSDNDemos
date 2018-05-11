//
//  XWArrayDictionaryDemoTests.m
//  XWArrayDictionaryDemoTests
//
//  Created by 邱学伟 on 2018/5/11.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XWArrayDictionaryDemoTests : XCTestCase

@end

@implementation XWArrayDictionaryDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testArray {
    
}

- (void)testDictEnum2 {
    NSDictionary *dict = @{@"邱学伟":@"3",@"极客学伟":@"1",@"一米八":@"2"};
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key : %@,  value : %@",key,obj);
    }];
}

- (void)testDictEnum {
    NSDictionary *dict = @{@"邱学伟":@"3",@"极客学伟":@"1",@"一米八":@"2"};
    [dict keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key : %@,  value : %@",key,obj);
        return YES;
    }];
}

- (void)testDictSort {
    NSDictionary *dict = @{@"邱学伟":@"3",@"极客学伟":@"1",@"一米八":@"2"};
    NSLog(@"%@",[dict keysSortedByValueUsingSelector:@selector(compare:)]);
}

- (void)testEnum4 {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];\
    [array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSLog(@"%@",evaluatedObject);
        return YES;
    }]];
    NSLog(@")))))))))))))))");
}


- (void)testEnum3 {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    NSEnumerator *enumerator = [array objectEnumerator];
    id obj;
    while (obj = [enumerator nextObject]) {
        NSLog(@"%@",obj);
    }
    NSLog(@")))))))))))))))");
}

- (void)testEnum2 {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    for (int i = 0 ; i < array.count; i++) {
        NSLog(@"%@",array[i]);
    }
}

- (void)testEnum1 {
     NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         NSLog(@"%@",obj);
    }];
}

- (void)testEnum {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    [array indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
        return YES;
    }];
}

/// 降序
- (void)testSort4 {
    NSArray *array = @[@1,@9,@6,@2,@7,@4];
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    NSLog(@"%@",result);
}

/// 降序
- (void)testSort3 {
    NSArray *array = @[@1,@9,@6,@2,@7,@4];
    NSArray *result = [[[array sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    NSLog(@"%@",result);
}

/// 升序
- (void)testNumberSort2 {
    NSArray *array = @[@1,@9,@6,@2,@7,@4];
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSLog(@"%@",result);
}

/// 升序
- (void)testNumberSort {
    NSArray *array = @[@1,@123,@98,@6,@77,@22];
    NSArray *result = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"%@",result);
}

- (void)testAraySort {
    NSArray *array1 = @[@1,@123,@98,@6,@77,@22];
    NSArray *result = [[array1 reverseObjectEnumerator] allObjects];
    NSLog(@"%@",result);
    
    NSArray *array2 = @[@"qiuxuewei",@"lovke",@"a",@"z",@"123"];
    [array2 sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
