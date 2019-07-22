//
//  LNSwipeCell.h
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/6.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义编辑文字可修改属性key
extern NSString *const LNSWIPCELL_FONT;
extern NSString *const LNSWIPCELL_TITLE;
extern NSString *const LNSWIPCELL_TITLECOLOR;
extern NSString *const LNSWIPCELL_BACKGROUNDCOLOR;
extern NSString *const LNSWIPCELL_IMAGE;


typedef NS_OPTIONS(NSUInteger, LNSwipeCellState) {
    LNSwipeCellStateHadClose   = 0,//默认全部闭合
    LNSwipeCellStateMoving    ,    //正在打开,或者正在关闭，手指还没有离开cell
    LNSwipeCellStateHadOpen   ,    //已经打开
};

@protocol LNSwipeCellDataSource , LNSwipeCellDelegate;

@interface LNSwipeCell : UITableViewCell



/**
 事件代理
 */
@property (nonatomic, weak) id<LNSwipeCellDelegate> swipeCellDelegate;

/**
 数据源代理
 */
@property (nonatomic, weak) id<LNSwipeCellDataSource> swipeCellDataSource;


/**
 当前cell的状态
 */
@property (nonatomic, assign, readonly) LNSwipeCellState state;


/**
 打开cell，如果有特殊需求可以调用，一般用不到

 @param animate 是否要动画
 */
- (void)open:(BOOL)animate;


/**
 关闭cell，如果有特殊需求可以调用，一般用不到

 @param animate 是否要动画
 */
- (void)close:(BOOL)animate;

@end



@protocol LNSwipeCellDataSource <NSObject>

@required

/**
 number of items
 
 @param swipeCell 当前cell
 @return count of items;
 */
- (int)numberOfItemsInSwipeCell:(LNSwipeCell *)swipeCell;

@optional

/**
 设置每个可操作的item都为button，设置好之后返回
 
 @param swipeCell cell
 @param index   位置自右往左，从0开始
 @return 设置好的item信息：包括字体、颜色、图片、背景色等
 key包括如下字段，根据需要设置
 extern const NSString *LNSWIPCELL_FONT;
 extern const NSString *LNSWIPCELL_TITLE;
 extern const NSString *LNSWIPCELL_TITLECOLOR;
 extern const NSString *LNSWIPCELL_BACKGROUNDCOLOR;
 extern const NSString *LNSWIPCELL_IMAGE;
 */
- (NSDictionary *)dispositionForSwipeCell:(LNSwipeCell *)swipeCell atIndex:(int)index;


/**
 设置每一项的宽度
 
 @param swipeCell cell
 @param index 位置自右往左，从0开始
 @return 宽度
 */
- (CGFloat)itemWithForSwipeCell:(LNSwipeCell *)swipeCell atIndex:(int)index;
@end



/**
 cell 的事件代理
 */
@protocol LNSwipeCellDelegate <NSObject>


/**
 是否开启左滑编辑功能
 
 @param swipeCell cell
 @param indexPath indexPath
 @return BOOL
 */
- (BOOL)swipeCellCanSwipe:(LNSwipeCell *)swipeCell atIndexPath:(NSIndexPath *)indexPath;

/**
 某一个item被点击后触发的事件
 
 @param swipeCell cell
 @param button button
 @param index 位置
 */
- (void)swipeCell:(LNSwipeCell *)swipeCell didSelectButton:(UIButton *)button atIndex:(int)index;


/**
 cell正在所有滑动，手指还没有离开，不确定是打开还是关闭
 
 @param swipeCell cell
 */
- (void)swipeCellMoving:(LNSwipeCell *)swipeCell;

/**
 当左滑打开后触发该事件
 
 @param swipeCell cell
 */
- (void)swipeCellHadOpen:(LNSwipeCell *)swipeCell;

/**
 cell优化打开时触发该事件
 
 @param swipeCell cell
 */
- (void)swipeCellHadClose:(LNSwipeCell *)swipeCell;

@end










