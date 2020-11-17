# ZXPagingScrollView
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/SmileZXLee/ZXPagingScrollView/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/ZXPagingScrollView.svg?style=flat)](http://cocoapods.org/?q=ZXPagingScrollView)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/ZXPagingScrollView.svg?style=flat)](http://cocoapods.org/?q=ZXPagingScrollView)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%208.0%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
## 安装
### 通过CocoaPods安装
```ruby
pod 'ZXPagingScrollView'
```
### 手动导入
* 将ZXPagingScrollView拖入项目中。

### 导入头文件
```objective-c
#import "UIScrollView+ZXPaging.h"
```
## 基础使用(tableView与collectionView相同，此处以tableView为例)
### 在控制器viewDidLoad中初始化ZXPaging，设置分页下拉刷新与上拉加载更多的回调函数，并设置分页的数据源(也就是tableView的数据源数组)
* 添加默认的ZXPaging(target默认是当前控制器)(默认MJHeader为MJRefreshNormalHeader，MJFooter为MJRefreshBackNormalFooter【加载结束看不到MJFooter】)
```objective-c
[self.tableView zx_addDefaultPagingWithSel:@selector(requestTableViewData) pagingDatas:self.datasAttar];
```
### 在网络请求结束后，更新ZXPaging的状态，设置当前是否加载成功，与服务器返回的数组(先字典转模型一下，pageNo和pageCount的值ZXPaging会自动管理)
```objective-c
- (void)requestTableViewData{
    //获取当前的pageNo
    NSNumber *pageNo = self.tableView.zx_pageNoNumber;
    //获取当前的pageCount
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
```
### 至此，一个基础的分页效果已经完成
### 查看效果
<img src="https://img-blog.csdnimg.cn/20191025144212386.gif"/>

***

## 使用进阶
### 注：以下配置可以统一写在Base控制器中，不需要每个控制器都更改
### 更改默认的PageNo
* pageNo默认从0开始，若要更改初始的pageNo，请在zx_addDefaultPaging之前设置
```objective-c
//设置pageNo从1开始
self.tableView.zx_pageNo = 1;
```
### 更改默认的PageCount
* pageCount默认为10，若要更改初始的pageCount，请在zx_addDefaultPaging之前设置
```objective-c
//设置pageCount为20
self.tableView.zx_pageCount = 20;
```
### 更改MJFooter没有更多数据时显示的文字内容
```objective-c
self.tableView.zx_noMoreStr = @"亲，没有更多数据啦~";
```
### 更改MJHeader或MJFooter样式
* MJHeader默认为MJRefreshNormalHeader，MJFooter默认为MJRefreshBackNormalFooter(加载结束看不到MJFooter)
* 若需要的样式在上述范围内，则可以直接更改self.tableView.mj_header...来更改对应样式
* 请在zx_addDefaultPaging之后设置(因为zx_addDefaultPaging会自动添加self.tableView.mj_header)，如
```objective-c
//隐藏上次加载时间
((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
```
* 若您需要设置的样式不在默认的样式之中，则需要使用zx_addCustomPagingWithSel进行分页的初始化设置
* 例如，要实现一个gif效果的MJHeader
[header setImages:idleImages forState:MJRefreshStateIdle];
* 使用[self.tableView zx_addCustomPagingWithSel...]代替原来的[self.tableView zx_addDefaultPagingWithSel...]初始化方法，并设置需要自定义的MJHeader或MJFooter的类(传nil则为默认的)
```objective-c
[self.tableView zx_addCustomPagingWithSel:@selector(requestTableViewData) customMJHeaderClass:[MJRefreshGifHeader class] customMJFooterClass:nil pagingDatas:self.datasAttar];
```
### MJHeader或MJFooter刷新的回调
* ZXPaging会自动实现二者的刷新回调并进行对应的分页逻辑处理
* 若您需要这二者的回调进行一些分页之外的操作，请勿直接通过MJRefresh自带的刷新block，否则会导致分页逻辑异常
* 若需要获取MJHeader或MJFooter的刷新回调(此处以MJHeader为例)
```objective-c
self.tableView.zx_mjHeaderRefreshingBlock = ^{
    NSLog(@"触发了下拉刷新");
};
```
### 根据请求结果刷新完毕tableView/collectionView之后的回调
* 刷新tableView/collectionView的MJFooter状态之后，ZXPaging提供了对应的回调，以便您根据刷新的结果进行额外的处理
```objective-c
self.tableView.zx_didUpdateScrollViewStatusBlock = ^(ZXDidUpdateScrollViewStatus didUpdateScrollViewStatus) {
    if(didUpdateScrollViewStatus == ZXDidUpdateScrollViewStatusHasMoreData){
        //刷新结果为还有更多的数据
    }else if(didUpdateScrollViewStatus == ZXDidUpdateScrollViewStatusNoMoreData){
        //刷新结果为没有更多的数据
    }else if(didUpdateScrollViewStatus == ZXDidUpdateScrollViewStatusFailed){
        //刷新结果为请求失败
    }
};
```
### MJFooter为MJRefreshAutoNormalFooter情况下，若当前页面为第一页，则自动隐藏MJFooter，非第一页显示MJFooter，默认为NO
```objective-c
//第一页的时候自动隐藏MJFooter(MJRefreshAutoNormalFooter情况下生效)
self.tableView.zx_autoHideMJFooterInGroup = YES;
```
