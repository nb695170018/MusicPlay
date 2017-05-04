//
//  LrcLabel.m
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import "LrcLabel.h"

@implementation LrcLabel
-(void)setProgress:(CGFloat)progress
{
    _progress = progress;
  //  NSLog(@"progress---->%f",progress);
    [self setNeedsDisplay];
    
    
}
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    // 1.
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width * self.progress , self.bounds.size.height);
    
    [[UIColor cyanColor]set];
    
   // UIRectFill(fillRect);
    
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
    
    
}

@end
