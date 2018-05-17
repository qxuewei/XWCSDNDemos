//
//  TestImageCell.m
//  XWCornerImageViewDemo
//
//  Created by 邱学伟 on 2018/5/17.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "TestImageCell.h"

@interface TestImageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageV1;
@property (weak, nonatomic) IBOutlet UIImageView *imageV2;
@property (weak, nonatomic) IBOutlet UIImageView *imageV3;
@property (weak, nonatomic) IBOutlet UIImageView *imageV4;

@end

@implementation TestImageCell

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    for (UIView *subV in self.contentView.subviews) {
        if ([subV isKindOfClass:[UIImageView class]]) {
            UIImageView *imagev = (UIImageView *)subV;
            imagev.image = [UIImage imageNamed:imageName];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
