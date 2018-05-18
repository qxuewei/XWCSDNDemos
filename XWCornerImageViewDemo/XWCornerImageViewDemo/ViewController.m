//
//  ViewController.m
//  XWLoadImageToolDemo
//
//  Created by 邱学伟 on 2018/5/16.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "TestImageCell.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource> {
    CADisplayLink *displayLink;
    NSUInteger scheduleTimes;//执行次数
    CFTimeInterval timestamp;//时间戳
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.rowHeight = 98.0;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self setupDisplayLink];
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TestImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestImageCell class])];
    if (!cell) {
        [tableView registerNib: [UINib nibWithNibName:@"TestImageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TestImageCell class])];
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestImageCell class])];
    }
    NSUInteger index = 20 + arc4random_uniform(21);
    cell.imageName = [NSString stringWithFormat:@"IMG_00%zd",index];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}

#pragma mark - 刷新频率
- (void)setupDisplayLink {
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayMethod:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)displayMethod:(CADisplayLink *)link {
    scheduleTimes ++;
    if (timestamp == 0) {
        timestamp = link.timestamp;
    }
    CFTimeInterval timestampPassed = link.timestamp - timestamp;
    if (timestampPassed >= 1.0) {
        //fps
        CGFloat fps = scheduleTimes / timestampPassed;
        printf("fps:%.1f, timePassed:%f\n", fps, timestampPassed);
        timestamp = link.timestamp;
        scheduleTimes = 0;
    }
}

#pragma mark - getter

- (NSMutableArray *)images {
    if(!_images){
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}
@end
