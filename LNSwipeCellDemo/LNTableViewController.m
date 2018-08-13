//
//  LNTableViewController.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/9.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNTableViewController.h"
#import "LNTableViewCell.h"
#import "LNCellModel.h"

@interface LNTableViewController ()<LNSwipeCellDelegate,LNSwipeCellDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation LNTableViewController

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"LNSwipeCell-Demo";
    [self.tableView registerClass:[LNTableViewCell  class] forCellReuseIdentifier:@"LNTableViewCell"];

    [self loadData];
}

- (void)loadData
{
    for (int i = 0; i < 30; i++) {
        LNCellModel *model = [[LNCellModel alloc]init];
        model.headUrl = @"headImage";
        model.isTop = i < 5;
        model.name = [NSString stringWithFormat:@"宁哥哥-LN-%d",i];
        model.message = [NSString stringWithFormat:@"热爱生活，热爱coding！"];
        model.unreadCount = i%4;
        [self.dataSource addObject:model];
    }
    [self.tableView reloadData];
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LNTableViewCell"];
    cell.tableView = tableView;
    cell.indexPath = indexPath;
    cell.swipeCellDelete = self;
    cell.swipeCellDataSource = self;
    cell.model = self.dataSource[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView------>%@ , indexPath------->%@",tableView,indexPath);
}


#pragma mark - swipeCellDelegate && dataSource
- (int)numberOfItemsInSwipeCell:(LNSwipeCell *)swipeCell
{
    return 2;
}

/*
 const NSString *LNSWIPCELL_FONT = @"LNSwipeCell_Font";
 const NSString *LNSWIPCELL_TITLE = @"LNSwipeCell_title";
 const NSString *LNSWIPCELL_TITLECOLOR = @"LNSwipeCell_titleColor";
 const NSString *LNSWIPCELL_BACKGROUNDCOLOR = @"LNSwipeCell_backgroundColor";
 const NSString *LNSWIPCELL_IMAGE = @"LNSwipeCell_image";
 */
- (NSDictionary *)dispositionForSwipeCell:(LNSwipeCell *)swipeCell atIndex:(int)index
{
    LNCellModel *model = self.dataSource[swipeCell.indexPath.row];
    NSString *title = @"删除";
    UIColor *color = [UIColor redColor];
    if (index == 1) {
        title = model.unreadCount >0 ? @"标为已读":@"标为未读";
        color = [UIColor lightGrayColor];
    }
    return @{
             LNSWIPCELL_FONT:[UIFont systemFontOfSize:13],
             LNSWIPCELL_TITLE:title,
             LNSWIPCELL_BACKGROUNDCOLOR:color
             };
}

- (CGFloat)itemWithForSwipeCell:(LNSwipeCell *)swipeCell atIndex:(int)index
{
    if (index == 0) {
        return 50;
    }else{
        return 70;
    }
}

- (void)swipeCell:(LNSwipeCell *)swipeCell didSelectButton:(UIButton *)button atIndex:(int)index
{
    NSLog(@"--%s--",__func__);
    LNCellModel *model = self.dataSource[swipeCell.indexPath.row];
    if (index == 0) {
        //确认删除
        [self.dataSource removeObjectAtIndex:swipeCell.indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[swipeCell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }else{
        //标为未读/标为已读
        NSString *title = [button titleForState:UIControlStateNormal];
        if ([title isEqualToString:@"标为未读"]) {
            model.unreadCount = 1;
        }else{
            model.unreadCount = 0;
        }
        LNTableViewCell *cell = (LNTableViewCell*)swipeCell;
        cell.model = model;
    }
}


- (void)swipeCellMoving:(LNSwipeCell *)swipeCell
{
    NSLog(@"--%s--",__func__);
}

- (void)swipeCellHadClose:(LNSwipeCell *)swipeCell {
    NSLog(@"--%s--",__func__);
}


- (void)swipeCellHadOpen:(LNSwipeCell *)swipeCell {
    NSLog(@"--%s--",__func__);
}



- (void)dealloc
{
    NSLog(@"------->%s",__func__);
}


@end
