//
//  LNSwipeCell.h
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/6.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString *LNSWIPCELL_FONT;
extern const NSString *LNSWIPCELL_TITLE;
extern const NSString *LNSWIPCELL_TITLECOLOR;
extern const NSString *LNSWIPCELL_BACKGROUNDCOLOR;
extern const NSString *LNSWIPCELL_IMAGE;


typedef NS_OPTIONS(NSUInteger, LNSwipeCellState) {
    LNSwipeCellStateHadClose   = 0,//默认全部闭合
    LNSwipeCellStateMoving    ,    //正在打开,或者正在关闭，手指还没有离开cell
    LNSwipeCellStateHadOpen   ,    //已经打开
};

@protocol LNSwipeCellDataSource , LNSwipeCellDelegate;

@interface LNSwipeCell : UITableViewCell


/**
 所属的tableView,一定要传
 */
@property (nonatomic, weak) UITableView *tableView;

/**
 cell 的位置，一定要穿
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 替换cell的cententView使用
 */
@property (nonatomic, strong) UIView *ln_contentView;

/**
 事件代理
 */
@property (nonatomic, weak) id<LNSwipeCellDelegate> swipeCellDelete;

/**
 数据源代理
 */
@property (nonatomic, weak) id<LNSwipeCellDataSource> swipeCellDataSource;


/**
 当前cell的状态
 */
@property (nonatomic, assign, readonly) LNSwipeCellState state;

/**
 包含的编辑按钮的总宽度
 */
@property (nonatomic, assign, readonly) CGFloat totalWidth;

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










