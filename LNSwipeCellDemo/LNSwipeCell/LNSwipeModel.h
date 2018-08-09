//
//  LNSwipeModel.h
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/9.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, LNSwipeState) {
    LNSwipeStateHadClose   = 0,//默认全部闭合
    LNSwipeStateMoving    ,    //正在打开
    LNSwipeStateHadOpen   ,    //已经打开
};

@interface LNSwipeModel : NSObject
@property (nonatomic, assign) LNSwipeState state;
@end
