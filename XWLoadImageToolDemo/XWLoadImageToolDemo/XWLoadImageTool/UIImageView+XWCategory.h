//
//  UIImageView+XWCategory.h
//  XWLoadImageToolDemo
//
//  Created by 邱学伟 on 2018/5/16.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (XWCategory)

/**
 设置网络图片 (SDWebImage)

 @param url 图片路径
 @param placeholderImageName 占位图片名称
 */
- (void)tl_setImageWithUrl:(NSString *)url placeholderImageName:(NSString *)placeholderImageName;

/**
 设置高性能圆角图片
 
 @param cornerRadius 圆角半径
 @param size 图片尺寸
 @param backgroundColor 填充颜色 默认clear
 @param imageName 本地加载 图片名
 @param url 网络下载链接
 @param placeholderImageName 占位图
 */
- (void)tl_setImageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)size backgroundColor:(UIColor *)backgroundColor imageName:(NSString *)imageName url:(NSString *)url placeholderImageName:(NSString *)placeholderImageName;

@end
