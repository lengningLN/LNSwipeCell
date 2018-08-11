//
//  LNTableViewCell.h
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/11.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNSwipeCell.h"

@class LNCellModel;
@interface LNTableViewCell : LNSwipeCell
@property (nonatomic, strong) LNCellModel *model;
@end
