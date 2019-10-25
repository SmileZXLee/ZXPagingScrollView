//
//  TestCollectionViewCell.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/25.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "TestCollectionViewCell.h"
#import "TestModel.h"
@interface TestCollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *testTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *testDetailLabel;
@property (strong, nonatomic) TestModel *testModel;
@end
@implementation TestCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setTestModel:(TestModel *)testModel{
    _testModel = testModel;
    self.testTitleLabel.text = testModel.title;
    self.testDetailLabel.text = testModel.msg;
}

@end
