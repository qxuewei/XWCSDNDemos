# iOS CALayer 详解

## 1. 概述
在iOS中，你能看得见摸得着的东西基本上都是UIView，比如一个按钮、一个文本标签、一个文本输入框、一个图标等等，这些都是UIView，其实UIView之所以能显示在屏幕上，完全是因为它内部的一个图层，在创建UIView对象时，UIView内部会自动创建一个图层(即CALayer对象)，通过UIView的layer属性可以访问这个层：

```object
@property(nonatomic,readonly,strong)   CALayer  *layer;            
// returns view's layer. Will always return a non-nil value. view is layer's delegate
```    
当UIView需要显示到屏幕上时，会调用drawRect:方法进行绘图，并且会将所有内容绘制在自己的图层上，绘图完毕后，系统会将图层拷贝到屏幕上，于是就完成了UIView的显示, 在UIView中所有能够看到的内容都包含在layer中。

### CALayer 属性：
![UIView和CALayer关系](https://raw.githubusercontent.com/qxuewei/XWCSDNDemos/master/Images/calayer%E5%B1%9E%E6%80%A7s.png)

## 2.CALayer 演示
### 实现一个常规的 点击 放大缩小的 layer小动画 顺便熟悉layer常规属性：

```objective-c
/// 普通layer
- (void)setupLayer {
    CALayer *layer = [[CALayer alloc] init];
    _layer = layer;
    [self.view.layer addSublayer:layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.position = self.view.center;
    layer.anchorPoint = CGPointMake(0, 0);
    layer.bounds = CGRectMake(0, 0, cLayerWidth, cLayerWidth);
    layer.cornerRadius = cLayerWidth * 0.5;
    layer.shadowColor = [UIColor greenColor].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowOpacity = 0.6;
    layer.borderColor = [UIColor blackColor].CGColor;
    layer.borderWidth = 1.0;
    layer.contents = (id)[UIImage imageNamed:@"cat"].CGImage;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGFloat w = _layer.bounds.size.width;
    if (w == cLayerWidth) {
        w = cLayerWidth * 4.0;
    }else{
        w = cLayerWidth;
    }
    _layer.bounds = CGRectMake(0, 0, w, w);
    _layer.cornerRadius = w * 0.5;
    _layer.position = [touch locationInView:self.view];
}
```

### 圆角图片
* 方案1：


```objective-c
/// 圆角图层
- (void)setupImageLayer {
    CALayer *imageLayer = [CALayer layer];
    _imageLayer = imageLayer;
    [self.view.layer addSublayer:imageLayer];
    
    
    imageLayer.bounds = CGRectMake(0, 0, cImageLayerWidth, cImageLayerWidth);
    imageLayer.position = self.view.center;
    imageLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    /// 圆角方案1
    imageLayer.contents = (id)[UIImage imageNamed:@"cat"].CGImage;
    imageLayer.cornerRadius = cImageLayerWidth * 0.5;
    //注意仅仅设置圆角，对于图形而言可以正常显示，但是对于图层中绘制的图片无法正确显示
    //如果想要正确显示则必须设置masksToBounds=YES，剪切子图层
    imageLayer.masksToBounds = YES;
    //阴影效果无法和masksToBounds同时使用，因为masksToBounds的目的就是剪切外边框，
    //而阴影效果刚好在外边框
    //imageLayer.shadowColor = [UIColor blackColor].CGColor;

    /// 圆角方案2
//    [self drawRoundedLayer:imageLayer color:[UIColor whiteColor]];
    
    //边框
    imageLayer.borderWidth = 1.0;
    imageLayer.borderColor = [UIColor blackColor].CGColor;
}
```

* 方案2：


```objective-c
/// 圆角图层2
- (void)setupImageLayer2 {
    //边框
    CALayer *borderLayer = [CALayer layer];
    borderLayer.bounds = CGRectMake(0, 0, cImageLayerWidth, cImageLayerWidth);
    borderLayer.position = self.view.center;
    borderLayer.cornerRadius = cImageLayerWidth * 0.5;
    borderLayer.borderWidth = 1.0;
    borderLayer.borderColor = [UIColor blackColor].CGColor;
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.bounds = CGRectMake(0, 0, cImageLayerWidth, cImageLayerWidth);
    imageLayer.position = CGPointMake(cImageLayerWidth * 0.5, cImageLayerWidth * 0.5);
    imageLayer.anchorPoint = CGPointMake(0.5, 0.5);
    [self drawRoundedLayer:imageLayer color:[UIColor whiteColor]];
    
    [borderLayer addSublayer:imageLayer];
    [self.view.layer addSublayer:borderLayer];
}

/// 绘制高性能圆角
- (void)drawRoundedLayer:(CALayer *)layer color:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, YES, 0);
    [color setFill];
    UIRectFill(layer.bounds);
    [[UIBezierPath bezierPathWithRoundedRect:layer.bounds cornerRadius:cImageLayerWidth * 0.5] addClip];
    UIImage *image = [UIImage imageNamed:@"cat"];
    [image drawInRect:layer.bounds];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    layer.contents = (id)newImage.CGImage;
}
```


