# iOS-性能优化深入探究
![deeply-ios-performance-optimization02](http://p95ytk0ix.bkt.clouddn.com/2018-07-02-deeply-ios-performance-optimization02.png)

上图是几种时间复杂度的关系，性能优化一定程度上是为了降低程序执行效率减低时间复杂度。
如下是几种时间复杂度的实例：
##### O(1)

```objective-c
return array[index] == value;
```

##### O(n)

```objective-c
for (int i = 0, i < n, i++) {
    if (array[i] == value) 
        return YES;
}
```

##### O(n2)

```objective-c
/// 找数组中重复的值
for (int i = 0, i < n, i++) {
    for (int j = 0, j < n, j++) {
        if (i != j && array[i] == array[j]) {
            return YES;
        }
    }
}
```

### OC 中几种常见集合对象接口方法的时间复杂度
#### NSArray / NSMutableArray
* `containsObject; indexOfObject; removeObject` 均会遍历元素查看是否匹配，复杂度等于或小于 O（n）
* `objectAtIndex；firstObject；lastObject; addObject; removeLastObject` 这些只针对栈顶，栈底的操作时间复杂度都是 O(1)
* `indexOfObject:inSortedRange:options:usingComparator:` 使用的是二分查找，时间复杂度是O(log n)

#### NSSet / NSMutableSet / NSCountedSet
集合类型是无序并且没有重复元素的。这样可以使用hash table 进行快速的操作。比如，`addObject; removeObject; containsObject` 都是按照 O(1) 来的。需要注意的是将数组转成Set 时，会将重复元素合并为一个，并且失去排序。

#### NSDictionary / NSMutableDictionary
和 Set 一样都可以使用 hash table ，多了键值对应。添加和删除元素都是 O(1)。

#### `containsObject` 方法在数组和Set里的不同的实现
##### `containsObject` 在数组中的实现

```objective-c
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
```
##### `containsObject` 在 Set 里的实现： 

```objective-c
- (BOOL) containsObject: (id)anObject
{
  return (([self member: anObject]) ? YES : NO);
}
//在 GSSet,m 里有对 member 的实现
- (id) member: (id)anObject
{
  if (anObject != nil)
    {
      GSIMapNode node = GSIMapNodeForKey(&map, (GSIMapKey)anObject);
      if (node != 0)
    {
      return node->key.obj;
    }
    }
  return nil;
}
```
##### 在数组中会遍历所有元素查找到结果后返回，在Set中查找元素是通过键值的方式从map映射表中取出，因为S儿童里的元素是唯一的，所以可以hash元素对象作为key达到快速查找的目的。




