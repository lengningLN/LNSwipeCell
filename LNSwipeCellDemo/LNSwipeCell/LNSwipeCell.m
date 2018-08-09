//
//  LNSwipeCell.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/6.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNSwipeCell.h"
#import "LNSwipeModel.h"
#import "UIView+Extension.h"

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
 按钮的总宽度
 */
@property (nonatomic, assign) CGFloat totalWidth;

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.ln_contentView.frame = self.contentView.bounds;
}

- (void)customUI
{
    self.layer.masksToBounds = NO;
    self.contentView.layer.masksToBounds = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.ln_contentView == nil) {
        UIView *view = [[UIView alloc]init];
        [self.contentView addSubview:view];
        self.ln_contentView = view;

        //先加两个按钮
        for (int i = 0; i < 2; i++) {
            UIButton *button = [[UIButton alloc]init];
            [self.buttons addObject:button];
            [self.contentView addSubview:button];
        }
        [self.contentView bringSubviewToFront:self.ln_contentView];
    }
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    pan.delegate = self;
    [self.ln_contentView addGestureRecognizer:pan];
    self.panGesture = pan;
    [self layoutIfNeeded];
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
    self.state = LNSwipeCellStateHadClose;
    //不允许在初始状态下往右边滑动
    CGPoint translation = [gesture translationInView:self.ln_contentView];
    if (self.ln_contentView.x == 0 && translation.x > 0) {
        return;
    }
    self.totalCount = [self.swipeCellDataSource numberOfItemsInSwipeCell:self];
    [self configureButtonsIfNeeded];
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
    self.state = LNSwipeCellStateMoving;
    if ([self.swipeCellDelete respondsToSelector:@selector(swipeCellMoving:)]) {
        [self.swipeCellDelete swipeCellMoving:self];
    }
    
    // 手指移动后在相对坐标中的偏移量
    if (self.ln_contentView.x < -self.totalWidth) {
        CGRect rect = self.ln_contentView.frame;
        rect.origin.x = -self.totalWidth;
        self.ln_contentView.frame = rect;
    }else if (self.ln_contentView.x >0){
        CGRect rect = self.ln_contentView.frame;
        rect.origin.x = 0;
        self.ln_contentView.frame = rect;
    }else{
        CGFloat center_x = self.ln_contentView.center.x;
        center_x += translation.x;
        self.ln_contentView.center = CGPointMake(center_x, self.ln_contentView.center.y);
    }
    // 清除相对的位移
    [gesture setTranslation:CGPointZero inView:self.ln_contentView];
   
}

- (void)endGesute:(UIPanGestureRecognizer *)gesture
{
    //判断花开的宽度是不是达到50，如果是开启，如果没有关闭
    [self.ln_contentView layoutIfNeeded];
    if (self.ln_contentView.x < -40 ) {
        //打开
        [self open:YES];
    }else{
        [self close:YES];
    }
}

//设置滑动后的显示
- (void)configureButtonsIfNeeded
{
    if (self.buttons.count < self.totalCount) {
        for (NSInteger i = self.buttons.count; i < self.totalCount; i++) {
            UIButton *button = [[UIButton alloc]init];
            [self.buttons addObject:button];
            [self.contentView addSubview:button];
        }
        [self.contentView bringSubviewToFront:self.ln_contentView];
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
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //获取宽度
        CGFloat width = [self.swipeCellDataSource itemWithForSwipeCell:self atIndex:i];
        button.frame = CGRectMake(content_width-width-left_margin, 0, width, content_height);
        
        left_margin += width;
        // 获取总宽度
        if (i == self.totalCount-1) {
            self.totalWidth = left_margin;
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.contentView];
    if (CGRectContainsPoint(self.ln_contentView.frame, point)) {

    }
}


- (void)buttonClick:(UIButton *)button
{
    int index = (int)[self.buttons indexOfObject:button];
    [self.swipeCellDelete swipeCell:self didSelectButton:button atIndex:index];
}


- (void)open:(BOOL)animate
{
    if (self.ln_contentView.x == -self.totalWidth) {
        self.state = LNSwipeCellStateHadOpen;
        return;
    }
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.ln_contentView.x = -self.totalWidth;
                     } completion:^(BOOL finished){
                         self.state = LNSwipeCellStateHadOpen;
                         if ([self.swipeCellDelete respondsToSelector:@selector(swipeCellHadOpen:)]) {
                             [self.swipeCellDelete swipeCellHadClose:self];
                         }
                     }];
}
- (void)close:(BOOL)animate
{
    if (self.ln_contentView.x == 0) {
        self.state = LNSwipeCellStateHadClose;
        return;
    }
    [UIView animateWithDuration:1.0
                          delay:0
         usingSpringWithDamping:0.9
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.ln_contentView.x = 0;
                     } completion:^(BOOL finished){
                         self.state = LNSwipeCellStateHadClose;
                         if ([self.swipeCellDelete respondsToSelector:@selector(swipeCellHadClose:)]) {
                              [self.swipeCellDelete swipeCellHadClose:self];
                         }
                     }];
}

@end
