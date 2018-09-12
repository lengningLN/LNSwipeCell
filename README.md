# LNSwipeCell
一套友好的、方便集成的针对cell的左滑编辑功能！
实现一个类似微信聊天页表的左滑编辑功能。

# 本次优化
1. 解决删除cell是越界的问题
2. 对cell关闭做优化
3. 新增当手指接触到tableView空白处能关闭cell
4. 打开、关闭cell时，完全实现和微信聊天列表页的cell一样的动画效果
5. Demo中实现不同cell不同数量的编辑model，并实现置顶等功能



# Interduce 【简单介绍】
- 按照苹果官方的MVC的设计模式封装的Cell控件，类似UITableView的实现方式
- LNSwipeCell的编辑功能的数据由*LNSwipeCellDataSource*提供
- LNSwipeCell的编辑功能的事件由*LNSwipeCellDelegate*提供


# Features【能做什么】
 - [x] 实现左滑显示，标为已读、删除、置顶等多个按钮
 - [x] 触摸到已经打开的cell的contentView区域，关闭cell
 - [x] 触模到其他cell，关闭已经打开的cell
 - [x] 滑动tableView，关闭已经打开的cell
 - [x] 触摸到tableView的空白区域，关闭打开的cell
 - [x] 打开和关闭cell时，编辑按钮按照微信一样的动画出现
 - [ ] 点击删除按钮，变化为确认删除按钮
 
# 目前存在的问题
1. 由删除变化到确认删除的操作有问题，因为一旦改变tableview的子视图的frame，tabelview就会吧contentView归零，目前没找到合适的解决方式
2. 极端情况细节的处理不够完美

# Class【使用到的类】
1. LNSwipeCell   -- 封装了左滑编辑的cell


# Getting Started【开始使用】

## 效果演示

![](https://github.com/lengningLN/LNSwipeCellDemo/blob/master/LNSwipeCellDemo/resource/swipecell2.gif)  


## 文字介绍
- 把LNSwipeCell类拖进工程中
- 让你的cell继承LNSwipeCell，因为lNSwipeCell只封装了左滑编辑的逻辑和实现，因此你要根据需求自己绘制cell的UI
- 接受LNSwipeCellDataSource和LNSwipeCellDelegate
- 根据需要实现对应的协议方法

## 代码介绍
- 创建cell的设置
```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LNSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.swipeCellDelete = self;
    cell.swipeCellDataSource = self;
    
    return cell;
}
```

- 需要实现的数据协议
```
/**
 number of items
 
 @param swipeCell 当前cell
 @return count of items;
 */
- (int)numberOfItemsInSwipeCell:(LNSwipeCell *)swipeCell;

/**
 设置每个可操作的item都为button，把需要设置的属性放到字典中返回
 
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

```

- 可能感兴趣的事件协议
```
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

```




# more about  【更多】
1. 如果有什么问题，请在[issues](https://github.com/lengningLN/LNSwipeCellDemo/issues)区域提问，我会抽时间改进。
2. [我的博客](http://lengningln.github.io/)
3. [我的微博](http://weibo.com/liuning185)
### 打赏
![](http://m.qpic.cn/psb?/V11R4JcH0fAdbu/h4vWrizoOlby*zntVMiu.1F9CMMMx2T9BOWUjSEnCE8!/b/dDUBAAAAAAAA&bo=nALQAgAAAAADB24!&rf=viewer_4)

