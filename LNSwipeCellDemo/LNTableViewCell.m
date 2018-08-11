//
//  LNTableViewCell.m
//  LNSwipeCellDemo
//
//  Created by 刘宁 on 2018/8/11.
//  Copyright © 2018年 刘宁. All rights reserved.
//

#import "LNTableViewCell.h"
#import "LNCellModel.h"

@interface LNTableViewCell ()
/**
 头像信息
 */
@property (nonatomic, strong) UIImageView *headView;

/**
 name
 */
@property (nonatomic, strong) UILabel *nameL;

/**
 消息
 */
@property (nonatomic, strong) UILabel *messageL;

/**
 时间
 */
@property (nonatomic, strong) UILabel *timgeL;

/**
 未读消息数
 */
@property (nonatomic, strong) UILabel *countL;
@end

@implementation LNTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addUI];
    }
    return self;
}

- (void)addUI
{
    // 头像，单聊
    _headView = [[UIImageView alloc]init];
    [self.ln_contentView addSubview:_headView];
    
    // 姓名
    _nameL = [[UILabel alloc]init];
    _nameL.textAlignment = NSTextAlignmentLeft;
    _nameL.font = [UIFont systemFontOfSize:15];
    _nameL.textColor = [UIColor blackColor];
    [self.ln_contentView addSubview:_nameL];
    
    // 消息
    _messageL = [[UILabel alloc]init];
    _messageL.textAlignment = NSTextAlignmentLeft;
    _messageL.font = [UIFont systemFontOfSize:13];
    _messageL.textColor = [UIColor lightGrayColor];
    [self.ln_contentView addSubview:_messageL];
    
    // 时间
    _timgeL = [[UILabel alloc]init];
    _timgeL.textAlignment = NSTextAlignmentRight;
    _timgeL.font = [UIFont systemFontOfSize:12];
    _timgeL.textColor = [UIColor lightTextColor];
    [self.ln_contentView addSubview:_timgeL];
    
    // 未读消息数
    _countL = [[UILabel alloc]init];
    _countL.font = [UIFont systemFontOfSize:10];
    _countL.backgroundColor = [UIColor redColor];
    _countL.textColor = [UIColor whiteColor];
    _countL.textAlignment = NSTextAlignmentCenter;
    [self.ln_contentView addSubview:_countL];
    
    CGFloat screentWidth = [UIScreen mainScreen].bounds.size.width;
    _headView.frame = CGRectMake(15, 15, 50, 50);
    _nameL.frame = CGRectMake(CGRectGetMaxX(_headView.frame)+15, 18, screentWidth-CGRectGetMaxX(_headView.frame)-35, 20);
    _messageL.frame = CGRectMake(_nameL.frame.origin.x, CGRectGetMaxY(_headView.frame)-22, _nameL.frame.size.width, 20);
    _timgeL.frame = CGRectMake(screentWidth-60-15, 15, 60, 14);
    _countL.frame = CGRectMake(CGRectGetMaxX(_headView.frame)-13, _headView.frame.origin.y-7, 20, 20);
    _countL.layer.masksToBounds = YES;
    _countL.layer.cornerRadius = 10;
}

- (void)setModel:(LNCellModel *)model
{
    _model = model;
    // 是否置顶
    
    self.ln_contentView.backgroundColor = model.isTop?[UIColor colorWithRed:242/255.0 green:250/255.0 blue:1 alpha:1]:[UIColor whiteColor];

    // 头像
    self.headView.image = [UIImage imageNamed:model.headUrl];
    // 姓名
    self.nameL.text = model.name;
    // 消息
    self.messageL.text = model.message;
    // 时间
    self.timgeL.text = model.time;
    // 未读消息数
    self.countL.hidden = (model.unreadCount==0);
    self.countL.text = [NSString stringWithFormat:@"%d",model.unreadCount];
}



@end
