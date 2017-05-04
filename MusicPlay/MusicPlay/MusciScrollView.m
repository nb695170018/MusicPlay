//
//  MusciScrollView.m
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import "MusciScrollView.h"
#import "Masonry.h"
#import "LrcTableViewCell.h"
#import "MusicLrcNameTool.h"
#import "LrcLineModel.h"
#import "LrcLabel.h"
#import "XZAllMusicModel.h"
#import <MediaPlayer/MediaPlayer.h>
@interface MusciScrollView()<UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
/*歌词数组*/
@property(nonatomic,strong)NSArray *lrcListArray;

/** 记录当前刷新的某航 索引值*/
@property(nonatomic,assign) NSInteger currentIndex;
@end
@implementation MusciScrollView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        //初始化tableview
        [self setupTableView];
        
        
    }
    return self;
    
}
-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTableView];
    }
    return self;
}
-(void)setupTableView
{
    // 1 初始化tableview
    UITableView *tableView = [[UITableView alloc]init];
    
    [self addSubview:tableView];
    self.tableView = tableView;
    
    tableView.dataSource = self;
    

    
    
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    // 1. 添加约束
   self.  tableView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left).offset(0);
        make.width.equalTo(self.mas_width);
        
    }];
    // 2.改变背景色
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 40;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tableView.bounds.size.height *0.5, 0);
    
    
}
#pragma mark - tableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
     return self.lrcListArray.count;
  
  
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LrcTableViewCell * cell = [LrcTableViewCell lrcCellWithTableView:tableView];
    
    if (self.currentIndex == indexPath.row) {
        
        cell.lrcLabel.font = [UIFont systemFontOfSize:16.0f];

    }else{
        cell.lrcLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.lrcLabel.progress = 0;
       

    }
    
    LrcLineModel * model = self.lrcListArray[indexPath.row];
    
    cell.lrcLabel.text = model.text;
    
    
    return cell;
    
    
}

#pragma mark - 重写歌曲名
-(void)setLrcName:(NSString *)lrcName{
    // -1 将table滚动到中间
    [self.tableView setContentOffset:CGPointMake(0,-(self.tableView.bounds.size.height *0.5))];
    
    //0. 将当前索引设为0
    self.currentIndex = 0;
    
    //.1 记录歌词名
    _lrcName = [_lrcName copy];
    
    // 2 解析歌词
    self.lrcListArray = [MusicLrcNameTool lrcToolWithMusicName:lrcName];
    //2.1设置第一句歌词
    
    LrcLineModel *firstLrcLine = self.lrcListArray[0];
    self.lrcLab.text = firstLrcLine.text;
    self.lrcLab.font = [UIFont systemFontOfSize:16];
    
    // 3. 刷新表
    [self.tableView reloadData];
    
    
}
#pragma mark - 重写当前时间
-(void)setCurrentTime:(NSTimeInterval)currentTime
{
    
  
    // 1.记录当前的播放时间
    _currentTime = currentTime;
    
    // 2. 判断显示哪句歌词
    NSInteger count = self.lrcListArray.count;
    
    for (NSInteger i = 0; i< count; i++) {
        //2.1 取出当前歌词
        LrcLineModel *currentLine = self.lrcListArray[i];
        //2.2 取出下一句歌词
        NSInteger nextIndex = i+1;
        LrcLineModel *nextModel = nil;
        if (nextIndex < self.lrcListArray.count) {
            
            nextModel = self.lrcListArray[nextIndex];
            
        }
        // 2.3 用当前播放器的时间,跟当前这句歌词和一下句歌词的时间 进行对比,如果大于等于当前歌词的时间.并且小于 下一句 歌词的时间 , 就 显示 当前的歌词
        if(self.currentIndex != i && currentTime >= currentLine.timeVal && currentTime < nextModel.timeVal){
            
            //1.将当前的这句歌词滚动到 中间
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            //2.记录当前刷新的某行
            self.currentIndex = i ;
            //3 .刷新当前这句歌词,并且刷新上一句歌词
            [self.tableView reloadRowsAtIndexPaths:@[indexPath,previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            //4将当前的这句歌词滚动到中间
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            // 5.设置主界面歌词的文字
            self.lrcLab.text = currentLine.text;
                       
        }
        
        //当前这句歌词
        if (self.currentIndex == i) {
            
            //1. 用当前播放器的时间  减去   当前歌词的时间除以（下一句歌词的时间-当前歌词的时间）
            CGFloat value = (currentTime - currentLine.timeVal) / (nextModel.timeVal - currentLine.timeVal);
            //2. 设置当前歌词播放的进度
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0]    ;
            LrcTableViewCell *lrcCell = [self.tableView cellForRowAtIndexPath:indexPath];
            lrcCell.lrcLabel.progress = value;
            self.lrcLab.progress =value;
            
        }
        
        
    }
    
}






@end
