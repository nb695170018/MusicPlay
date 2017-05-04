//
//  XZAllMusicModel.h
//  XiaoZhu
//
//  Created by LM on 2017/4/20.
//  Copyright © 2017年 孙亚锋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZAllMusicModel : NSObject


@property (nonatomic, copy)NSString *musicName;
@property (nonatomic, copy)NSString *time;
@property (nonatomic, copy)NSString *img;
@property (nonatomic, copy)NSString *musicId;
@property (nonatomic, copy)NSString *songUrl;
@property (nonatomic, copy)NSString *lyricsUrl;


-(id)initWithDictionary:(NSDictionary *)aDic;
@end
