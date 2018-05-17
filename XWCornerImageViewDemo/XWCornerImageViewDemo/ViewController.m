//
//  ViewController.m
//  XWLoadImageToolDemo
//
//  Created by 邱学伟 on 2018/5/16.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "TestImageCell.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.rowHeight = 98.0;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TestImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestImageCell class])];
    if (!cell) {
        [tableView registerNib: [UINib nibWithNibName:@"TestImageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TestImageCell class])];
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestImageCell class])];
    }
    cell.imageName = @"mac_dog";
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (NSMutableArray *)images {
    if(!_images){
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}
@end
