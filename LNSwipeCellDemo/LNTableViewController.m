//
//  LNTableViewController.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/9.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNTableViewController.h"
#import "LNSwipeCell.h"

@interface LNTableViewController ()<LNSwipeCellDelete,LNSwipeCellDataSource>

@end

@implementation LNTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[LNSwipeCell class] forCellReuseIdentifier:@"cell"];

}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LNSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.tableView = tableView;
    cell.swipeCellDelete = self;
    cell.swipeCellDataSource = self;
    cell.ln_contentView.backgroundColor = indexPath.row %2 == 0 ?[UIColor purpleColor]:[UIColor blueColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    NSString *title = @"删除";
    UIColor *color = [UIColor redColor];
    if (index == 1) {
        title = @"标为已读";
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
    
}


- (void)swipeCellMoving:(LNSwipeCell *)swipeCell
{
    
}

- (void)swipeCellHadClose:(LNSwipeCell *)swipeCell {
    
}


- (void)swipeCellHadOpen:(LNSwipeCell *)swipeCell {
    
}



- (void)dealloc
{
    NSLog(@"%s",__func__);
}


@end
