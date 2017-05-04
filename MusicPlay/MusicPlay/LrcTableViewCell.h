//
//  LrcTableViewCell.h
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LrcLabel;
@interface LrcTableViewCell : UITableViewCell

+(instancetype)lrcCellWithTableView:(UITableView *)tableView;


@property(nonatomic,weak)LrcLabel *lrcLabel;
@end
