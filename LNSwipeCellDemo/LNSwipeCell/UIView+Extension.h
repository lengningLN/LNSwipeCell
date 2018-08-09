//
//  UIView+Extension.h
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/9.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LNFrame)
// 用来快速访问和设置View的位置相关属性
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGSize  size;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic, readonly) CGFloat middleX;
@property (nonatomic, readonly) CGFloat middleY;
@property (nonatomic, readonly) CGPoint centerInSelf;
@property (nonatomic, readonly) CGFloat bottom;
@property (nonatomic, readonly) CGFloat left;
@property (nonatomic, readonly) CGFloat right;
@property (nonatomic, readonly) CGFloat top;
@property (nonatomic, readonly) NSString *frameString;
@end
