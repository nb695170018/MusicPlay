//
//  LrcTableViewCell.m
//  MusicPlayDemo
//
//  Created by 孙亚锋 on 2017/3/25.
//  Copyright © 2017年 yafeng.sun. All rights reserved.
//

#import "LrcTableViewCell.h"
#import "LrcLabel.h"
#import "Masonry.h"
@implementation LrcTableViewCell
+(instancetype)lrcCellWithTableView:(UITableView *)tableView
{
 
  static NSString *ID = @"cell";
    LrcTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[LrcTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
       return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        LrcLabel *lrcLabel = [[LrcLabel alloc]init];
        lrcLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:lrcLabel];
        
        self.lrcLabel = lrcLabel;
        
        //2. 添加约束
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
        }];
        
        // 3.设置基本数据
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        lrcLabel.textColor = [UIColor whiteColor];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        lrcLabel.font = [UIFont systemFontOfSize:14.0f];
     }
    return self;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
