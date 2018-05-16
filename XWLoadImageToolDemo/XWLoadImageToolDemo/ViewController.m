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
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self loadImages];
}

- (void)loadImages {
    for (int i = 28; i <= 80; i++) {
        NSString *imageUrl = [@"https://raw.githubusercontent.com/zhaohang/photo/master/%E9%B8%9F%E5%B7%A22010%E4%BA%94%E4%B8%80/nokia5320_0" stringByAppendingString:[NSString stringWithFormat:@"%d.jpg",i]];
        [self.images addObject:imageUrl];
    }
    [self.tableview reloadData];
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TestImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestImageCell class])];
    if (!cell) {
        [tableView registerNib: [UINib nibWithNibName:@"TestImageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TestImageCell class])];
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestImageCell class])];
    }
    NSString *url = self.images[indexPath.row];
    cell.url = url;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (NSMutableArray *)images {
    if(!_images){
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}
@end
