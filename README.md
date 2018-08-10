# LNSwipeCell
一套友好的、方便集成的针对cell的左滑编辑功能！
实现一个和微信功能一样的左滑编辑页面。

# 本次优化
1. 删除多余的类，只提供一个LNSwipeCell，model删除了，把cell的状态放到cell内部管理，view的frame的相关属性的快速访问也集成到cell内部
2. cell内部的触摸，直接能关闭已经打开的cell
3. 监听tableView的滑动，关闭已经打开的cell

# Interduce 【简单介绍】
- 按照苹果官方的MVC的设计模式封装的Cell控件，类似UITableView的实现方式
- LNSwipeCell的编辑功能的数据由*LNSwipeCellDataSource*提供
- LNSwipeCell的编辑功能的事件由*LNSwipeCellDelegate*提供


# Features【能做什么】
 - [x] 实现左滑显示，标为已读、删除 按钮
 - [x] 触摸到已经打开的cell的contentView，关闭cell
 - [x] 触模到其他cell，关闭已经打开的cell
 - [x] 滑动tableView，关闭已经打开的cell
 - [ ] 点击删除按钮，变化为确认删除按钮

# Class【使用到的类】
1. LNSwipeCell   -- 封装了左滑编辑的cell


# Getting Started【开始使用】

## 文字介绍
- 把LNSwipeCell类拖进工程中
- 让你的cell继承LNSwipeCell，因为lNSwipeCell只封装了左滑编辑的逻辑和实现，因此你要根据需求自己绘制cell的UI
- 把之前加载到cell的contentView上的视图，都加载到cell的ln_contentView上
- 接受LNSwipeCellDataSource和LNSwipeCellDelegate
- 根据需要实现对应的协议方法

## 代码介绍
- 创建cell的设置
```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LNSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.tableView = tableView;
    cell.swipeCellDelete = self;
    cell.swipeCellDataSource = self;
    cell.ln_contentView.backgroundColor = indexPath.row %2 == 0 ?[UIColor purpleColor]:[UIColor blueColor];
    
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
1. 如果有什么问题，请在issue区域提问，我会抽时间改进。
2. [我的博客](https://www.jianshu.com/u/dbd52f0e4f1c)
### 打赏
![](http://m.qpic.cn/psb?/V11R4JcH0fAdbu/rYiFGKO*rsz3odB9curI0NDj4u9bA2qwI5bLHHEjbK8!/b/dDQBAAAAAAAA&bo=WAKEAwAAAAARB.0!&rf=viewer_4)

