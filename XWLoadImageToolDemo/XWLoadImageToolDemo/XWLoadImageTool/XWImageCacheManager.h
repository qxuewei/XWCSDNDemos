//
//  XWImageCacheManager.h
//  TravelLive
//
//  Created by 邱学伟 on 2017/6/12.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XWImageCacheManager : NSObject
/**
 加载高性能圆角图片

 @param cornerRadius 圆角半径
 @param size 图片尺寸
 @param backgroundColor 填充颜色 默认clear
 @param imageName 本地加载 图片名
 @param url 网络下载链接
 @param completed 完成回调图片
 */
- (void)imageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)size backgroundColor:(UIColor *)backgroundColor imageName:(NSString *)imageName url:(NSString *)url completed:(void(^)(UIImage *image))completed;

/// 单例
+ (instancetype)shareInstance;
/// 加载图片
- (UIImage *)imageWithName:(NSString *)name;
@end
