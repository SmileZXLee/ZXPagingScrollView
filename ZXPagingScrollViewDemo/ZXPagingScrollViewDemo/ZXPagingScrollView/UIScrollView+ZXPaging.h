//
//  UIScrollView+ZXPaging.h
//  ZXPagingScrollView
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//  https://github.com/SmileZXLee/ZXPagingScrollView

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#define ZXPagingWeakSelf(obj) autoreleasepool{} __weak typeof(obj) o##Weak = obj;
#define ZXPagingStrongSelf(obj) autoreleasepool{} __strong typeof(obj) obj = o##Weak;
NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ZXDidUpdateScrollViewStatus) {
    ///加载结束刷新后还有更多数据
    ZXDidUpdateScrollViewStatusHasMoreData = 0,
    ///加载结束刷新后没有更多数据
    ZXDidUpdateScrollViewStatusNoMoreData,
    ///加载失败
    ZXDidUpdateScrollViewStatusFailed
};

typedef void(^zx_mjHeaderBlock) (void);
typedef void(^zx_mjFooterBlock) (void);
@interface UIScrollView (ZXPaging)

/**
 分页的No(从第几页开始)(默认为0)
 */
@property(assign, nonatomic, readonly)NSUInteger zx_pageNo;

/**
 分页的No(从第几页开始)(默认为0)[Number类型，方便直接放到请求的字典中]
 */
@property(strong, nonatomic, readonly)NSNumber *zx_pageNoNumber;

/**
 设置默认分页的No(从第几页开始)(默认为0)(仅需设置一次，可以在项目加载时通过[UIScrollView new].zx_defaultPageNo设置)
 */
@property(assign, nonatomic)NSUInteger zx_defaultPageNo;

/**
 分页的Count(每页显示多少条数据)(默认为10)(仅需设置一次)
 */
@property(assign, nonatomic, readonly)NSUInteger zx_pageCount;

/**
 分页的Count(每页显示多少条数据)(默认为10)[Number类型，方便直接放到请求的字典中]
 */
@property(strong, nonatomic, readonly)NSNumber *zx_pageCountNumber;

/**
 设置默认分页的Count(每页显示多少条数据)(默认为10)(仅需设置一次，可以在项目加载时通过[UIScrollView new].zx_defaultPageCount设置)
 */
@property(assign, nonatomic)NSUInteger zx_defaultPageCount;

/**
 MJFooter没有更多数据时显示的文字
 */
@property(copy, nonatomic)NSString *zx_noMoreStr;

/**
 MJFooter没有更多数据时显示的默认文字(仅需设置一次，可以在项目加载时通过[UIScrollView new].zx_defaultNoMoreStr设置)
 */
@property(copy, nonatomic, nullable)NSString *zx_defaultNoMoreStr;

/**
 分页请求的数据源数组，不要使用数组的copy方法给它赋值，以便ZXPaging自动修改原数据源数组
 */
@property(strong, nonatomic)NSMutableArray *zx_pageDatas;

/**
 addPaing时，禁止同时调用数据请求函数
 */
@property(assign, nonatomic)BOOL zx_disbaleAutoCallWhenAddingPaging;


/**
 是否是MJHeader触发的请求(一般用不到)
 */
@property(assign, nonatomic, readonly)BOOL zx_isMJHeaderRef;


/**
 MJHeader下拉刷新回调(若需要在下拉刷新时额外处理，请使用此回调，勿使用MJRefresh自带的block，否则会导致ZXPaging下拉刷新回调失效)
 */
@property(copy, nonatomic)void (^zx_mjHeaderRefreshingBlock)(void);

/**
 MJFooter下拉刷新回调(若需要在下拉刷新时额外处理，请使用此回调，勿使用MJRefresh自带的block，否则会导致ZXPaging下拉刷新回调失效)
 */
@property(copy, nonatomic)void (^zx_mjFooterRefreshingBlock)(void);


/**
 根据请求结果刷新完毕tableView/collectionView之后的回调
 */
@property(copy, nonatomic)void (^zx_didUpdateScrollViewStatusBlock)(ZXDidUpdateScrollViewStatus didUpdateScrollViewStatus);

/**
 MJFooter为MJRefreshAutoNormalFooter情况下，若当前页面为第一页，则自动隐藏MJFooter，非第一页显示MJFooter，默认为NO
 */
@property(assign, nonatomic)BOOL zx_autoHideMJFooterInGroup;


/**
 添加默认的ZXPaging(默认MJHeader为MJRefreshNormalHeader，MJFooter为MJRefreshBackNormalFooter)

 @param target 下拉刷新或上拉加载更多调用方法的target
 @param sel 下拉刷新或上拉加载更多调用方法的selector
 */
- (void)zx_addDefaultPagingWithReqTarget:(id)target sel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas;


/**
 添加默认的ZXPaging(target默认是当前控制器)(默认MJHeader为MJRefreshNormalHeader，MJFooter为MJRefreshBackNormalFooter)

 @param sel 下拉刷新或上拉加载更多调用方法的selector
 */
- (void)zx_addDefaultPagingWithSel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas;

/**
 添加自定义的ZXPaging(当自定义MJHeader或MJFooter时使用)

 @param target 下拉刷新或上拉加载更多调用方法的target
 @param sel 下拉刷新或上拉加载更多调用方法的selector
 @param mjHeaderClass MJHeader的Class，传nil则为默认的MJRefreshNormalHeader
 @param mjFooterClass MJFooter的Class，传nil则为默认的MJRefreshBackNormalFooter
 */
- (void)zx_addCustomPagingWithReqTarget:(id)target sel:(SEL)sel customMJHeaderClass:(__nullable Class)mjHeaderClass customMJFooterClass:(__nullable Class)mjFooterClass pagingDatas:(NSMutableArray *)pagingDatas;


/**
 添加自定义的ZXPaging(当自定义MJHeader或MJFooter时使用)(target默认是当前控制器)

 @param sel 下拉刷新或上拉加载更多调用方法的selector
 @param mjHeaderClass MJHeader的Class，传nil则为默认的MJRefreshNormalHeader
 @param mjFooterClass MJFooter的Class，传nil则为默认的MJRefreshBackNormalFooter
 */
- (void)zx_addCustomPagingWithSel:(SEL)sel customMJHeaderClass:(__nullable Class)mjHeaderClass customMJFooterClass:(__nullable Class)mjFooterClass pagingDatas:(NSMutableArray *)pagingDatas;


/**
 请求完成调用此方法

 @param success 请求是否成功
 @param resultArray 请求完成后返回的数据(将自动赋值给zx_pageDatas，建议字典转模型之后再传进来)
 */
- (void)zx_requestResult:(BOOL)success resultArray:(NSArray *)resultArray;


/**
 结束MJHeaderView和MJFooter的刷新状态，且自动reloadData(一般用不到，zx_requestResult方法内部会自动调用，若其他地方需要使用可以调用)
 */
- (void)zx_endMJRef;

/**
 刷新paging(等同于下拉刷新)
 */
- (void)zx_reloadPaging;
@end

NS_ASSUME_NONNULL_END
