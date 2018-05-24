//
//  ViewController.m
//  XWAutolayoutDemo
//
//  Created by 邱学伟 on 2018/5/24.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"

@interface YellowView : UIView

@end
@implementation YellowView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"%s",__func__);
}
@end

@interface GrayView : UIView

@end
@implementation GrayView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"%s",__func__);
}
@end

@interface ViewController () {
    YellowView *_yellowV;
    GrayView *_grayV;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testAutolayout1];
//    [self testVFL];
    [self testLayout];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _grayV.bounds = CGRectMake(10, 0, 200, 40);
}

- (void)testLayout {
    YellowView *yellowV = [[YellowView alloc] initWithFrame:CGRectMake(100, 100, 200, 80)];
    _yellowV = yellowV;
    [self.view addSubview:yellowV];
    GrayView *grayV = [[GrayView alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
    _grayV = grayV;
    [yellowV addSubview:grayV];
}

- (void)testVFL {
    UIView *redV = [[UIView alloc] init];
    redV.backgroundColor = [UIColor redColor];
    redV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redV];
    
    UIView *blueV = [[UIView alloc] init];
    blueV.backgroundColor = [UIColor blueColor];
    blueV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blueV];
    /*
     format ：VFL语句
     opts ：约束类型
     metrics ：VFL语句中用到的具体数值
     views ：VFL语句中用到的控件
     */
    //水平方向 redV 左右间距为20
    NSArray *cons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[redV]-20-|" options:0 metrics:nil views:@{@"redV":redV}];
    [self.view addConstraints:cons1];
    
    //垂直方法redV距离顶部 100, redV 高度为64, blueV顶部距离redV 100 像素, blueV的高度等于redV
    NSArray *cons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[redV(64)]-margin-[blueV(==redV)]" options:NSLayoutFormatAlignAllRight metrics:@{@"margin" : @100} views:NSDictionaryOfVariableBindings(redV,blueV)];
    [self.view addConstraints:cons2];
    
    NSLayoutConstraint *cons = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0];
    [self.view addConstraint:cons];
}

- (void)testAutolayout1 {
    UIView *redV = [[UIView alloc] init];
    redV.backgroundColor = [UIColor redColor];
    redV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:redV];
    /**
     view1 ：要约束的控件
     attr1 ：约束的类型（做怎样的约束）
     relation ：与参照控件之间的关系
     view2 ：参照的控件
     attr2 ：约束的类型（做怎样的约束）
     multiplier ：乘数
     c ：常量
     */
    /// 左间距100:
    NSLayoutConstraint *consLeft = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:100];
    [self.view addConstraint:consLeft];
    
    /// 上间距200:
    NSLayoutConstraint *consTop = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:200];
    [self.view addConstraint:consTop];
    
    /// 宽150:
    NSLayoutConstraint *consWidth = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:150];
    [redV addConstraint:consWidth];
    
    /// 高64:
    NSLayoutConstraint *consHeight = [NSLayoutConstraint constraintWithItem:redV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:64];
    [redV addConstraint:consHeight];
    
    
    UIView *blueV = [[UIView alloc] init];
    blueV.backgroundColor = [UIColor blueColor];
    blueV.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blueV];
    
    /// 和 redV 右间距为0
    NSLayoutConstraint *b_consRight = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    [self.view addConstraint:b_consRight];
    
    /// 和 redV 等高
    NSLayoutConstraint *b_consHeight = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:b_consHeight];
    
    /// 宽度是 redV 的一半
    NSLayoutConstraint *b_consWidth = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0];
    [self.view addConstraint:b_consWidth];
    
    /// 顶部距离 redV 20
    NSLayoutConstraint *b_consTop = [NSLayoutConstraint constraintWithItem:blueV attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:redV attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0];
    [self.view addConstraint:b_consTop];
}

@end
