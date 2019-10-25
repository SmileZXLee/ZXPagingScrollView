//
//  TestCell.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "TestCell.h"
#import "TestModel.h"
@interface TestCell()
@property (weak, nonatomic) IBOutlet UILabel *testTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *testDetailLabel;
@property (strong, nonatomic) TestModel *testModel;
@end
@implementation TestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTestModel:(TestModel *)testModel{
    _testModel = testModel;
    self.testTitleLabel.text = testModel.title;
    self.testDetailLabel.text = testModel.msg;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
