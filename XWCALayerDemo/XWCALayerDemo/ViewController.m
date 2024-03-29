//
//  ViewController.m
//  XWCALayerDemo
//
//  Created by 邱学伟 on 2018/5/16.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CALayerDelegate> {
    CALayer *_layer;
    CALayer *_imageLayer;
    __weak IBOutlet UIImageView *imageV;
}

@end

@implementation ViewController
static const CGFloat cLayerWidth = 60.0;
static const CGFloat cImageLayerWidth = 160.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    imageV.image = [UIImage imageNamed:@"cat"];
//    [self setupLayer];
//    [self setupImageLayer1];
//    [self setupImageLayer2];
    [self setupTextLayer];
}

- (void)setupTextLayer {
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.bounds = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    textLayer.position = self.view.center;
    [self.view.layer addSublayer:textLayer];
    
    /// 很重要的属性设置-避免文本模糊显示
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    /// 文本属性
    textLayer.string = @"这是一个文本Layer !! 吊不吊 !!";
    
    // 字体
    UIFont *font = [UIFont systemFontOfSize:15.0];
    CFStringRef fontStringRef = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontStringRef);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    /// 文本属性
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
}

/// 圆角图层
- (void)setupImageLayer1 {
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
//    layer.contents = (id)[UIImage imageNamed:@"cat"].CGImage;
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

@end
