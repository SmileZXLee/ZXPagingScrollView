//
//  DemoListCell.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "DemoListCell.h"
@interface DemoListCell()
@property(copy, nonatomic)NSString *demoListModel;
@end
@implementation DemoListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDemoListModel:(NSString *)demoListModel{
    _demoListModel = demoListModel;
    self.textLabel.text = demoListModel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
