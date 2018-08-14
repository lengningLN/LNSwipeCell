//
//  LNSwipeCell.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/6.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNSwipeCell.h"
#import <objc/runtime.h>

// 用来快速访问和设置View的位置相关属性
@interface UIView (LNFrame)
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGSize  size;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@end

//  item 对应的key
const NSString *LNSWIPCELL_FONT = @"LNSwipeCell_Font";
const NSString *LNSWIPCELL_TITLE = @"LNSwipeCell_title";
const NSString *LNSWIPCELL_TITLECOLOR = @"LNSwipeCell_titleColor";
const NSString *LNSWIPCELL_BACKGROUNDCOLOR = @"LNSwipeCell_backgroundColor";
const NSString *LNSWIPCELL_IMAGE = @"LNSwipeCell_image";

@interface LNSwipeCell ()<UIGestureRecognizerDelegate>

/**
 可操作按钮的总数
 */
@property (nonatomic, assign) int totalCount;




/**
 所有可操作的按钮
 */
@property (nonatomic, strong) NSMutableArray *buttons;



@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation LNSwipeCell

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray new];
    }
    return _buttons;
}

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.ln_contentView.size = self.contentView.size;
}

- (void)customUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.ln_contentView == nil) {
        UIView *view = [[UIView alloc]init];
        [self.contentView addSubview:view];
        self.ln_contentView = view;

        //先加两个按钮
        for (int i = 0; i < 2; i++) {
            UIButton *button = [[UIButton alloc]init];
            button.tag = i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttons addObject:button];
            [self.contentView addSubview:button];
            [self.contentView sendSubviewToBack:button];
        }
        [self.contentView bringSubviewToFront:self.ln_contentView];
    }
    
    [self layoutIfNeeded];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    pan.delegate = self;
    [self.ln_contentView addGestureRecognizer:pan];
    self.panGesture = pan;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.ln_contentView addGestureRecognizer:tap];
}

- (void)tapAction
{
    if (self.state == LNSwipeCellStateHadOpen){
        [self __closeCurrentCell];
        return;
    }
    
    if ([self __hasOpenCell] == NO) {
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:self.indexPath];
        }
    }

}

- (void)setTableView:(UITableView *)tableView{
    if (_tableView != tableView && tableView) {
        _tableView = tableView;
        //监听tableView的contentOffset变化
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self __closeAllOpenCell];
    }
}


// 解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint velocity = [panGesture velocityInView:self.ln_contentView];
        if (velocity.x > 0) {
            [self close:YES];
            return YES;
        } else if (fabs(velocity.x) > fabs(velocity.y)) {
            return NO;
        }
    }
    
    return YES;
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
    _state = LNSwipeCellStateHadClose;
    //不允许在初始状态下往右边滑动
    CGPoint translation = [gesture translationInView:self.ln_contentView];
    if (self.ln_contentView.x == 0 && translation.x > 0) {
        return;
    }
    self.totalCount = [self.swipeCellDataSource numberOfItemsInSwipeCell:self];
    //配置数据
    [self configureButtonsIfNeeded];
}


//设置滑动后的显示
- (void)configureButtonsIfNeeded
{
    if (self.buttons.count < self.totalCount) {
        for (NSInteger i = self.buttons.count; i < self.totalCount; i++) {
            UIButton *button = [[UIButton alloc]init];
            button.tag = i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttons addObject:button];
            [self.contentView addSubview:button];
            [self.contentView sendSubviewToBack:button];
        }
    }else if (self.buttons.count > self.totalCount){
        for (NSInteger i = self.totalCount; i < self.buttons.count; i++) {
            [self.buttons removeObjectAtIndex:i];
        }
    }
    
    CGFloat left_margin = 0;
    CGFloat content_width = self.ln_contentView.frame.size.width;
    CGFloat content_height = self.ln_contentView.frame.size.height;
    for (int i = 0; i < self.totalCount; i++) {
        // 获取配置信息
        NSDictionary *dict = [self.swipeCellDataSource dispositionForSwipeCell:self atIndex:i];
        if (dict == nil) return ;
        UIButton *button = self.buttons[i];
        button.backgroundColor = dict[LNSWIPCELL_BACKGROUNDCOLOR];
        button.titleLabel.font = dict[LNSWIPCELL_FONT];
        [button setTitle:dict[LNSWIPCELL_TITLE] forState:UIControlStateNormal];
        [button setTitleColor:dict[LNSWIPCELL_TITLECOLOR] forState:UIControlStateNormal];
        [button setImage:dict[LNSWIPCELL_IMAGE] forState:UIControlStateNormal];
        
        //获取宽度
        CGFloat width = [self.swipeCellDataSource itemWithForSwipeCell:self atIndex:i];
        //button.frame = CGRectMake(content_width-width-left_margin, 0, width, content_height);
        button.frame = CGRectMake(content_width, 0, width, content_height);
        left_margin += width;
        // 获取总宽度
        if (i == self.totalCount-1) {
            _totalWidth = left_margin;
        }
    }
}

/* 手势变化中**/
- (void)changedGesture:(UIPanGestureRecognizer *)gesture
{
    if (self.totalCount == 0)  return;
    //只允许水平滑动
    CGPoint translation = [gesture translationInView:self.ln_contentView];
    if (fabs(translation.y) > fabs(translation.x)) {
        return;
    }
    //只允许向左侧划开
    if (self.ln_contentView.x == 0 && translation.x > 0) {
        return;
    }
    _state = LNSwipeCellStateMoving;
    [self __closeAllOpenCell];
    if ([self.swipeCellDelete respondsToSelector:@selector(swipeCellMoving:)]) {
        [self.swipeCellDelete swipeCellMoving:self];
    }
    // 手指移动后在相对坐标中的偏移量
    if (self.ln_contentView.x < -_totalWidth) {
        self.ln_contentView.x = -_totalWidth;
        [self adjustItemsShow];
    }else if (self.ln_contentView.x > 0){
        self.ln_contentView.x = 0;
    }else{
        if (self.ln_contentView.x + 2*translation.x >= -_totalWidth) {
            self.ln_contentView.x += 2*translation.x;
        }else{
            self.ln_contentView.x = -_totalWidth;
        }
        
        [self adjustItemsShow];
    }
    // 清除相对的位移
    [gesture setTranslation:CGPointZero inView:self.ln_contentView];
   
}

- (void)adjustItemsShow
{
    if (self.ln_contentView.x == _totalWidth) {
        CGFloat orgin_x = self.ln_contentView.width;
        for (int i = 0 ; i < _buttons.count; i++) {
            UIButton *item = _buttons[i];
            orgin_x -= item.width;
            item.frame = CGRectMake(orgin_x, 0, item.width, item.height);
        }
        return;
    }
    CGFloat width = ABS(self.ln_contentView.x);
    NSInteger count = _buttons.count;
    CGFloat firstOrginX = self.ln_contentView.width;
    CGFloat indexWidth = 0;
    for (int i = 0 ; i < count; i++) {
        UIButton *item = _buttons[i];
        // 每个按钮占的比例
        CGFloat scale = item.width/self.totalWidth;
        indexWidth += scale*width;
        item.x = firstOrginX-indexWidth;
    }
}

- (void)endGesute:(UIPanGestureRecognizer *)gesture
{
    //判断打开的宽度是不是达到三分之一，如果是开启，如果没有关闭
    if (self.ln_contentView.x < -_totalWidth/3 ) {
        //打开
        [self open:YES];
    }else{
        [self close:YES];
    }
}


- (void)open:(BOOL)animate
{
    if (self.ln_contentView.x <= -_totalWidth) {
        self.ln_contentView.x = -_totalWidth;
        _state = LNSwipeCellStateHadOpen;
        return;
    }
    CGFloat duration = 0.5;
    CGFloat scale = ABS(self.ln_contentView.x)/self.totalWidth;
    [UIView animateWithDuration:duration*scale
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.ln_contentView.x = -self->_totalWidth;
                         [self adjustItemsShow];
                     } completion:^(BOOL finished){
                         self->_state = LNSwipeCellStateHadOpen;
                         if ([self.swipeCellDelete respondsToSelector:@selector(swipeCellHadOpen:)]) {
                             [self.swipeCellDelete swipeCellHadClose:self];
                         }
                     }];
}


- (void)close:(BOOL)animate
{
    if (self.ln_contentView.x == 0) {
        _state = LNSwipeCellStateHadClose;
        return;
    }
    
    [UIView animateWithDuration:1.0
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.ln_contentView.x = 0;
                         for (UIButton *button in self->_buttons) {
                             button.x = self.ln_contentView.width;
                         }
                     } completion:^(BOOL finished){
                         self->_state = LNSwipeCellStateHadClose;
                         if ([self.swipeCellDelete respondsToSelector:@selector(swipeCellHadClose:)]) {
                             [self.swipeCellDelete swipeCellHadClose:self];
                         }
                     }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.contentView];
    BOOL contain = CGRectContainsPoint(self.ln_contentView.frame, point);
    if ( contain && self.state == LNSwipeCellStateHadOpen) {
        [self __closeCurrentCell];
    }else{
        //检车其他cell有没有被打开
        [self __closeAllOpenCell];
    }
}

- (void)buttonClick:(UIButton *)button
{
    int index = (int)[self.buttons indexOfObject:button];
    //这里假设为微信的功能，可更需需要自行修改
    if (index == 0) {
        if (button.width == _totalWidth) {
            [self close:YES];
            [self.swipeCellDelete swipeCell:self didSelectButton:button atIndex:index];
        }else{
            [self deleteAction:button];
        }
    }else{
        [self close:YES];
        [self.swipeCellDelete swipeCell:self didSelectButton:button atIndex:index];
    }
}

- (void)deleteAction:(UIButton *)button
{
    [UIView animateWithDuration:.4
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         button.frame = CGRectMake(button.x-(self->_totalWidth-button.width), 0, self->_totalWidth, button.height);
                         [button setTitle:@"确认删除" forState:UIControlStateNormal];
                     } completion:^(BOOL finished){
                         
                     }];
}


#pragma mark -- 私有方法
/**
 关闭其他cell
 */
- (void)__closeAllOpenCell
{
    if (self.tableView == nil) return ;
    NSArray *visibleCells = [self.tableView visibleCells];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (UITableViewCell * cell in visibleCells) {
            if (![cell isKindOfClass:[LNSwipeCell class]]) {
                continue;
            }
            LNSwipeCell *swipeCell = (LNSwipeCell*)cell;
            if (swipeCell.state == LNSwipeCellStateHadOpen) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [swipeCell close:YES];
                });
                return ;
            }
        }
    });
}

- (BOOL)__hasOpenCell
{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (LNSwipeCell * cell in visibleCells) {
        if (cell.state == LNSwipeCellStateHadOpen) {
            return YES;
        }
    }
    return NO;
}


/**
 关闭当前cell
 */
- (void)__closeCurrentCell
{
    if (_state == LNSwipeCellStateHadOpen) {
        [self close:YES];
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end




#pragma mark - 添加一个快速访问的UIView子类的分类
#pragma mark - 

@implementation UIView (LNFrame)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.bounds.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.bounds.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.bounds.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}




@end
