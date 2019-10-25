//
//  DemoListVC.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "DemoListVC.h"
#import "DemoListCell.h"

#import "DemoZXTableViewPagingVC.h"
#import "DemoZXCollectionPagingVC.h"
@interface DemoListVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;

@end

@implementation DemoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ZXPagingScrollViewDemo";
    self.tableView.zx_setCellClassAtIndexPath = ^Class _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [DemoListCell class];
    };
    __weak typeof(self)weakSelf = self;
    self.tableView.zx_didSelectedAtIndexPath = ^(NSIndexPath * _Nonnull indexPath, NSString * _Nonnull model, id  _Nonnull cell) {
        UIViewController *vc;
        if([model isEqualToString:@"TableView中的分页Demo"]){
            vc = [[DemoZXTableViewPagingVC alloc]init];
        }else if([model isEqualToString:@"CollectionView中的分页Demo"]){
            vc = [[DemoZXCollectionPagingVC alloc]init];
        }
        if(vc){
            vc.title = model;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    };
    self.tableView.zxDatas = [@[@"TableView中的分页Demo",@"CollectionView中的分页Demo"] mutableCopy];
}



@end
