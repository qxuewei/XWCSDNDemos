//
//  TLStatusVolumeManager.h
//  BeijingLive
//
//  Created by 邱学伟 on 2018/4/19.
//  Copyright © 2018年 兰雄传媒. All rights reserved.
//  全局音量视图

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 进度视图可自定义
@protocol TLVolumeView <NSObject>
@optional
- (void)setCurrentVolume:(float)volume;
- (void)updateVolume:(float)volume;
- (float)viewHeight;
@end

@interface TLStatusVolumeManager : NSObject
/**
 自定义进度视图
 */
@property (class, nonatomic, readonly, strong, nullable) UIView <TLVolumeView> *volumeView;
/**
 进度条颜色
 */
@property (class, nonatomic, strong, nonnull) UIColor *indicatorTintColor;
/**
 背景色
 */
@property (class, nonatomic, strong, nonnull) UIColor *barBackgroundColor;
/**
 出现时间 默认1s
 */
@property (class, nonatomic, assign) NSTimeInterval displayTimeInterval;

+ (void)regiseter: (UIView<TLVolumeView> *_Nullable)volumeView;
+ (void)addCustomVolumeView;
+ (void)removeVolumeView;
@end
