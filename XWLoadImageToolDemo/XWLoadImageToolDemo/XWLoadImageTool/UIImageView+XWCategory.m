//
//  UIImageView+XWCategory.m
//  XWLoadImageToolDemo
//
//  Created by 邱学伟 on 2018/5/16.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "UIImageView+XWCategory.h"
#import "XWImageCacheManager.h"
#import <UIImageView+WebCache.h>

@implementation UIImageView (XWCategory)
/// 设置圆角图片
- (void)tl_setImageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)size backgroundColor:(UIColor *)backgroundColor imageName:(NSString *)imageName url:(NSString *)url placeholderImageName:(NSString *)placeholderImageName {
    UIImage *placeholderImage = [[XWImageCacheManager shareInstance] imageWithName:placeholderImageName];;
    [self setImage:placeholderImage];
    [[XWImageCacheManager shareInstance] imageWithCornerRadius:cornerRadius size:size backgroundColor:backgroundColor imageName:imageName url:url completed:^(UIImage *image) {
        if (image) {
            [self setImage:image];
        }
    }];
}

/// 设置网络图片
- (void)tl_setImageWithUrl:(NSString *)url placeholderImageName:(NSString *)placeholderImageName {
    UIImage *placeholderImage = [[XWImageCacheManager shareInstance] imageWithName:placeholderImageName];
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholderImage];
}
@end
