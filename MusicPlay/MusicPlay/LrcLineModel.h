//
//  LrcLineModel.h
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LrcLineModel : NSObject

@property(nonatomic,copy) NSString *text;

@property(nonatomic,assign) NSTimeInterval timeVal;


-(instancetype)initWithLrcLineString:(NSString *)lrcLineString;

+(instancetype)LineString:(NSString *)lrcLineString;

@end
