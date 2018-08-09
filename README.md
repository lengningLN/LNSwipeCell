# LNSwipeCell
一套友好的、方便集成的针对cell的左滑编辑功能！
实现一个和微信功能一样的左滑编辑页面。

# Interduce 【简单介绍】
- 安装苹果官方的MVC的设计模式实现，类似UITableView的实现方式
- LNSwipeCell的编辑共能的数据由<LNSwipeCellDataSource>提供
- LNSwipeCell的编辑功能的事件由<LNSwipeCellDelete>提供
- UIView+Extension类是为了一步到位的访问和修改UIView子类的Frame相关属性

# Features【能做什么】
 - [x] 实现左滑显示，标为已读、删除 按钮
 - [x] 触摸到已经打开的cell的contentView，关闭cell
 - [x] 触模到其他cell，关闭已经打开的cell
 - [x] 滑动tableView，关闭已经打开的cell
 - [ ] 点击删除按钮，变化为确认删除按钮

# Class【使用到的类】
1. LNSwipeCell   -- 封装了左滑编辑的cell
2. LNSwipeModel  -- 支持cell编辑的数据
3. UIView+Extension -- 快速访问和修改UIView的Frame相关属性

# Getting Started【开始使用】
- 把三个类拖进工程中


## 使用方法


# Installation【安装】
