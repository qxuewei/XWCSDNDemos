# iOS 手势操作和事件传递响应链
## 概述
iOS中的事件可以分为3大类型：触摸事件、加速计事件、远程控制事件。
在我们点击屏幕的时候，iphone OS获取到了用户进行了“单击”这一行为，操作系统把包含这些点击事件的信息包装成UITouch和UIEvent形式的实例，然后找到当前运行的程序，逐级寻找能够响应这个事件的对象，直到没有响应者响应。这一寻找的过程，被称作事件的响应链。

## Hit-Test 机制
当用户触摸(Touch)屏幕进行交互时，系统首先要找到响应者（Responder）。系统检测到手指触摸(Touch)操作时，将Touch 以UIEvent的方式加入UIApplication事件队列中。UIApplication从事件队列中取出最新的触摸事件进行分发传递到UIWindow进行处理。UIWindow 会通过hitTest:withEvent:方法寻找触碰点所在的视图，这个过程称之为hit-test view。
hitTest 的顺序如下
`UIApplication -> UIWindow -> Root View -> ··· -> subview`
在顶级视图（Root View）上调用pointInside:withEvent:方法判断触摸点是否在当前视图内；

如果返回NO，那么hitTest:withEvent:返回nil；

如果返回YES，那么它会向当前视图的所有子视图发送hitTest:withEvent:消息，所有子视图的遍历顺序是从最顶层视图一直到到最底层视图，即从subviews数组的末尾向前遍历，直到有子视图返回非空对象或者全部子视图遍历完毕。

如果有subview的hitTest:withEvent:返回非空对象则A返回此对象，处理结束（注意这个过程，子视图也是根据pointInside:withEvent:的返回值来确定是返回空还是当前子视图对象的。并且这个过程中如果子视图的hidden=YES、userInteractionEnabled=NO或者alpha小于0.1都会并忽略）；

如果所有subview遍历结束仍然没有返回非空对象，则hitTest:withEvent:返回self；

系统就是这样通过hit test找到触碰到的视图(Initial View)进行响应。

![1306128-ec979c527e4f9252](http://p95ytk0ix.bkt.clouddn.com/2018-06-05-1306128-ec979c527e4f9252.png)


## UIResponder
在iOS中不是任何对象都能处理事件，只有继承了UIResponder的对象才能接收并处理事件。我们称之为“响应者对象”，UIApplication、UIViewController、UIView都继承自UIResponder，因此它们都是响应者对象，都能够接收并处理事件。

继承了UIResponder就可以处理事件。UIResponder内部提供了以下方法来处理事件：

```objective-c
//触摸事件：
//一根或者多根手指开始触摸view，系统会自动调用view的下面方法：
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event

//一根或者多根手指在view上移动，系统会自动调用view的下面方法（随着手指的移动，会持续调用该方法）：
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event

//一根或者多根手指离开view，系统会自动调用view的下面方法：
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

//触摸结束前，某个系统事件(例如电话呼入)会打断触摸过程，系统会自动调用view的下面方法：
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
- 
//加速计事件：
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;

//远程控制事件：
-(void)remoteControlReceivedWithEvent:(UIEvent *)event;
```

## UITouch
使 UIView 跟随手指移动

```objective-c
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint current = [touch locationInView:moveV];
    CGPoint previous = [touch previousLocationInView:moveV];
    
    CGPoint point = moveV.center;
    point.x += current.x - previous.x;
    point.y += current.y - previous.y;
    NSLog(@"point:%@  current:%@",NSStringFromCGPoint(point),NSStringFromCGPoint(current));
    moveV.center = point;
}
```

当用户用一根手指触摸屏幕时，会创建一个与手指相关联的UITouch对象，一根手指对应一个UITouch对象。
UITouch保存着跟手指相关的信息，比如触摸的位置、时间、阶段：
（1）当手指移动时，系统会更新同一个UITouch对象，使之能够一直保存该手指在的触摸位置。
（2）当手指离开屏幕时，系统会销毁相应的UITouch对象。


```objective-c
//触摸产生时所处的窗口：
@property(nonatomic,readonly,retain) UIWindow    *window;

//触摸产生时所处的视图：
@property(nonatomic,readonly,retain) UIView    *view;

//短时间内点按屏幕的次数，可以根据tapCount判断单击、双击或更多的点击：
@property(nonatomic,readonly) NSUInteger    tapCount;

//记录了触摸事件产生或变化时的时间，单位是秒：
@property(nonatomic,readonly) NSTimeInterval    timestamp;

//当前触摸事件所处的状态：
@property(nonatomic,readonly) UITouchPhase    phase;

```
    
```objective-c
//返回值表示触摸在view上的位置，这里返回的位置是针对view的坐标系的（以view的左上角为原点(0, 0)）
//调用时传入的view参数为nil的话，返回的是触摸点在UIWindow的位置。
- (CGPoint)locationInView:(UIView *)view;  
 //该方法记录了前一个触摸点的位置
- (CGPoint)previousLocationInView:(UIView *)view; 
```

## UIEvent
每产生一个事件，就会产生一个UIEvent对象，称为事件对象，记录事件产生的时刻和类型。

常见属性：

```objective-c
//事件类型：
@property(nonatomic,readonly) UIEventType    type;
@property(nonatomic,readonly) UIEventSubtype    subtype;
//事件产生的时间：
@property(nonatomic,readonly) NSTimeInterval    timestamp;
```
一次完整的触摸过程会经历三个阶段：

```objective-c
//触摸开始：
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event

//触摸移动：
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event

//触摸结束：
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event

//触摸取消（可能会经历）：
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
```
4个触摸事件处理方法中，都有NSSet *touches和UIEvent *event两个参数：
#####（1）一次完整的触摸过程中，只会产生一个事件对象，4个触摸方法都是同一个event参数
#####（2）如果两根手指同时触摸一个view，那么view只会调用一次touchesBegan:withEvent:方法，touches参数中装着2个UITouch对象
#####（3）如果这两根手指一前一后分开触摸同一个view，那么view会分别调用2次touchesBegan:withEvent:方法，并且每次调用时的touches参数中只包含一个UITouch对象
#####（4）根据touches中UITouch的个数可以判断出是单点触摸还是多点触摸

## 事件的产生和传递
发生触摸事件后，系统会将该事件加入到一个由UIApplication管理的事件队列中，UIApplication会从事件队列中取出最前面的事件，并将事件分发下去以便处理。通常，先发送事件给应用程序的主窗口（keyWindow），主窗口会在视图层次结构中找到一个最合适的视图来处理触摸事件，也就是说keyWindow最先收到触摸事件。这也是整个事件处理过程的第一步，找到合适的视图控件后，就会调用视图控件的touches方法来作具体的事件处理：

touchesBegan…
touchesMoved…
touchedEnded…

这些touches方法的默认做法是将事件顺着响应者链条向上传递，将事件交给上一个响应者进行处理。
如果父控件不能接收触摸事件，那么子控件就不可能接收到触摸事件

UIView不接收触摸事件的三种情况：

#####（1）不接收用户交互

userInteractionEnabled = NO

#####（2）隐藏

hidden = YES

#####（3）透明

alpha = 0.0 ~ 0.01

UIImageView的userInteractionEnabled默认就是NO，因此UIImageView以及它的子控件默认是不能接收触摸事件的。


## 响应者链条

响应者链条示意图：
![iOS_responder_chain_2x](http://p95ytk0ix.bkt.clouddn.com/2018-06-05-iOS_responder_chain_2x.png)

响应者链的事件传递过程：

（1）如果view的控制器存在，就传递给控制器；如果控制器不存在，则将其传递给它的父视图。

（2）在视图层次结构的最顶级视图，如果也不能处理收到的事件或消息，则其将事件或消息传递给window对象进行处理。

（3）如果window对象也不处理，则其将事件或消息传递给UIApplication对象。

（4）如果UIApplication也不能处理该事件或消息，则将其丢弃。

触摸事件完整处理过程：

（1）先将事件对象由上往下传递（由父控件传递给子控件），找到最合适的控件来处理事件。

（2）调用最合适控件的touches…方法。

（3）如果这个控件调用了[super touches…];就会将事件顺着相应链条往下传递，传递给上一个响应者。

（4）接着就会调用上一个响应者的touches…方法。

（5）事件还可以继续往上传递，直到UIApplication，如果UIApplication也不处理该事件或消息，则将其丢弃。

上一个响应者：

如果当前这个View是控制器的View，那么控制器就是上一个响应者。

如果当前这个View不是控制器的View，那么父控件就是上一个响应者。

## UIGestureRecognizer

为了完成手势识别，必须借助于手势识别器——UIGestureRecognizer，利用UIGestureRecognizer，能轻松识别用户在某个view上面做的一些常见手势，UIGestureRecognizer是一个抽象类，定义了所有手势的基本行为，使用它的子类才能处理具体的手势：

```objective-c
//敲击
UITapGestureRecognizer

//捏合，可用于缩放
UIPinchGestureRecognizer

//拖拽
UIPanGestureRecognizer

//轻扫
UISwipeGestureRecognizer

//旋转
UIRotationGestureRecognizer

//长按
UILongPressGestureRecognizer
```

### 手势识别器的用法：

```objective-c
// 创建手势识别器对象
UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];

// 设置手势识别器对象的具体属性
// 连续敲击2次
tap.numberOfTapsRequired = 2;
// 需要2根手指一起敲击
tap.numberOfTouchesRequired = 2;

// 添加手势识别器到对应的view上
[self.iconView addGestureRecognizer:tap];

// 监听手势的触发
[tap addTarget:self action:@selector(tapIconView:)];
```


```objective-c
typedef NS_ENUM(NSInteger, UIGestureRecognizerState) {
    // 没有触摸事件发生，所有手势识别的默认状态
    UIGestureRecognizerStatePossible,
    // 一个手势已经开始但尚未改变或者完成时
    UIGestureRecognizerStateBegan,
    // 手势状态改变
    UIGestureRecognizerStateChanged,
    // 手势完成
    UIGestureRecognizerStateEnded,
    // 手势取消，恢复至Possible状态
    UIGestureRecognizerStateCancelled,
    // 手势失败，恢复至Possible状态
    UIGestureRecognizerStateFailed,
    // 识别到手势识别
    UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded
};
```
### 长按手势

```objective-c
- (void)addLongPressGes {
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [iconImageView addGestureRecognizer:longGes];
}
- (void)longPress:(UILongPressGestureRecognizer *)longP {
    if(longP.state == UIGestureRecognizerStateBegan){
        NSLog(@"开始长按");
    }else if(longP.state == UIGestureRecognizerStateChanged){
        NSLog(@"长按时手指移动");
    }else if(longP.state == UIGestureRecognizerStateEnded){
        NSLog(@"手指离开屏幕");
    }
}
```

### 清扫手势

```objective-c
- (void)addSwipGes {
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGes:)];
    // 清扫方向
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [iconImageView addGestureRecognizer:swip];
}
- (void)swipGes:(UISwipeGestureRecognizer *)swipe {
    // 判断的轻扫的方向
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"向左轻扫");
    }else if(swipe.direction == UISwipeGestureRecognizerDirectionUp){
        NSLog(@"向上轻扫");
    }
}
```

### 拖动手势

```objective-c
- (void)addPanGes {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [iconImageView addGestureRecognizer:pan];
}
- (void)pan:(UIPanGestureRecognizer *)pan {
    // 拖动手势也有状态
    if(pan.state == UIGestureRecognizerStateBegan){
        //  开始拖动
    }else if(pan.state == UIGestureRecognizerStateChanged){
        //   获取当前手指移动的距离，是相对于最原始的点
        CGPoint transP = [pan translationInView:iconImageView];
        
        //    清空上一次的形变
        iconImageView.transform = CGAffineTransformMakeTranslation(transP.x,transP.y);
        iconImageView.transform = CGAffineTransformTranslate(iconImageView.transform, transP.x, transP.y);
        
        //    复位,让它相对于上一次.
//        [pan setTranslation:CGPointZero inView:iconImageView];
    }else if(pan.state == UIGestureRecognizerStateEnded){
        //   结束拖动
    }
}
```

### 捏合手势

```objective-c
- (void)addPinchGes {
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pin:)];
    [iconImageView addGestureRecognizer:pin];
}
- (void)pin:(UIPinchGestureRecognizer *)pin {
    iconImageView.transform = CGAffineTransformScale(iconImageView.transform, pin.scale, pin.scale);
    // 复位
    [pin setScale:1.0];
}
```

### 旋转手势


```objective-c
- (void)addRotaGes {
    UIRotationGestureRecognizer *ro = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(retation:)];
    // 设置代理可以使其同时支持多个手势
    ro.delegate = self;
    [iconImageView addGestureRecognizer:ro];
}
- (void)retation:(UIRotationGestureRecognizer *)rotation {
    iconImageView.transform = CGAffineTransformRotate(iconImageView.transform, rotation.rotation);
    [rotation setRotation:0.0];
}
```

#### 演示代码  [XWTouchResponderDemo](https://github.com/qxuewei/XWCSDNDemos/tree/master/XWTouchResponderDemo)

参考：
* [https://www.jianshu.com/p/ef33cc31a614](https://www.jianshu.com/p/ef33cc31a614)

