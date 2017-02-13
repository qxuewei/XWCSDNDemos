//
//  ViewController.m
//  JSPatchDemo
//
//  Created by 邱学伟 on 2017/2/13.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "ViewController.h"

#define kID @"kID"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *demoTableVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDemoTableVC];
}

-(void)loadDemoTableVC{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.demoTableVC = tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 18;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kID];
    }
    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor lightGrayColor] : [UIColor yellowColor];
    return cell;
}

/**  热更新的OC 代码
 -(void)loadDemoTableVC{
 UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
 tableView.delegate = self;
 tableView.dataSource = self;
 [self.view addSubview:tableView];
 self.demoTableVC = tableView;
 }
 
 #pragma mark - UITableViewDataSource
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 return 8;
 }
 
 -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
 return 2;
 }
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kID];
 if (!cell) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kID];
 }
 cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor greenColor] : [UIColor redColor];
 return cell;
 }
 */

@end
