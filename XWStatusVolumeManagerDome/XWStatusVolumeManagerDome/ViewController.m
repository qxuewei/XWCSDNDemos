//
//  ViewController.m
//  XWStatusVolumeManagerDome
//
//  Created by 邱学伟 on 2018/4/19.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "TLStatusVolumeManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TLStatusVolumeManager regiseter:nil];
    [TLStatusVolumeManager addCustomVolumeView];
}


@end
