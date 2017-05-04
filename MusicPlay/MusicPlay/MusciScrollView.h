//
//  MusciScrollView.h
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LrcLabel;
@interface MusciScrollView : UIScrollView


/** 歌词 名*/
@property(nonatomic,copy) NSString *lrcName;
/** 歌词 名*/
@property(nonatomic,copy) NSString *lrcppp;

/** 当前播放器播放时间 */
@property(nonatomic,assign)NSTimeInterval currentTime;


@property(nonatomic,weak)LrcLabel *lrcLab;

/** 当前播放器播放总时间 */
@property(nonatomic,assign)NSTimeInterval totlaDurtion;


@end
