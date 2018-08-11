//
//  LNCellModel.h
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/11.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNCellModel : NSObject
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) int unreadCount;

/**
 是否置顶
 */
@property (nonatomic, assign) BOOL isTop;
@end
