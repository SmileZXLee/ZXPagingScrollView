//
//  DemoZXCollectionPagingVC.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/25.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "DemoZXCollectionPagingVC.h"

#import "TestCollectionViewCell.h"
#import "TestModel.h"
#warning ZXPaging配置与tableView完全相同，注意信息可查阅DemoZXTableViewPagingVC控制器
@interface DemoZXCollectionPagingVC ()
@property (weak, nonatomic) IBOutlet ZXCollectionView *collectionView;
@end

@implementation DemoZXCollectionPagingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark 初始化UI
- (void)setupUI{
    self.title = [self.title stringByAppendingString:@"[共33条数据]"];
    [self setupCollectionView];
    [self setupPaging];
    
    //显示Loading
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}

#pragma mark 初始化分页效果
- (void)setupPaging{
    //1.为self.tableView添加分页效果，此方法会自动调用[self requestTableViewData]
    [self.collectionView zx_addDefaultPagingWithSel:@selector(requestTableViewData) pagingDatas:self.collectionView.zxDatas];
}

#pragma mark 初始化collectionView
- (void)setupCollectionView{
    self.collectionView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    //声明cell是什么类
    self.collectionView.zx_setCellClassAtIndexPath = ^Class _Nonnull(NSIndexPath * _Nullable indexPath) {
        return [TestCollectionViewCell class];
    };
    //快速创建（设置布局）
    ZXCVFastModel *fastModel = [[ZXCVFastModel alloc]init];
    ///设置ZXCollectionView显示3列
    fastModel.colCount = 3;
    //设置ZXCollectionView中cell的高度为宽度+30
    fastModel.itemHConstant = 30;
    //设置ZXCollectionView内容宽度，若不设置默认为ZXCollectionView.frame.size.width
    fastModel.superW = [UIScreen mainScreen].bounds.size.width;
    //设置布局模型
    [self.collectionView zx_fastWithModel:fastModel];
    
}

#pragma mark 网络请求
- (void)requestTableViewData{
    NSNumber *pageNo = self.collectionView.zx_pageNoNumber;
    NSNumber *pageCount = self.collectionView.zx_pageCountNumber;
    [HttpRequest reqLocalDtatWithParam:@{@"pageNo":pageNo,@"pageCount":pageCount} resultBlock:^(BOOL result, id  _Nonnull backData) {
        //隐藏loading
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //字典转模型
        NSArray *backModelDatas = [TestModel zx_modelWithObj:backData];
        //2.刷新ZXPaging分页请求结果
        [self.collectionView zx_requestResult:result resultArray:backModelDatas];
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
