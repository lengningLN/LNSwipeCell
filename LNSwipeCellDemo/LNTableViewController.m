//
//  LNTableViewController.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/9.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNTableViewController.h"
#import "LNSwipeCell.h"
#import "LNSwipeModel.h"

@interface LNTableViewController ()<LNSwipeCellDelete,LNSwipeCellDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation LNTableViewController
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[LNSwipeCell class] forCellReuseIdentifier:@"cell"];
   
    [self loadData];
}

- (void)loadData
{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (int i = 0; i < 20; i++) {
                LNSwipeModel *model = [[LNSwipeModel alloc]init];
                model.state = 0;
                [self.dataSource addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LNSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
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

// 关闭除了indexPath之外的cell
- (void)closeCell:(NSIndexPath*)indexPath
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL shouldRefresh = NO;
        for (LNSwipeModel *model in self.dataSource) {
            if (model.state == 2) {
                shouldRefresh = YES;
                model.state = 0;
            }
        }
        if (shouldRefresh == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
    });
}


@end
