//
//  DemoZXTableViewPagingVC.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "DemoZXTableViewPagingVC.h"

#import "TestCell.h"
#import "TestModel.h"

#warning 此Demo示范了TableView情况下如何使用ZXPaging:
#warning 1.在viewDidload中调用tableView的zx_addDefaultPagingWithSel进行分页必要信息的配置；
#warning 2.在网络请求结束的回调中调用tableView的zx_requestResult进行回调结果的更新即可
#warning 3.请求参数的PageNo和PageCount，ZXPaging会自动管理，通过self.tableView.zx_pageNoNumber和self.tableView.zx_pageCountNumber获取即可
#warning 系统的UITableView使用与ZXTableView分页配置完全相同，ZXPaging进阶配置请查看github上面的ReadMe

@interface DemoZXTableViewPagingVC ()
@property (weak, nonatomic) IBOutlet ZXTableView *tableView;

@end

@implementation DemoZXTableViewPagingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
#pragma mark 初始化UI
- (void)setupUI{
    self.title = [self.title stringByAppendingString:@"[共33条数据]"];
    //初始化tableView
    [self setupTableView];
    //初始化分页效果
    [self setupPaging];
    
    //显示Loading
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}

#pragma mark 初始化tableView
- (void)setupTableView{
    //设置tableView显示的cell
    self.tableView.zx_setCellClassAtIndexPath = ^Class _Nonnull(NSIndexPath * _Nonnull indexPath) {
        return [TestCell class];
    };
    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
}

#pragma mark 初始化分页效果
- (void)setupPaging{
    //1.为self.tableView添加分页效果，此方法会自动调用[self requestTableViewData]
    [self.tableView zx_addDefaultPagingWithSel:@selector(requestTableViewData) pagingDatas:self.tableView.zxDatas];
    
}

#pragma mark 网络请求
- (void)requestTableViewData{
    NSNumber *pageNo = self.tableView.zx_pageNoNumber;
    NSNumber *pageCount = self.tableView.zx_pageCountNumber;
    [HttpRequest reqLocalDtatWithParam:@{@"pageNo":pageNo,@"pageCount":pageCount} resultBlock:^(BOOL result, id  _Nonnull backData) {
        //隐藏loading
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //字典转模型
        NSArray *backModelDatas = [TestModel zx_modelWithObj:backData];
        //2.刷新ZXPaging分页请求结果
        [self.tableView zx_requestResult:result resultArray:backModelDatas];
        if(result){
            //请求成功
            
        }else{
            //请求失败
        }
    }];
}


- (void)dealloc{
    NSLog(@"dealloc");
}
@end
