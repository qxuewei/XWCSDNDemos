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

## 1. OC 中几种常见集合对象接口方法的时间复杂度
#### `NSArray / NSMutableArray`
* `containsObject; indexOfObject; removeObject` 均会遍历元素查看是否匹配，复杂度等于或小于 O（n）
* `objectAtIndex；firstObject；lastObject; addObject; removeLastObject` 这些只针对栈顶，栈底的操作时间复杂度都是 O(1)
* `indexOfObject:inSortedRange:options:usingComparator:` 使用的是二分查找，时间复杂度是O(log n)

#### `NSSet / NSMutableSet / NSCountedSet`
集合类型是无序并且没有重复元素的。这样可以使用hash table 进行快速的操作。比如，`addObject; removeObject; containsObject` 都是按照 O(1) 来的。需要注意的是将数组转成Set 时，会将重复元素合并为一个，并且失去排序。

#### `NSDictionary / NSMutableDictionary`
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

## 2. 使用`GCD`进行性能优化
可以通过GCD提供的方法将一些耗时操作放到非主线程进行，使得App 能够运行的更加流畅，响应更快，但是使用GCD 时需要注意避免可能引起的线程爆炸和死锁的情况。在非主线程处理任务也不是万能的，如果一个处理需要消耗大量内存或者大量CPU操作，GCD也不合适，需要将大任务拆分成不同的阶段任务分时间进行处理。

#### 避免线程爆炸的方法：
* 使用串行队列
* 控制 `NSOperationQueue` 的并发数 - `NSOperationQueue.maxConcurrentOperationCount`

举个会造成线程爆炸和死锁的例子：

```objective-c
for (int i = 0, i < 999; i++) {
    dispatch_async(q,^{...});
}
dispatch_barrier_sync(q,^{...});
```
![deeply-ios-performance-optimization05](http://p95ytk0ix.bkt.clouddn.com/2018-07-03-deeply-ios-performance-optimization05.png)

如何避免上述的的线程爆炸和死锁呢？ 
首先使用 `dispatch_apply`

```objective-c
dispatch_apply(999,q,^(size_t i){...});
```

或者使用 `dispatch_semaphore`

```objective-c
#define CONCURRENT_TASKS 4

dispatch_queue_t q = dispatch_queue_create("com.qiuxuewei.gcd", nil);
    dispatch_semaphore_t sema = dispatch_semaphore_create(CONCURRENT_TASKS);
    for (int i = 0; i < 999; i++) {
        dispatch_async(q, ^{
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
```

## 3. I/O 性能优化
I/O 操作是性能消耗大户，任何的I/O操作都会使低功耗状态被打破。所以减少 I/O 操作次数是性能优化关键。如下是优化的一些方法:

* 将零碎的内容作为一个整体进行写入
* 使用合适的 I/O 操作 API
* 使用合适的线程
* 使用 NSCache 做缓存减少 I/O 次数

#### `NSCache`

![deeply-ios-performance-optimization06](http://p95ytk0ix.bkt.clouddn.com/2018-07-03-deeply-ios-performance-optimization06.png)

为何使用 `NSCache` 而不适应 `NSMutableDictionary` 呢？相交字典 `NSCache` 有以下优点：

* 自动清理系统所占内存（在接收到内存警告⚠️时）
* `NSCache` 是线程安全的
* `- (void)cache:(NSCache *)cache willEvictObject:(id)obj;` 缓存对象在即将被清理时回调。
* `evictsObjectWithDiscardedContent` 可以控制是否可被清理。

`SDWebImage` 在设置图片时就使用 `NSCache` 进行了性能优化：

```objective-c
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    return [self.memCache objectForKey:key];
}
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key {
    // 检查 NSCache 里是否有
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    // 从磁盘里读
    UIImage *diskImage = [self diskImageForKey:key];
    if (diskImage && self.shouldCacheImagesInMemory) {
        NSUInteger cost = SDCacheCostForImage(diskImage);
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    return diskImage;
}
``` 
 
 利用 `NSCache` 自动释放内存的特点将图片放到 `NSCache` 里，这样在内存警告时会自动清理掉不常用的图片，在读取 Cache 里内容时，如果没有被清理直接返回图片数据，清理了会执行 I/O 从磁盘中读取图片，通过这种方式减少磁盘操作，空间也会更加有效的控制释放。
 
## 4. 控制 App 的唤醒次数
通知，Voip, 定位，蓝牙 等都会使设备从 Standby 状态唤起。唤起这个过程会有比较大的消耗。应该避免频繁发生。
以 定位 API 举例：
##### 连续的位置更新
`[locationManager startUpdatingLocation]`
这个方法会使设备一直处于活跃状态。

##### 延时有效定位
`[locationManager allowDeferredLocationUpdatesUntilTraveled:<#(CLLocationDistance)#> timeout:<#(NSTimeInterval)#>]`
高效节能的定位方式，数据会缓存在位置硬件上。适合跑步应用。

##### 重大位置变化
`[locationManager startMonitoringSignificantLocationChanges]`
会更节能，对于那些只有在位置有很大变化的时候才需要回调的应用需要采用这种方式，比如天气应用。

##### 区域监测
`[locationManager startMonitoringForRegion:<#(nonnull CLRegion *)#>]`
也是一种节能的定位方式，比如在博物馆内按照不同区域监测展示不同信息之类的应用。

##### 频繁定位

```objective-c
// start monitoring location
[locationManager startUpdatingLocation]

// Stop monitoring when no longer needed
[locationManager stopUpdatingLocation]
```
不要轻易使用 startUpdatingLocation() 除非万不得已，尽快的使用 stopUpdatingLocation() 来结束定位还用户一个节能设备。

## 5. 预防性能问题
坚持几个编码原则：

* 优化计算的复杂度从而减少CPU的使用
* 在应用响应交互的时候停止没有必要的任务处理
* 设置合适的 Qos
* 将定时器任务合并，让CPU更多时候处于 idle 状态

## 6. 性能优化技巧篇

### 1. 复用机制
在 `UICollectionView` 和 `UITableView` 会使用到 代码复用的机制，在所展示的item数量超过屏幕所容纳的范围时，只创建少量的条目（通常是屏幕最大容纳量 + 1），通过复用来展示所有数据。这种机制不会为每一条数据都创建 Cell .增强效率和交互流畅性。
在iOS6以后，不仅可以复用cell，也可以复用每个section 的 header 和 footer。
在复用UITableView 会用到的 API:

```objective-c
// 复用 Cell：
- [UITableView dequeueReusableCellWithIdentifier:];
- [UITableView registerNib:forCellReuseIdentifier:];
- [UITableView registerClass:forCellReuseIdentifier:];
- [UITableView dequeueReusableCellWithIdentifier:forIndexPath:];

// 复用 Section 的 Header/Footer：
- [UITableView registerNib:forHeaderFooterViewReuseIdentifier:];
- [UITableView registerClass:forHeaderFooterViewReuseIdentifier:];
- [UITableView dequeueReusableHeaderFooterViewWithIdentifier:];
```
在使用代码复用需要注意在设置Cell 属性是，条件判断需要覆盖所有可能，避免因为复用导致数据错误的问题。例如在 `cellForRowAtIndexPath：` 方法内部：

```objective-c
if (indexPath %2 == 0) {
    cell.backgroundColor = [UIColor redColor];
}else{
    cell.backgroundColor = [UIColor clearColor];
}
```

### 2. 设置View为不透明
 `UIView` 又一个 `opaque` 属性， 在不需要透明效果的时候，应该尽量设置它为 YES, 可以提高绘图效率。
 在静态视图作用可能不明显，但在 `UITableVeiw` 或 `UICollectionView` 这种滚动 的 Scroll View 或是一个复杂动画中，透明效果对程序性能有较大的影响！
 
### 3. 避免使用臃肿的 Xib 文件
当加载一个 Xib 时，它所有的内容都会被加载，如歌这个 Xib 中有的View 你不会马上用到，加载就是浪费资源。而加载 StoryBoard 时，并不会把所有的ViewController 都加载，只会按需加载。

### 4. 不要阻塞主线程
`UIKit` 会把它所有的工作放在主线程执行，比如：绘制界面，管理手势，响应输入等。当把所有代码逻辑都放在主线程时，有可能因为耗时太长而卡住主线程造成程序无法响应，流畅性差等问题。所以一些 I/O 操作，网络数据解析都需要异步在非主线程处理。

### 5. 使用尺寸匹配的UIImage
当从 App bundle 中加载图片到 UIImageView 时，最好确保图片的尺寸和 UIImageView 相对应。否则会使UIImageView 对图片进行拉伸，这样会影响性能。如果图片时从网络加载，需要手动进行 scale。在UIImageView 中使用resize 后的图片

### 6. 选择合适的容器
在使用 `NSArray / NSDictionary / NSSet` 时，了解他们的特点便于在合适的时机选择他们。

* Array：数组。有序的，通过 index 查找很快，通过 value 查找很慢，插入和删除较慢。
* Dictionary：字典。存储键值对，通过键查找很快。
* Set：集合。无序的，通过 value 查找很快，插入和删除较快。

### 7. 启用 GZIP 数据压缩
在网络请求的数据量较大时，可以将数据进行压缩再进行传输。可以降低延迟，缩短网络交互时间。

### 8. 懒加载视图 / 视图隐藏
展现视图的两种形式一种是懒加载，当用到的时候去创建并展现给用户，另外一种提前分配内存创建出视图，不用的时候将其隐藏，等用到的时候将其透明度变为1，两种方案各有利弊。懒加载更合理的使用内存，视图隐藏让视图的展现更迅速。在选择时需要权衡两者利弊做出最优选择。

### 9. 缓存
开发需要秉承一个原则，对于一些更新频率低，访问频率高的内容进行缓存，例如：

* 服务器响应数据
* 图片
* 计算值 （UITableView 的 row height）

### 10. 处理 Memory Warning
处理 Memory Warning 的几种方式：

* 在 AppDelegate 中实现 `- [AppDelegate applicationDidReceiveMemoryWarning:]` 代理方法。
* 在 `UIViewController` 中重载 `didReceiveMemoryWarning` 方法。
* 监听 `UIApplicationDidReceiveMemoryWarningNotification` 通知。 

当通过这些方式监听到内存警告时，你需要马上释放掉不需要的内存从而避免程序被系统杀掉。

比如，在一个 UIViewController 中，你可以清除那些当前不显示的 View，同时可以清除这些 View 对应的内存中的数据，而有图片缓存机制的话也可以在这时候释放掉不显示在屏幕上的图片资源。

但是需要注意的是，你这时清除的数据，必须是可以在重新获取到的，否则可能因为必要数据为空，造成程序出错。在开发的时候，可以使用 iOS Simulator 的 Simulate memory warning 的功能来测试你处理内存警告的代码。

### 11. 复用高开销对象
高开销对象，顾名思义就是初始化很耗性能的对象。比如：`NSDateFormatter` , `NSCalendar` .为了避免频繁创建，我们可以使用一个全局单例强引用着这个对象，保证整个App 的生命周期只被初始化一次。

```objective-c
// no property is required anymore. The following code goes inside the implementation (.m)
- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd a HH:mm:ss EEEE"];
    });
    return dateFormatter;
}
```

设置 NSDateFormatter 的 date format 跟创建一个新的 NSDateFormatter 对象一样慢，因此当你的程序中要用到多种格式的 date format，而每种又会用到多次的时候，你可以尝试为每种 date format 创建一个可复用的 NSDateFormatter 对象来提供程序的性能。

### 12. 选择正确的网络返回数据格式
通常用到的有两种: JSON 和 XML。
JSON 优点：

* 能够更快的被解析
* 在承载相同数据时，体积比XML更小，传输的数据量更小。

缺点：

* 需要整个JSON数据全部加载完成后才能开始解析

而XML的优缺点恰好相反。解析数据不需要全部读取完才解析，可以变加载边解析，这样在处理大数据集时可以有效提高性能。 选择哪种格式取决于应用场景。

### 13. 合理设置背景图片
为一个View 设置背景图，我们想到的方案有两种

* 为视图加一个 UIImageView 设置 UIImage 作为背景
* 通过 `[UIColor colorWithPatternImage:<#(nonnull UIImage *)#>]` 将一张图转化为 UIColor, 直接为 View 设置 backgroundColor。

两种方案各有优缺点：若使用一个全尺寸图片作为背景图使用 UIImageView 会节省内存。
当你计划采用一个小块的模板样式图片，就像贴瓷砖那样来重复填充整个背景时，你应该用 `[UIColor colorWithPatternImage:<#(nonnull UIImage *)#>]` 这个方法，因为这时它能够绘制的更快，并且不会用到太多的内存。

### 14. 减少离屏渲染
离屏渲染：GPU在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作。
离屏渲染需要多次切换上下文环境：先是从当前屏幕（On-Screen）切换到离屏（Off-Screen）；等到离屏渲染结束以后，将离屏缓冲区的渲染结果显示到屏幕上又需要将上下文环境从离屏切换到当前屏幕，而上下文环境的切换是一项高开销的动作。

设置如下属性均会造成离屏渲染：

* shouldRasterize（光栅化）
* masks（遮罩）
* shadows（阴影）
* edge antialiasing（抗锯齿）
* group opacity（不透明）
* 复杂形状设置圆角等
* 渐变

例如给一个View设置阴影，通常我们会使用这种方式：

```objective-c
imageView.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
imageView.layer.shadowRadius = 5.0f;
imageView.layer.shadowOpacity = 0.6;
```
这种方式会触发离屏渲染，造成不必要的内存开销，我们完全可以使用如下方式代替：

```objective-c
imageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectMake(imageView.bounds.origin.x+5, imageView.bounds.origin.y+5, imageView.bounds.size.width, imageView.bounds.size.height)] CGPath];
imageView.layer.shadowOpacity = 0.6;
```
不会造成离屏渲染。

### 15. 光栅化
CALayer 有一个属性是 shouldRasterize 通过设置这个属性为 YES 可以将图层绘制到一个屏幕外的图像，然后这个图像将会被缓存起来并绘制到实际图层的 contents 和子图层，如果很很多的子图层或者有复杂的效果应用，这样做就会比重绘所有事务的所有帧来更加高效。但是光栅化原始图像需要时间，而且会消耗额外的内存。

```objective-c
cell.layer.shouldRasterize = YES;
cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
```
使用光栅化的一个前提是视图不会频繁变化，若一个频繁变化的视图，例如 排版多变，高度不同的 Cell, 光栅化的意义就不大了，反而造成必要的内存损耗。

### 16. 优化 `UITableView`

* 通过正确的设置 reuseIdentifier 来重用 Cell。
* 尽量减少不必要的透明 View。
* 尽量避免渐变效果、图片拉伸和离屏渲染。
* 当不同的行的高度不一样时，尽量缓存它们的高度值。
* 如果 Cell 展示的内容来自网络，确保用异步加载的方式来获取数据，并且缓存服务器的 response。
* 使用 shadowPath 来设置阴影效果。
* 尽量减少 subview 的数量，对于 subview 较多并且样式多变的 Cell，可以考虑用异步绘制或重写 drawRect。
* 尽量优化 - [UITableView tableView:cellForRowAtIndexPath:] 方法中的处理逻辑，如果确实要做一些处理，可以考虑做一次，缓存结果。
* 选择合适的数据结构来承载数据，不同的数据结构对不同操作的开销是存在差异的。
* 对于 rowHeight、sectionFooterHeight、sectionHeaderHeight 尽量使用常量。

### 17.选择合适数据存储方式
iOS 中数据存储方案有以下几种：

* NSUserDefaults。只适合用来存小数据。
* XML、JSON、Plist 等文件。JSON 和 XML 文件的差异在「选择正确的数据格式」已经说过了。
* 使用 NSCoding 来存档。NSCoding 同样是对文件进行读写，所以它也会面临必须加载整个文件才能继续的问题。
* 使用 SQLite 数据库。可以配合 FMDB 使用。数据的相对文件来说还是好处很多的，比如可以按需取数据、不用暴力查找等等。
* 使用 CoreData。 Apple 提供的对于SQLite 的封装，性能不如使用原生 SQLite, 不推荐使用。

### 18. 减少应用启动时间
在启动时的一些网络配置，数据库配置，数据解析的工作放在异步线程进行。

### 19. 使用 Autorelease Pool
当需要在代码中创建许多临时对象时，你会发现内存消耗激增直到这些对象被释放，一个问题是这些内存只会到 UIKit 销毁了它对应的 Autorelease Pool 后才会被释放，这就意味着这些内存不必要地会空占一些时间。这时候就是我们显式的使用 Autorelease Pool 的时候了，一个示例如下：

```objective-c
//一个很大数组
NSArray *urls = <# An array of file URLs #>; 
for (NSURL *url in urls) {
    @autoreleasepool {
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfURL:url
                                         encoding:NSUTF8StringEncoding error:&error];
        /* Process the string, creating and autoreleasing more objects. */
    }
}
```
添加 Autorelease Pool 会在每一次循环中释放掉临时对象，提高性能。

### 20. 合理选择 `imageNamed` 和 `imageWithContentsOfFile`
* `imageNamed` 会对图片进行缓存，适合多次使用某张图片
* `imageWithContentsOfFile` 从bundle中加载图片文件，不会进行缓存，适用于加载一张较大的并且只使用一次的图片，例如引导图等

今年的 WWDC 2018 Apple 向我们推荐了一种性能比较高的大图加载方案：

```swift
func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
	let sourceOpt = [kCGImageSourceShouldCache : false] as CFDictionary
	// 其他场景可以用createwithdata (data并未decode,所占内存没那么大),
	let source = CGImageSourceCreateWithURL(imageURL as CFURL, sourceOpt)!

	let maxDimension = max(pointSize.width, pointSize.height) * scale
	let downsampleOpt = [kCGImageSourceCreateThumbnailFromImageAlways : true,
kCGImageSourceShouldCacheImmediately : true ,
kCGImageSourceCreateThumbnailWithTransform : true,
kCGImageSourceThumbnailMaxPixelSize : maxDimension] as CFDictionary
	let downsampleImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOpt)!

	return UIImage(cgImage: downsampleImage)
}

作者：知识小集
链接：https://juejin.im/post/5b396fece51d4558a3055131
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

详细关于两者的分析可参照笔者的另外一篇博客：[iOS-UIImage imageWithContentsOfFile 和 imageName 对比](https://blog.csdn.net/qxuewei/article/details/50779851)

### 21. 合理进行线程分配
GCD 很轻易的可以开辟一个异步线程（不会100%开辟新线程），若不加以控制，会导致开辟的子线程越来越多浪费内存。并且在多线程情况下因为网络时序会造成数据处理错乱，所以可以：

* UI 操作和 DataSource 操作在主线程
* DB 操作，日志记录，网络回调在各自固定线程
* 不同业务，通过使用队列保持数据一致性。

### 22. 预处理和延时加载
预处理：初次展示需要消耗大量内存的数据需提前在后台线程处理完毕，需要时将处理好的数据进行展现
延时加载：提前加载下级界面的数据内容。举个栗子：类似抖音视频滑动，在播放当前视频的时候就提前将下个视频的数据加载好，等滑到下个视频时直接进行展示！

### 23. 在合适的时机使用 CALayer 替代 UIView
若视图无需和用户交互，类似绘制线条，单纯展示一张图片，可以将图片对象赋值给 layer 的 content 属性，以提高性能。
但是不能滥用，否则会造成代码难以维护的恶果。

以上。


