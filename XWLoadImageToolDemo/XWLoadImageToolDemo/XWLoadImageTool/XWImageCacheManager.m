//
//  XWImageCacheManager.m
//  TravelLive
//
//  Created by 邱学伟 on 2017/6/12.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "XWImageCacheManager.h"
#import "SDWebImageDownloader.h"

@interface XWImageCacheManager ()
/// 普通图片缓存cache
@property (nonatomic, strong) NSCache *imageCache;
/// 圆角图片缓存cache
@property (nonatomic, strong) NSCache *conerImageCache;
@end
@implementation XWImageCacheManager
/// 单例对象
static XWImageCacheManager *_defaultManager;

#pragma mark - public
- (void)imageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)size backgroundColor:(UIColor *)backgroundColor imageName:(NSString *)imageName url:(NSString *)url completed:(void(^)(UIImage *image))completed {
    if (imageName.length > 0) {
        // 本地图片名为key缓存
        UIImage *image = [self.conerImageCache objectForKey:imageName];
        if (image) {
            // 已缓存过此圆角图
            completed ? completed(image) : nil;
            return;
        }
        image = [self imageWithName:imageName];
        if (!image) {
            completed ? completed(NULL) : nil;
            return;
        }
        [self radiusImageWithCornerRadius:cornerRadius size:size backgroundColor:backgroundColor image:image imageCompleted:completed];
        [self.conerImageCache setObject:image forKey:imageName];
    }else if (url.length > 0){
        //图片链接为key缓存
        UIImage *cacheImage = [self.conerImageCache objectForKey:url];
        if (cacheImage) {
            // 已缓存过此圆角图
            completed ? completed(cacheImage) : nil;
            return;
        }
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderLowPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (!image) {
                completed ? completed(NULL) : nil;
                return;
            }
            [self radiusImageWithCornerRadius:cornerRadius size:size backgroundColor:backgroundColor image:image imageCompleted:completed];
            [self.conerImageCache setObject:image forKey:url];
        }];
    }else{
         completed ? completed(NULL) : nil;
    }
}

/// 异步绘制圆角图片
- (void)radiusImageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)size backgroundColor:(UIColor *)backgroundColor image:(UIImage *)image imageCompleted:(void(^)(UIImage *image))imageCompleted {
    if (cornerRadius == 0.0) {
        imageCompleted ? imageCompleted(image) : nil;
        return;
    }
    if (!backgroundColor) {
        backgroundColor = [UIColor clearColor];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        // 填充颜色
        [backgroundColor setFill];
        UIRectFill(rect);
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        CGContextAddPath(ctx,path.CGPath);
        CGContextClip(ctx);
        [image drawInRect:rect];
        CGContextDrawPath(ctx, kCGPathFillStroke);
        UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            imageCompleted ? imageCompleted(newImage) : nil;
        });
    });
}

/// 加载普通图片
- (UIImage *)imageWithName:(NSString *)name{
    UIImage *image = [self.imageCache objectForKey:name];
    if (!image) {
        image = [UIImage imageNamed:name];
        if (image) {
            [self.imageCache setObject:image forKey:name];
        }
    }
    return image;
}

#pragma mark - 单例对象
+ (instancetype)shareInstance {
    if (!_defaultManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _defaultManager = [[self alloc] init];
        });
    }
    return _defaultManager;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_defaultManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _defaultManager = [super allocWithZone:zone];
        });
    }
    return _defaultManager;
}
- (id)copyWithZone:(NSZone *)zone{
    return _defaultManager;
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return _defaultManager;
}

#pragma mark - getter
- (NSCache *)conerImageCache {
    if(!_conerImageCache){
        _conerImageCache = [[NSCache alloc] init];
    }
    return _conerImageCache;
}
- (NSCache *)imageCache {
    if(!_imageCache){
        _imageCache = [[NSCache alloc] init];
    }
    return _imageCache;
}

@end
