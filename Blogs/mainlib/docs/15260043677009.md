# iOS基础集合类

## NSArray

### 排序

```objective-c
- (NSEnumerator<ObjectType> *)objectEnumerator;
- (NSEnumerator<ObjectType> *)reverseObjectEnumerator;
- (NSArray<ObjectType> *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType, ObjectType, void * _Nullable))comparator context:(nullable void *)context;
- (NSArray<ObjectType> *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType, ObjectType, void * _Nullable))comparator context:(nullable void *)context hint:(nullable NSData *)hint;
- (NSArray<ObjectType> *)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray<ObjectType> *)subarrayWithRange:(NSRange)range;
```

#### 1. 逆序

```objective-c
/// 将原有的数组逆序输出
[[array reverseObjectEnumerator] allObjects];
```


```objective-c
 - (void)testArraySort {
     NSArray *array1 = @[@1,@123,@98,@6,@77,@22];
     NSArray *result = [[array1 reverseObjectEnumerator] allObjects];
     NSLog(@"%@",result);
}
```
 输出：
 
```objective-c
2018-05-11 10:32:21.820441+0800 XWArrayDictionaryDemo[2148:94679] (
    22,
    77,
    6,
    98,
    123,
    1
)
```

#### 2. 升序 、降序

##### 升序
```objective-c
/// 升序
- (void)testNumberSort {
    NSArray *array = @[@1,@123,@98,@6,@77,@22];
    NSArray *result = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"%@",result);
}
```
输出：

```objective-c
2018-05-11 13:52:31.889127+0800 XWArrayDictionaryDemo[5877:230244] (
    1,
    6,
    22,
    77,
    98,
    123
)
```

```objective-c
/// 升序
- (void)testNumberSort2 {
    NSArray *array = @[@1,@9,@6,@2,@7,@4];
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSLog(@"%@",result);
}
```
输出：

```objective-c
2018-05-11 13:58:59.779001+0800 XWArrayDictionaryDemo[6065:252727] (
    1,
    2,
    4,
    6,
    7,
    9
)
```


#####  降序

```objective-c
/// 降序
- (void)testSort3 {
    NSArray *array = @[@1,@9,@6,@2,@7,@4];
    NSArray *result = [[[array sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    NSLog(@"%@",result);
}
```
输出：

```objective-c
2018-05-11 14:01:36.237543+0800 XWArrayDictionaryDemo[6140:260610] (
    9,
    7,
    6,
    4,
    2,
    1
)
```

```objective-c
/// 降序
- (void)testSort4 {
    NSArray *array = @[@1,@9,@6,@2,@7,@4];
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    NSLog(@"%@",result);
}
```
输出：

```objective-c
2018-05-11 14:02:41.385379+0800 XWArrayDictionaryDemo[6182:265228] (
    9,
    7,
    6,
    4,
    2,
    1
)
```

### 枚举

#### 使用 `indexesOfObjectsWithOptions:passingTest:`

```objective-c
- (void)testEnum {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    [array indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
        return YES;
    }];
}
```

#### For 循环

```objective-c
- (void)testEnum1 {
     NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    for (NSString *str in array) {
        NSLog(@"%@",str);
    }
}
```

#### Block 方式枚举

```objective-c
- (void)testEnum1 {
     NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         NSLog(@"%@",obj);
    }];
}
```

#### 通过下标 index

```objective-c
- (void)testEnum2 {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    for (int i = 0 ; i < array.count; i++) {
        NSLog(@"%@",array[i]);
    }
}
```

#### 使用 NSEnumerator
```objective-c
- (void)testEnum3 {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];
    NSEnumerator *enumerator = [array objectEnumerator];
    id obj;
    while (obj = [enumerator nextObject]) {
        NSLog(@"%@",obj);
    }
}
```

#### 使用 predicate
```objective-c
- (void)testEnum4 {
    NSArray *array = @[@"邱学伟",@"极客学伟",@"一米八",@"CSDN",@"iOS开发"];\
    [array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSLog(@"%@",evaluatedObject);
        return YES;
    }]];
}
```

| 枚举方法 / 时间 [ms] | 10.000.000 elements | 10.000 elements |
| :------------ |---------------:| -----:|
| indexesOfObjects:, concurrent | 1844.73 | 2.25 |
| NSFastEnumeration (for in) | 3223.45 | 3.21 |
| indexesOfObjects: | 4221.23 | 3.36 |
| enumerateObjectsUsingBlock: | 5459.43 | 5.43 |
| objectAtIndex: | 5282.67 | 5.53 |
| NSEnumerator | 5566.92 | 5.75 |
| filteredArrayUsingPredicate: | 6466.95 | 6.31 |


## NSDictionary
同样数目的值，NSDictionary比NSArray要花费多得多的内存空间

### 排序

通过 value 的顺序将 key 按指定顺序输出

```objective-c
- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator;
- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr;
- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts
     usingComparator:(NSComparator)cmptr;
```

### 枚举

#### `keysOfEntriesWithOptions:passingTest：` 可并行

```objective-c
- (void)testDictEnum {
    NSDictionary *dict = @{@"邱学伟":@"3",@"极客学伟":@"1",@"一米八":@"2"};
    [dict keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key : %@,  value : %@",key,obj);
        return YES;
    }];
}
```

#### `block` 枚举

```object
- (void)testDictEnum2 {
    NSDictionary *dict = @{@"邱学伟":@"3",@"极客学伟":@"1",@"一米八":@"2"};
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key : %@,  value : %@",key,obj);
    }];
}
```

* 各个方法枚举时间参考

| 枚举方法 / 时间 [ms] | 50.000 elements | 1.000.000 elements |
| :------------ |---------------:| -----:|
| keysOfEntriesWithOptions:, concurrent | 16.65 | 425.24 |
| getObjects:andKeys: | 30.33 | 798.49 |
| keysOfEntriesWithOptions: | 30.59 | 856.93 |
| enumerateKeysAndObjectsUsingBlock: | 36.33 | 882.93 |
| NSFastEnumeration | 41.20 | 1043.42 |
| NSEnumeration | 42.21 | 1113.08 |

