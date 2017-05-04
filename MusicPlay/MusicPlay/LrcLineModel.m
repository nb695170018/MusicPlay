//
//  LrcLineModel.m
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import "LrcLineModel.h"

@implementation LrcLineModel
-(instancetype)initWithLrcLineString:(NSString *)lrcLineString
{
    self = [super init];
    
    if (self) {
       // [01:17.44]想你时你在脑海
        
        NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];
        self.text    = lrcArray[1];
        
        self.timeVal = [self timeWithString:[lrcArray[0]substringFromIndex:1]];
        
        
        
    }
    return self;
}

+(instancetype)LineString:(NSString *)lrcLineString
{
    return [[self alloc]initWithLrcLineString:lrcLineString];
    
}

-(NSTimeInterval )timeWithString:(NSString *)timeString{
    
   // 01:17.44
  
    NSInteger min = [[timeString componentsSeparatedByString:@":"][0]integerValue];
    
    NSInteger sec = [[timeString substringWithRange:NSMakeRange(3,2)]integerValue];
    
    NSInteger hs =  [[timeString componentsSeparatedByString:@"."][1]integerValue];
    
    
    
    return min*60 + sec + hs*0.01;
}





@end
