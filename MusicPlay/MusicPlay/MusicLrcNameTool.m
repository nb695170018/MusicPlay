//
//  MusicLrcNameTool.m
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//
/*
[ti:]
[ar:]
[al:]

[00:00.89]传奇
[00:02.34]作词：刘兵
[00:03.82]作曲：李健
[00:05.48]演唱：王菲
[00:07.39]
[00:33.20]只是因为在人群中多看了你一眼
[00:40.46]再也没能忘掉你容颜
[00:47.68]梦想着偶然能有一天再相见
[00:55.29]从此我开始孤单思念
[01:00.90]
[01:02.38]想你时你在天边
[01:09.86]想你时你在眼前
[01:17.44]想你时你在脑海
[01:24.98]想你时你在心田
[01:31.78]
[01:32.64]宁愿相信我们前世有约
[01:38.90]今生的爱情故事 不会再改变
[01:47.46]宁愿用这一生等你发现
[01:54.23]我一直在你身旁 从
 */
#import "MusicLrcNameTool.h"
#import "LrcLineModel.h"

@implementation MusicLrcNameTool
+(NSArray *)lrcToolWithMusicName:(NSString *)lrcName
{
    
    //将数据保存到本地指定位置
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //music文件夹
    NSString *createPath = [NSString stringWithFormat:@"%@/music", docDirPath];
    
    //1 获取路径
//    NSString * path = [[NSBundle mainBundle]pathForResource:lrcName ofType:nil];
    NSString * path = [NSString stringWithFormat:@"%@/%@", createPath ,lrcName];
    
    
//    // 判断文件夹是否存在，如果不存在，则创建
//    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath
//    
//    //2.获取歌词
    NSString * lrcStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    // NSLog(@"%@",lrcStr);
 
    //3.转化成歌词数组
    NSMutableArray * tempArray = [NSMutableArray array];
    NSArray *lrcArr = [lrcStr componentsSeparatedByString:@"\n"];
    
    for (NSString *lrcLineString in lrcArr) {
        
        // 4. 过滤不需要的字符串 [ti:]
        
        if ([lrcLineString hasPrefix:@"[ti:"] || [lrcLineString hasPrefix:@"[ar:"] || [lrcLineString hasPrefix:@"[al:"] || ![lrcLineString hasPrefix:@"["]) {
            continue;
        }
        // 5.将歌词转化成模型
        LrcLineModel *lrcLine = [LrcLineModel LineString:lrcLineString];
        
        [tempArray addObject:lrcLine];
        
    }
    // for (LrcLineModel *lrc in tempArray) {
    // NSLog(@"时间:%f   歌词 %@",lrc.timeVal,lrc.text);
    
    //  }
    return  tempArray;
    
    
    
    
    
    
}
@end
