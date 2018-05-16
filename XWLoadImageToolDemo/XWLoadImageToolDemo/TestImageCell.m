//
//  TestImageCell.m
//  XWLoadImageToolDemo
//
//  Created by 邱学伟 on 2018/5/16.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "TestImageCell.h"
#import "UIImageView+XWCategory.h"

@interface TestImageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@end

@implementation TestImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setUrl:(NSString *)url {
    _url = url;
    [self.imageV tl_setImageWithCornerRadius:25.0 size:_imageV.bounds.size backgroundColor:[UIColor greenColor] imageName:nil url:url placeholderImageName:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
