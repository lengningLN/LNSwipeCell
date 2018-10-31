
Pod::Spec.new do |s|

  s.name         = "LNSwipeCell"
  s.version      = "2.0.1"
  s.summary      = "一套友好的、方便集成的针对cell的左滑编辑功能！ 实现一个类似微信聊天列表的左滑编辑功能。."
  s.description  = <<-DESC
  一套友好的、方便集成的针对cell的左滑编辑功能！ 实现一个类似微信聊天列表的左滑编辑功能。
                   DESC
  s.homepage     = "https://github.com/lengningLN/LNSwipeCell"
  s.license      = "MIT"
  s.author             = { "LengNing" => "577935917@qq.com" }

  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/lengningLN/LNSwipeCell.git", :tag => s.version }
  s.source_files  = "LNSwipeCellDemo/LNSwipeCell/*.{h,m}"


end
