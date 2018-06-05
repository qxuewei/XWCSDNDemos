//
//  ViewController.m
//  XWTouchResponderDemo
//
//  Created by 邱学伟 on 2018/6/5.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"

@interface RedView : UIView
@end

@implementation RedView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%@   touchesBegan",self.class);
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    NSLog(@"%@  hitTest",self.class);
    return view;
}
@end

@interface BlueView : UIView
@end

@implementation BlueView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%@   touchesBegan",self.class);
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    NSLog(@"%@  hitTest",self.class);
    return view;
}
@end

@interface TestBtn : UIButton
@end

@implementation TestBtn
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"%@   touchesBegan",self.class);
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    NSLog(@"%@  hitTest",self.class);
    return view;
}
@end


@interface ViewController () <UIGestureRecognizerDelegate> {
    TestBtn *testBtn;
    RedView *redV;
    BlueView *blueV;
    UIView *moveV;
    
    __weak IBOutlet UIImageView *iconImageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    testBtn = [TestBtn buttonWithType:UIButtonTypeContactAdd];
//    [testBtn addTarget:self action:@selector(testBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    redV = [[RedView alloc] initWithFrame:CGRectMake(0, 64, 200, 200)];
//    blueV = [[BlueView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    [self.view addSubview:redV];
//    [redV addSubview:blueV];
//    [blueV addSubview:testBtn];
//    testBtn.center = blueV.center;
//
//    moveV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
//    moveV.backgroundColor = [UIColor blackColor];
//    moveV.center = self.view.center;
//    [self.view addSubview:moveV];
//
    iconImageView.userInteractionEnabled = YES;
//    [self addLongPressGes];
//    [self addSwipGes];
//    [self addPanGes];
//    [self addPinchGes];
    [self addRotaGes];
}

- (void)testBtnClick:(UIButton *)sender {
    NSLog(@"testBtnClick");
    NSLog(@"***********************");
    UIResponder *res = sender;
    while (res) {
        NSLog(@"++++++++++++\n %@",res);
        res = res.nextResponder;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
//    UITouch *touch = [touches anyObject];
//    CGPoint current = [touch locationInView:moveV];
//    CGPoint previous = [touch previousLocationInView:moveV];
//
//    CGPoint point = moveV.center;
//    point.x += current.x - previous.x;
//    point.y += current.y - previous.y;
//    NSLog(@"point:%@  current:%@",NSStringFromCGPoint(point),NSStringFromCGPoint(current));
//    moveV.center = point;
}


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

- (void)addSwipGes {
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGes:)];
    // 清扫方向,必须设置
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

- (void)addPinchGes {
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pin:)];
    [iconImageView addGestureRecognizer:pin];
}
- (void)pin:(UIPinchGestureRecognizer *)pin {
    iconImageView.transform = CGAffineTransformScale(iconImageView.transform, pin.scale, pin.scale);
    // 复位
    [pin setScale:1.0];
}

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
@end
