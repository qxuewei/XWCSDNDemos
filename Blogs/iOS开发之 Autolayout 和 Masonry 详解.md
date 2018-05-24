# iOS开发之 Autolayout 详解

![2018-05-24-1_HemKn1OC2bh7tUpK7_p0Ng](http://p95ytk0ix.bkt.clouddn.com/2018-05-24-2018-05-24-1_HemKn1OC2bh7tUpK7_p0Ng.png)

## 1. 概述
1. Autolayout 是 Apple 自 iOS6 开始引入的旨在解决不同屏幕之间布局适配的技术
2. 苹果官方推荐开发者使用 Autolayout 进行UI界面的布局
3. Autolayout 有两个核心概念：1. 参照。 2. 约束
4. 使用Autolayout的注意点：
    1. 添加约束之前需要保证控件已被添加到父控件中
    2. 不需要再给View设置frame
    3. 禁止 autoresizing 功能。

## 2. 代码实现 Autolayout

#### 2.1 步骤：
1. 把 View 添加到父控件上。
2. 添加约束到相应的 View 上。
    
    ```objective-c
    - (void)addConstraint:(NSLayoutConstraint *)constraint;
    - (void)addConstraints:(NSArray<__kindof NSLayoutConstraint *> *)constraints;
    ```
3. 自动布局核心公式：
    `obj1.property1 =（obj2.property2 * multiplier）+ constant value`

##### NSLayoutConstraint
```objective-c
/**
view1 ：要约束的控件
attr1 ：约束的类型（做怎样的约束）
relation ：与参照控件之间的关系
view2 ：参照的控件
attr2 ：约束的类型（做怎样的约束）
multiplier ：乘数
c ：常量
*/
+ (instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
```
#### 2.2 实例
##### 添加一个左间距100 上间距200，宽150 高64 的红视图:

```objective-c
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
}
```
##### 在上视图基础上添加一个与红视图右间距相同，高度相同，顶部距离红色视图间距20，宽度为红色视图一半的蓝色View

```obejctive-c
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
```
最终效果：
![屏幕快照 2018-05-24 下午2.18.54](http://p95ytk0ix.bkt.clouddn.com/2018-05-24-屏幕快照 2018-05-24 下午2.18.54.png)

#### 2.3 添加约束的规则
在创建约束之后，需要将其添加到作用的view上。
在添加时要注意目标view需要遵循以下规则：

#####（1）对于两个同层级view之间的约束关系，添加到它们的父view上
#####（2）对于两个不同层级view之间的约束关系，添加到他们最近的共同父view上
#####（3）对于有层次关系的两个view之间的约束关系，添加到层次较高的父view上


## 3. VFL
VFL全称是Visual Format Language，翻译过来是“可视化格式语言”，是苹果公司为了简化Autolayout的编码而推出的抽象语言。


```object0ve-c
    /*
     format ：VFL语句
     opts ：约束类型
     metrics ：VFL语句中用到的具体数值
     views ：VFL语句中用到的控件
     */
+ (NSArray<__kindof NSLayoutConstraint *> *)constraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *,id> *)views;
```

`@{@"redV" : redV}` 等价于 `NSDictionaryOfVariableBindings(redV)`


```obejctive-c
NSDictionary *views =

NSDictionaryOfVariableBindings(blueView, redView);

NSArray *conts2 =

[NSLayoutConstraint constraintsWithVisualFormat:

@"V:[blueView(==blueHeight)]-margin-|" options:0 metrics:

@{@"blueHeight" : @40, @"margin" : @20} views:views];
```

### 约束格式说明：

水平方向  　　　　　　  H:
垂直方向  　　　　　　  V:
Views　　　　　　　　 [view]
SuperView　　　　　　|
关系　　　　　　　　　>=,==,<=
空间,间隙　　　　　　　-
优先级　　　　　　　　@value

### 3.1 VFL 部分语法：

#### H:|-100-[redV(200)]-|
水平方向距离左边距100，宽度200

#### V:|-200-[redV(64)]-|
垂直方向距离顶部200，高度64

#### H:[redV(72)]-12-[blueV(50)]
水平方向redV 宽度72，blueV 宽度50，他们之间间距12

#### H:[redV(>=60@700)]
水平方向redV宽度大于等于60，优先级为700 （优先级最大1000）

#### V:[redBox]-[yellowBox(==redBox)]
竖直方向上，先有一个redBox，其下方紧接一个高度等于redBox高度的yellowBox

#### H:|-10-[Find]-[FindNext]-[FindField(>=20)]-|
水平方向上，Find距离父view左边缘默认间隔宽度，之后是FindNext距离Find间隔默认宽度；再之后是宽度不小于20的FindField，它和FindNext以及父view右边缘的间距都是默认宽度。（竖线“|” 表示superview的边缘）

### 3.2 VFL的语法
* 标准间隔：[button]-[textField]
* 宽约束：[button(>=50)]
* 与父视图的关系：|-50-[purpleBox]-50-|
* 垂直布局：V:[topField]-10-[bottomField]
* Flush Views：[maroonView][buleView]
* 权重：[button(100@20)]
* 等宽：[button(==button2)]
* Multiple Predicates：[flexibleButton(>=70,<=100)]

#### 注意事项
创建这种字符串时需要注意一下几点：
* H:和V:每次都使用一个。
* 视图变量名出现在方括号中，例如[view]。
* 字符串中顺序是按照从顶到底，从左到右
* 视图间隔以数字常量出现，例如-10-。
* |表示父视图

### 3.3 使用Auto Layout时需要注意的点
* 注意禁用Autoresizing Masks。对于每个需要使用Auto Layout的视图需要调用setTranslatesAutoresizingMaskIntoConstraints:NO
* VFL语句里不能包含空格和>，<这样的约束
* 布局原理是由外向里布局，最先屏幕尺寸，再一层一层往里决定各个元素大小。
* 删除视图时直接使用removeConstraint和removeConstraints时需要注意这样删除是没法删除视图不支持的约束导致view中还包含着那个约束（使用第三方库时需要特别注意下）。解决这个的办法就是添加约束时用一个局部变量保存下，删除时进行比较删掉和先前那个，还有个办法就是设置标记，constraint.identifier = @“What you want to call”。

### 3.4 布局约束规则
表达布局约束的规则可以使用一些简单的数学术语，如下表

| 类型 | 描述 | 值 |
| :------------ |:---------------| :-----|
| 属性 | 视图位置 | NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeTop, NSLayoutAttributeBottom |
| 属性 | 视图前面后面 | NSLayoutAttributeLeading, NSLayoutAttributeTrailing |
| 属性 | 视图的宽度和高度 | NSLayoutAttributeWidth, NSLayoutAttributeHeight |
| 属性 | 视图中心 | NSLayoutAttributeCenterX, NSLayoutAttributeCenterY |
| 属性 | 视图的基线，在视图底部上方放置文字的地方 | NSLayoutAttributeBaseline |
| 属性 | 占位符，在与另一个约束的关系中没有用到某个属性时可以使用占位符 | NSLayoutAttributeNotAnAttribute |
| 关系 | 允许将属性通过等式和不等式相互关联 | NSLayoutRelationLessThanOrEqual, NSLayoutRelationEqual, NSLayoutRelationGreaterThanOrEqual |
| 数学运算 | 每个约束的乘数和相加性常数 | CGFloat值 |

### 3.5 View的改变会调用哪些方法

* 改变frame.origin不会掉用layoutSubviews
* 改变frame.size会使 superVIew的layoutSubviews调用和自己view的layoutSubviews方法
* 改变bounds.origin和bounds.size都会调用superView和自己view的layoutSubviews方法

### 3.6 VFL 实例：

```obejctive-c
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
```
运行结果：
![屏幕快照 2018-05-24 下午3.46.26](http://p95ytk0ix.bkt.clouddn.com/2018-05-24-屏幕快照 2018-05-24 下午3.46.26.png)

