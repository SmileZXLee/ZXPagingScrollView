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
typedef NS_OPTIONS(NSUInteger, ZXMJFooterStyle) {
    ///加载结束看不到MJFooter
    ZXMJFooterStylePlain = 0,
    ///加载结束可以看到MJFooter和对应的提示文字
    ZXMJFooterStyleGroup
};

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
@property(assign, nonatomic)NSUInteger zx_pageNo;

/**
 分页的No(从第几页开始)(默认为0)[Number类型，方便直接放到请求的字典中]
 */
@property(strong, nonatomic ,readonly)NSNumber *zx_pageNoNumber;

/**
 分页的Count(每页显示多少条数据)(默认为10)
 */
@property(assign, nonatomic)NSUInteger zx_pageCount;

/**
 分页的Count(每页显示多少条数据)(默认为10)[Number类型，方便直接放到请求的字典中]
 */
@property(strong, nonatomic ,readonly)NSNumber *zx_pageCountNumber;

/**
 MJFooter没有更多数据时显示的文字，ZXMJFooterStyle == ZXMJFooterStyleGroup时有效
 */
@property(copy, nonatomic)NSString *zx_noMoreStr;

/**
 分页请求的数据源数组，不要使用数组的copy方法给它赋值，以便ZXPaging自动修改原数据源数组
 */
@property(strong, nonatomic)NSMutableArray *zx_pageDatas;

/**
 上一次加载的数据(一般用不到)
 */
@property(strong, nonatomic, readonly)NSMutableArray *zx_lastPageDatas;

/**
 MJFooter显示的样式
 */
@property(assign, nonatomic)ZXMJFooterStyle zx_mjFooterStyle;

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
 MJFooter为ZXMJFooterStyleGroup情况下，若当前页面为第一页，则自动隐藏MJFooter，非第一页显示MJFooter，默认为NO
 */
@property(assign, nonatomic)BOOL zx_autoHideMJFooterInGroup;


/**
 添加默认的ZXPaging

 @param target 下拉刷新或上拉加载更多调用方法的target
 @param sel 下拉刷新或上拉加载更多调用方法的selector
 */
- (void)zx_addDefaultPagingWithReqTarget:(id)target sel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas;


/**
 添加默认的ZXPaging(target默认是当前控制器)

 @param sel 下拉刷新或上拉加载更多调用方法的selector
 */
- (void)zx_addDefaultPagingWithSel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas;

/**
 添加自定义的ZXPaging(当自定义MJHeader或MJFooter时使用，请在这一行代码之前自定义MJHeader或MJFooter)

 @param target 下拉刷新或上拉加载更多调用方法的target
 @param sel 下拉刷新或上拉加载更多调用方法的selector
 @param isCustomHeader 是否自定义MJHeader
 @param isCustomFooter 是否自定义MJFooter
 */
- (void)zx_addCustomPagingWithReqTarget:(id)target sel:(SEL)sel isCustomHeader:(BOOL)isCustomHeader isCustomFooter:(BOOL)isCustomFooter pagingDatas:(NSMutableArray *)pagingDatas;


/**
 添加自定义的ZXPaging(当自定义MJHeader或MJFooter时使用，请在这一行代码之前自定义MJHeader或MJFooter)(target默认是当前控制器)

 @param sel 下拉刷新或上拉加载更多调用方法的selector
 @param isCustomHeader 是否自定义MJHeader
 @param isCustomFooter 是否自定义MJFooter
 */
- (void)zx_addCustomPagingWithSel:(SEL)sel isCustomHeader:(BOOL)isCustomHeader isCustomFooter:(BOOL)isCustomFooter pagingDatas:(NSMutableArray *)pagingDatas;


/**
 请求完成调用此方法

 @param success 请求是否成功
 @param resultArray 请求完成后返回的数据(将自动赋值给zx_pageDatas，建议字典转模型之后再传进来)
 */
- (void)zx_requestResult:(BOOL)success resultArray:(NSArray *)resultArray;


/**
 结束MJHeaderView和MJFooter的刷新状态，且自动reloadData(一般用不到，需要的时候可以调用)
 */
- (void)zx_endMJRef;
@end

NS_ASSUME_NONNULL_END
