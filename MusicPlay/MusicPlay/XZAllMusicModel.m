//
//  XZAllMusicModel.m
//  XiaoZhu
//
//  Created by LM on 2017/4/20.
//  Copyright © 2017年 孙亚锋. All rights reserved.
//

#import "XZAllMusicModel.h"

@implementation XZAllMusicModel
-(id)initWithDictionary:(NSDictionary *)aDic{
    
    if (self = [super init]){
        
        self.musicId    =   [NSString stringWithFormat:@"%@",[aDic objectForKey:@"musicId"]];
        
        self.musicName      =   [aDic objectForKey:@"musicName"];
        
        self.img     =   [aDic objectForKey:@"img"];
        
        self.time  =   [aDic objectForKey:@"time"];
        
        self.songUrl     =   [aDic objectForKey:@"songUrl"];
        
        self.lyricsUrl  =   [aDic objectForKey:@"lyricsUrl"];
        
    }
    return self;
    
}
@end
