//
//  LNSwipeCell.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/6.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNSwipeCell.h"
#import <objc/runtime.h>
#import "UIView+LNFrame.h"

// item 对应的key
NSString *const LNSWIPCELL_FONT = @"LNSwipeCell_Font";
NSString *const LNSWIPCELL_TITLE = @"LNSwipeCell_title";
NSString *const LNSWIPCELL_TITLECOLOR = @"LNSwipeCell_titleColor";
NSString *const LNSWIPCELL_BACKGROUNDCOLOR = @"LNSwipeCell_backgroundColor";
NSString *const LNSWIPCELL_IMAGE = @"LNSwipeCell_image";

static const CGFloat singleItemExtraWidth = 25.0;

@interface LNSwipeCell ()<UIGestureRecognizerDelegate>


/**
 cell所属的tableView
 */
@property (nonatomic, weak) UITableView *tableView;

/**
 cell 的位置
 */
@property (nonatomic, strong) NSIndexPath *indexPath;


/**
 当前cell是都可以滑动编辑
 */
@property (nonatomic, assign) BOOL canSwipe;


/**
 可操作按钮的总数
 */
@property (nonatomic, assign) int totalCount;

/**
 包含的编辑按钮的总宽度
 */
@property (nonatomic, assign) CGFloat totalWidth;

/**
 所有可操作的按钮
 */
@property (nonatomic, strong) NSMutableArray *buttons;


@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) BOOL tryDeleteAction;

@end

@implementation LNSwipeCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customUI];
    }
    return self;
}

- (void)customUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    pan.delegate = self;
    [self.contentView addGestureRecognizer:pan];
    self.panGesture = pan;
}



// 解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint velocity = [panGesture velocityInView:self.contentView];
        if (velocity.x > 0 || self.state == LNSwipeCellStateHadOpen) {
            // 在touchesBegan：的时候处理
           // [self close:YES];
            return YES;
        } else if (fabs(velocity.x) > fabs(velocity.y)) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.state == LNSwipeCellStateHadOpen && gestureRecognizer == self.panGesture) {
        return NO;
    }
    if (self.panGesture == gestureRecognizer) {
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer*)gestureRecognizer;
        if ([self.swipeCellDelegate respondsToSelector:@selector(swipeCellCanSwipe:atIndexPath:)]) {
            self.canSwipe = [self.swipeCellDelegate swipeCellCanSwipe:self atIndexPath:self.indexPath];
        }
        //不允许在初始状态下往右边滑动
        CGPoint translation = [gesture translationInView:self.contentView];
        if ((self.contentView.x == 0 && translation.x > 0) || self.canSwipe == NO) {
            return NO;
        }
        self.totalCount = [self.swipeCellDataSource numberOfItemsInSwipeCell:self];
        //配置数据
        [self configureButtonsIfNeeded];
        return YES;
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}



//设置滑动后的显示
- (void)configureButtonsIfNeeded
{
    [self clearAllButtons];
    CGFloat content_width = self.contentView.frame.size.width;
    CGFloat content_height = self.contentView.frame.size.height;
    CGFloat allButtonWidth = 0;
    for (int i = 0; i < self.totalCount; i++) {
        CGFloat width = [self.swipeCellDataSource itemWithForSwipeCell:self atIndex:i];
        NSDictionary *dict = [self.swipeCellDataSource dispositionForSwipeCell:self atIndex:i];
        
        UIButton *button = [[UIButton alloc]init];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(content_width-1, 0, width, content_height);
        button.layer.cornerRadius = 8;
        button.layer.masksToBounds = YES;
        button.backgroundColor = dict[LNSWIPCELL_BACKGROUNDCOLOR];
        button.titleLabel.font = dict[LNSWIPCELL_FONT];
        [button setTitle:dict[LNSWIPCELL_TITLE] forState:UIControlStateNormal];
        [button setTitleColor:dict[LNSWIPCELL_TITLECOLOR] forState:UIControlStateNormal];
        [button setImage:dict[LNSWIPCELL_IMAGE] forState:UIControlStateNormal];
        [self.buttons addObject:button];
        [self insertSubview:button belowSubview:self.contentView];
        [self sendSubviewToBack:button];
        
        allButtonWidth += button.width;
        // 获取总宽度
        if (i == self.totalCount-1) {
            self.totalWidth = allButtonWidth + self.totalCount+2;
        }
    }
}


// 分别处理手势的各个阶段
- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self beginGesute:recognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self changedGesture:recognizer];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self endGesute:recognizer];
            break;
            
        default:
            break;
    }
}

- (void)beginGesute:(UIPanGestureRecognizer *)gesture
{
    if (self.state == LNSwipeCellStateHadOpen) {
//        [self close:YES];
//        return;
    }else{
        [self __closeOtherOpenCell];
    }
    
}

- (void)clearAllButtons
{
    if (self.buttons.count) {
        for (UIButton * button in self.buttons) {
            [button removeFromSuperview];
        }
        [self.buttons removeAllObjects];
    }
}


/* 手势变化中**/
- (void)changedGesture:(UIPanGestureRecognizer *)gesture
{
    if (self.totalCount == 0 )  return;
    //只允许水平滑动
    CGPoint translation = [gesture translationInView:self.contentView];
    if (fabs(translation.y) > fabs(translation.x)) {
        return;
    }
    // transform.x 往左滑动为负数，往右滑动为正数
    NSLog(@"translation.x-------->%.2f",translation.x);
    //只允许向左侧划开
    if (self.contentView.x > 0) {
        self.contentView.x = 0;
    }else if (self.contentView.x < -_totalWidth){
        self.contentView.x = -_totalWidth;
    }else {
        if (self.contentView.x + 2*translation.x < -_totalWidth) {
            self.contentView.x = -_totalWidth;
        }else if (self.contentView.x + 2*translation.x > 0){
            self.contentView.x = 0;
        }else{
            self.contentView.x += 2*translation.x;
        }
        [self adjustItemsShow];
    }
    
    // 清除相对的位移
    [gesture setTranslation:CGPointZero inView:self.contentView];
   
    _state = LNSwipeCellStateMoving;
    if ([self.swipeCellDelegate respondsToSelector:@selector(swipeCellMoving:)]) {
        [self.swipeCellDelegate swipeCellMoving:self];
    }
}


#pragma mark - 调整item的位置
- (void)adjustItemsShow
{
    CGFloat width = ABS(self.contentView.x);
    NSInteger count = _buttons.count;
    CGFloat firstOrginX = self.contentView.width;
    CGFloat indexWidth = 0;
    for (int i = 0 ; i < count; i++) {
        UIButton *item = _buttons[i];
        // 每个按钮占的比例
        CGFloat scale = item.width/_totalWidth;
        indexWidth += scale*width;
        item.x = firstOrginX-indexWidth-i-1;
    }
}

- (void)endGesute:(UIPanGestureRecognizer *)gesture
{
    //判断打开的宽度是不是达到三分之一，如果是开启，如果没有关闭
    if (self.contentView.x < -_totalWidth/3 ) {
        //打开
        [self open:YES];
    }else{
        [self close:YES];
    }
}

- (void)open:(BOOL)animate
{
    if (self.contentView.x <= -_totalWidth) {
        self.contentView.x = -_totalWidth;
        _state = LNSwipeCellStateHadOpen;
        self.tableView.allowsSelection = NO;
        if ([self.swipeCellDelegate respondsToSelector:@selector(swipeCellHadOpen:)]) {
            [self.swipeCellDelegate swipeCellHadClose:self];
        }
        return;
    }
    CGFloat duration = 0.5;
    CGFloat scale = ABS(self.contentView.x)/self.totalWidth;
    [UIView animateWithDuration:duration*scale
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.contentView.x = -self->_totalWidth;
                         [self adjustItemsShow];
                     } completion:^(BOOL finished){
                         self->_state = LNSwipeCellStateHadOpen;
                         self.tableView.allowsSelection = NO;
                         if ([self.swipeCellDelegate respondsToSelector:@selector(swipeCellHadOpen:)]) {
                             [self.swipeCellDelegate swipeCellHadClose:self];
                         }
                     }];
}


- (void)close:(BOOL)animate
{
    if (self.contentView.x == 0) {
        _state = LNSwipeCellStateHadClose;
         self.tableView.allowsSelection = YES;
        if ([self.swipeCellDelegate respondsToSelector:@selector(swipeCellHadClose:)]) {
            [self.swipeCellDelegate swipeCellHadClose:self];
        }
        self.panGesture.enabled = YES;
        return;
    }
    if (animate) {
        [UIView animateWithDuration:1.0
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.contentView.x = 0;
                             for (UIButton *button in self->_buttons) {
                                 button.x = self.contentView.width;
                             }
                         } completion:^(BOOL finished){
                             if (finished) {
                                 self->_state = LNSwipeCellStateHadClose;
                                 if ([self.swipeCellDelegate respondsToSelector:@selector(swipeCellHadClose:)]) {
                                     [self.swipeCellDelegate swipeCellHadClose:self];
                                 }
                                 self.tableView.allowsSelection = YES;
                                 self.panGesture.enabled = YES;
                             }
                         }];
    }else{
        self.contentView.x = 0;
        self->_state = LNSwipeCellStateHadClose;
        self.tableView.allowsSelection = YES;
        [self.contentView resignFirstResponder];
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    BOOL contain = CGRectContainsPoint(self.contentView.frame, point);
    if ( contain && self.state == LNSwipeCellStateHadOpen) {
        [self close:YES];
    }else{
        //检查其他cell有没有被打开
        [self __closeOtherOpenCell];
    }
}

- (void)buttonClick:(UIButton *)button
{
    int index = (int)[self.buttons indexOfObject:button];
    //这里假设为微信的功能，可更需需要自行修改
    if (index == 0) {
        if ([[button titleForState:UIControlStateNormal] isEqualToString:@"确认删除"]) {
            [self close:YES];
            [self.swipeCellDelegate swipeCell:self didSelectButton:button atIndex:index];
        }else{
            // 后期优化这个功能
            [self deleteAction:button];
        }
    }else{
        [self close:YES];
        [self.swipeCellDelegate swipeCell:self didSelectButton:button atIndex:index];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
   
    if (self.state == LNSwipeCellStateHadOpen && self.tryDeleteAction) {
        if (self.totalCount == 1) {
            self.contentView.x = -self.totalWidth-singleItemExtraWidth;
        }else if (self.totalCount > 1){
            self.contentView.x = - self.totalWidth;
        }
    }
    
}


- (void)deleteAction:(UIButton *)button
{
    self.tryDeleteAction = YES;
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         //如果只有一个删除按钮
                        CGFloat buttonWidth = self.totalWidth;
                        if (button.width == self.totalWidth) {
                            buttonWidth += singleItemExtraWidth;
                        }
                        button.frame = CGRectMake(self.width-buttonWidth, button.y, buttonWidth, button.height);
                        [button setTitle:@"确认删除" forState:UIControlStateNormal];
                     } completion:^(BOOL finished){
                         if (finished ) {
                             self.tryDeleteAction = NO;
                         }
    }];
}


#pragma mark -- 私有方法
/**
 关闭其他cell
 */
- (void)__closeOtherOpenCell
{
    if (self.tableView == nil) return ;
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell * cell in visibleCells) {
        if ([cell isKindOfClass:[LNSwipeCell class]] && cell != self ) {
            LNSwipeCell *swipeCell = (LNSwipeCell*)cell;
            if (swipeCell.state == LNSwipeCellStateHadOpen) {
                [swipeCell close:YES];
            }
        }
    }
}



#pragma mark - getter

- (UITableView *)tableView
{
    if (!_tableView) {
        UIView *cellSuperView = self.superview;
        while (cellSuperView && ![cellSuperView isKindOfClass:[UITableView class]]) {
            cellSuperView = cellSuperView.superview;
        }
        if (cellSuperView && [cellSuperView isKindOfClass:[UITableView class]]) {
            _tableView = (UITableView *)cellSuperView;
        }
    }
    return _tableView;
}

- (NSIndexPath *)indexPath
{
    return [self.tableView indexPathForCell:self];
}

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray new];
    }
    return _buttons;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end




