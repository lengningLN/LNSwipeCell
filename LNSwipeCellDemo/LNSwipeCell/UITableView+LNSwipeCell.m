//
//  UITableView+LNSwipeCell.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/14.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "UITableView+LNSwipeCell.h"
#import "LNSwipeCell.h"
@implementation UITableView (LNSwipeCell)
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray *visibleCells = [self visibleCells];
    if (visibleCells.count == 0) return;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (UITableViewCell * cell in visibleCells) {
            if (![cell isKindOfClass:[LNSwipeCell class]]) {
                continue;
            }
            LNSwipeCell *swipeCell = (LNSwipeCell *)cell;
            if (swipeCell.state == LNSwipeCellStateHadOpen) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [swipeCell close:YES];
                    return ;
                });
            }
        }
    });
}
@end
