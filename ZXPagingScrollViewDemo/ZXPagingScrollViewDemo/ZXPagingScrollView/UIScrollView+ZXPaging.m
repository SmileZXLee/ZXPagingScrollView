//
//  UIScrollView+ZXPaging.m
//  ZXPagingScrollView
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//  https://github.com/SmileZXLee/ZXPagingScrollView

#import "UIScrollView+ZXPaging.h"
#import "MJRefresh.h"
#import <objc/runtime.h>
static int defaultPageNo = -1;
static int defaultPageCount = -1;
static NSString *defaultNoMoreStr = nil;
static NSString *zx_pageNoKey = @"zx_pageNoKey";
static NSString *zx_pageCountKey = @"zx_pageCountKey";
static NSString *zx_noMoreStrKey = @"zx_noMoreStrKey";
static NSString *zx_disbaleAutoCallWhenAddingPagingKey = @"zx_disbaleAutoCallWhenAddingPagingKey";
static NSString *zx_pageDatasKey = @"zx_pageDatasKey";
static NSString *zx_lastPageDatasKey = @"zx_lastPageDatasKey";
static NSString *zx_lastAddedPageDatasKey = @"zx_lastAddedPageDatas";
static NSString *zx_lastPageNoKey = @"zx_lastPageNoKey";
static NSString *zx_isMJHeaderRefKey = @"zx_isMJHeaderRefKey";
static NSString *zx_mjHeaderRefreshingBlockKey = @"zx_mjHeaderRefreshingBlockKey";
static NSString *zx_mjFooterRefreshingBlockKey = @"zx_mjFooterRefreshingBlockKey";
static NSString *zx_didUpdateScrollViewStatusBlockKey = @"zx_didUpdateScrollViewStatusBlockKey";
static NSString *zx_autoHideMJFooterInGroupKey = @"zx_autoHideMJFooterInGroupKey";
@interface UIScrollView (ZXPaging)
/**
 上一次加载的数据
 */
@property(strong, nonatomic)NSMutableArray *zx_lastPageDatas;

/**
 上一次添加的数据
 */
@property(strong, nonatomic)NSMutableArray *zx_lastAddedPageDatas;

/**
 上一次的pageNo
 */
@property(assign, nonatomic)NSUInteger zx_lastPageNo;

@end
@implementation UIScrollView (ZXPaging)
#pragma mark - Public
#pragma mark 添加默认的ZXPaging
- (void)zx_addDefaultPagingWithReqTarget:(id)target sel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas{
    if(defaultNoMoreStr){
        self.zx_noMoreStr = defaultNoMoreStr;
    }
    self.zx_pageDatas = pagingDatas;
    if(!self.zx_disbaleAutoCallWhenAddingPaging){
        [self zx_performSelWithTarget:target sel:sel];
    }
    __weak typeof(target)weakTarget = target;
    __weak typeof(self)weakSelf = self;
    [self addDefaultMJHeader:^{
        [weakSelf zx_performSelWithTarget:weakTarget sel:sel];
    }];
    [self addDefaultMJFooter:^{
        [weakSelf zx_performSelWithTarget:weakTarget sel:sel];
    }];
    self.mj_footer.hidden = YES;
}

#pragma mark 添加默认的ZXPaging(通过block方式)
- (void)zx_addDefaultPagingWithBlock:(void (^)(void))callback pagingDatas:(NSMutableArray *)pagingDatas{
    if(defaultNoMoreStr){
        self.zx_noMoreStr = defaultNoMoreStr;
    }
    self.zx_pageDatas = pagingDatas;
    if(!self.zx_disbaleAutoCallWhenAddingPaging){
        !callback ? : callback();
    }
    [self addDefaultMJHeader:^{
        !callback ? : callback();
    }];
    [self addDefaultMJFooter:^{
        !callback ? : callback();
    }];
    self.mj_footer.hidden = YES;
}

#pragma mark 添加默认的ZXPaging
- (void)zx_addDefaultPagingWithSel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas{
    self.zx_pageDatas = pagingDatas;
    [self zx_addDefaultPagingWithReqTarget:[self zx_pagingGetCurrentVc] sel:sel pagingDatas:pagingDatas];
}

#pragma mark 添加自定义的ZXPaging
- (void)zx_addCustomPagingWithReqTarget:(id)target sel:(SEL)sel customMJHeaderClass:(__nullable Class)mjHeaderClass customMJFooterClass:(__nullable Class)mjFooterClass pagingDatas:(NSMutableArray *)pagingDatas{
    self.zx_pageDatas = pagingDatas;
    if(!self.zx_disbaleAutoCallWhenAddingPaging){
        [self zx_performSelWithTarget:target sel:sel];
    }
    __weak typeof(target)weakTarget = target;
    __weak typeof(self)weakSelf = self;
    
    if(!mjHeaderClass){
        [self addDefaultMJHeader:^{
            [weakSelf zx_performSelWithTarget:weakTarget sel:sel];
        }];
    }else{
        [self addCustomMJHeader:mjHeaderClass callBack:^{
            [weakSelf zx_performSelWithTarget:weakTarget sel:sel];
        }];
    }
    if(!mjFooterClass){
        [self addDefaultMJFooter:^{
            [weakSelf zx_performSelWithTarget:weakTarget sel:sel];
        }];
    }else{
        [self addCustomMJFooter:mjFooterClass callBack:^{
            [weakSelf zx_performSelWithTarget:weakTarget sel:sel];
        }];
    }
    self.mj_footer.hidden = YES;
}

#pragma mark 添加自定义的ZXPaging
- (void)zx_addCustomPagingWithSel:(SEL)sel customMJHeaderClass:(__nullable Class)mjHeaderClass customMJFooterClass:(__nullable Class)mjFooterClass pagingDatas:(NSMutableArray *)pagingDatas{
    [self zx_addCustomPagingWithReqTarget:[self zx_pagingGetCurrentVc] sel:sel customMJHeaderClass:mjHeaderClass customMJFooterClass:mjFooterClass pagingDatas:pagingDatas];
}

#pragma mark 结束MJHeaderView和MJFooter的刷新状态，且自动reloadData
- (void)zx_endMJRef{
    if([self respondsToSelector:@selector(reloadData)]){
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
    }
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

#pragma mark 刷新paging(等同于下拉刷新)
- (void)zx_reloadPaging{
    if(self.mj_header && self.mj_header.refreshingBlock){
        self.mj_header.refreshingBlock();
    }
}

#pragma mark 请求完成调用此方法
- (void)zx_requestResult:(BOOL)success resultArray:(NSArray *)resultArray{
    if(!self.zx_pageDatas){
        self.zx_pageDatas = [NSMutableArray array];
    }
    if(self.zx_pageNo == [self getFinalPageNo]){
        [self.zx_pageDatas removeAllObjects];
        if(success){
            [self.zx_pageDatas addObjectsFromArray:resultArray];
        }
    }else{
        if(self.zx_pageNo == self.zx_lastPageNo){
            if(success){
                long loc = self.zx_pageNo - (defaultPageNo == -1 ? 0 : defaultPageNo);
                long count = resultArray.count;
                if(count && self.zx_pageDatas.count && loc + count <= self.zx_pageDatas.count){
                    [self.zx_pageDatas replaceObjectsInRange:NSMakeRange((self.zx_pageNo - (defaultPageNo == -1 ? 0 : defaultPageNo)) * self.zx_pageCount, resultArray.count) withObjectsFromArray:resultArray];
                }
            }
        }else{
            self.zx_lastPageNo = self.zx_pageNo;
            if(success){
                [self.zx_pageDatas addObjectsFromArray:resultArray];
            }
            
        }
    }
    if(success){
        [self setValue:resultArray forKey:@"zx_lastAddedPageDatas"];
    }
    [self updateScrollViewStatus:success];
    [self zx_endMJRef];
}

#pragma mark - Private
#pragma mark 设置MJFooter

#pragma mark 添加默认的MJHeader
- (void)addDefaultMJHeader:(zx_mjHeaderBlock)block{
    __weak typeof(self)weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf zx_handleMJHeaderRefresh];
        block();
    }];
    self.mj_header = header;
}

#pragma mark 添加自定义的MJHeader
- (void)addCustomMJHeader:(Class)headerClass callBack:(zx_mjHeaderBlock)block{
    __weak typeof(self)weakSelf = self;
    if(![headerClass respondsToSelector:@selector(headerWithRefreshingBlock:)]){
        NSAssert(NO, @"MJHeader的class错误，请检查customMJHeaderClass！");
        return;
    }
    MJRefreshHeader *header = [headerClass headerWithRefreshingBlock:^{
        [weakSelf zx_handleMJHeaderRefresh];
        block();
    }];
    self.mj_header = header;
}

#pragma mark 添加默认的MJFooter
- (void)addDefaultMJFooter:(zx_mjFooterBlock)block{
    __weak typeof(self)weakSelf = self;
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf zx_handleMjFooterRefresh];
        block();
    }];
    if(self.zx_noMoreStr.length){
        MJRefreshBackNormalFooter *foot = (MJRefreshBackNormalFooter *)footer;
        if([foot respondsToSelector:@selector(setTitle:forState:)]){
            [foot setTitle:self.zx_noMoreStr forState:MJRefreshStateNoMoreData];
        }
    }
    self.mj_footer = footer;
}

#pragma mark 添加自定义的MJFooter
- (void)addCustomMJFooter:(Class)footerClass callBack:(zx_mjHeaderBlock)block{
    __weak typeof(self)weakSelf = self;
    if(![footerClass respondsToSelector:@selector(footerWithRefreshingBlock:)]){
        NSAssert(NO, @"MJFooter的class错误，请检查customMJFooterClass！");
        return;
    }
    MJRefreshFooter *footer = [footerClass footerWithRefreshingBlock:^{
        [weakSelf zx_handleMjFooterRefresh];
        block();
    }];
    self.mj_footer = footer;
}

#pragma mark MJHeader刷新后的处理
- (void)zx_handleMJHeaderRefresh{
    [self setValue:@1 forKey:@"zx_isMJHeaderRef"];
    if(self.zx_pageDatas.count % self.zx_pageCount){
        self.mj_footer.state = MJRefreshStateNoMoreData;
    }
    [self.zx_pageDatas removeAllObjects];
    self.zx_pageNo = [self getFinalPageNo];
    self.zx_lastPageNo = self.zx_pageNo;
    if(self.zx_mjHeaderRefreshingBlock){
        self.zx_mjHeaderRefreshingBlock();
    }
}

#pragma mark MJFooter刷新后的处理
- (void)zx_handleMjFooterRefresh{
    [self setValue:@0 forKey:@"zx_isMJHeaderRef"];
    self.zx_pageNo++;
    if(self.zx_mjFooterRefreshingBlock){
        self.zx_mjFooterRefreshingBlock();
    }
}


#pragma mark 刷新tableView/collectionView状态
-(void)updateScrollViewStatus:(BOOL)status{
    [self zx_endMJRef];
    self.mj_header.hidden = NO;
    if([self.mj_footer
        respondsToSelector:@selector(arrowView)]){
        [self.mj_footer setValue:@1 forKeyPath:@"arrowView.alpha"];
    }
    ZXDidUpdateScrollViewStatus didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusHasMoreData;
    if(status){
        if(!self.zx_pageDatas.count){
            self.mj_footer.hidden = YES;
            didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusNoMoreData;
        }else{
            self.mj_footer.hidden = NO;
            if(!self.zx_lastAddedPageDatas.count || self.zx_pageDatas.count % self.zx_pageCount || (self.zx_lastPageDatas && self.zx_lastPageDatas.count == self.zx_pageDatas.count  && self.zx_lastPageDatas.count != self.zx_pageCount)){
                [self judgeHideMjFooterView];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.mj_footer.state = MJRefreshStateNoMoreData;
                    if([self.mj_footer
                        respondsToSelector:@selector(arrowView)]){
                        [self.mj_footer setValue:@0 forKeyPath:@"arrowView.alpha"];
                    }
                });
                didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusNoMoreData;
            }else{
                [self judgeHideMjFooterView];
            }
        }
        if(!self.zx_isMJHeaderRef && !(self.zx_pageNo == self.zx_lastPageNo)){
            [self setValue:[self.zx_pageDatas mutableCopy] forKey:@"zx_lastPageDatas"];
        }
    }else{
        if(!self.zx_pageDatas.count){
            self.mj_footer.hidden = YES;
        }
        if(self.zx_pageNo > [self getFinalPageNo]){
            self.zx_pageNo--;
            self.zx_lastPageNo--;
            [self.zx_lastPageDatas removeAllObjects];
        }
        didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusFailed;
    }
    if(self.zx_didUpdateScrollViewStatusBlock){
        self.zx_didUpdateScrollViewStatusBlock(didUpdateScrollViewStatus);
    }
}

#pragma mark 获取最终的pageNo
- (NSUInteger)getFinalPageNo{
    return defaultPageNo == -1 ? 0 : defaultPageNo;
}

#pragma mark 判断是否要隐藏MJFooter
- (void)judgeHideMjFooterView{
    if(!self.zx_autoHideMJFooterInGroup){
        return;
    }
    if(self.zx_pageNo == [self getFinalPageNo]){
        self.mj_footer.alpha = 0;
    }else{
        self.mj_footer.alpha = 1;
    }
}

#pragma mark 获取当前的控制器
- (id)zx_pagingGetCurrentVc{
    for (UIView *next = self.superview; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return nextResponder;
        }
    }
    return nil;
}

- (void)zx_performSelWithTarget:(id)target sel:(SEL)sel{
    if([target respondsToSelector:sel]){
        [target performSelector:sel withObject:nil afterDelay:0];
    }
}

#pragma mark - getter&setter
- (void)setZx_pageNo:(NSUInteger)zx_pageNo{
    objc_setAssociatedObject(self, &zx_pageNoKey, [NSNumber numberWithUnsignedInteger:zx_pageNo], OBJC_ASSOCIATION_ASSIGN);
}
- (NSUInteger)zx_pageNo{
    id pageNoValue = objc_getAssociatedObject(self, &zx_pageNoKey);
    NSUInteger pageNo = [pageNoValue unsignedIntegerValue];
    return !pageNoValue ? (defaultPageNo != -1 ? defaultPageNo : 0) : pageNo;
}

- (void)setZx_defaultPageNo:(NSUInteger)zx_defaultPageNo{
    defaultPageNo = (int)zx_defaultPageNo;
}

- (NSUInteger)zx_defaultPageNo{
    return defaultPageNo;
}

- (void)setZx_pageCount:(NSUInteger)zx_pageCount{
    objc_setAssociatedObject(self, &zx_pageCountKey, [NSNumber numberWithUnsignedInteger:zx_pageCount], OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)zx_pageCount{
    id pageCountValue = objc_getAssociatedObject(self, &zx_pageCountKey);
    NSUInteger pageCount = [pageCountValue unsignedIntegerValue];
    return !pageCountValue ? (defaultPageCount != -1 ? defaultPageCount : 10) : pageCount;
}

- (void)setZx_defaultPageCount:(NSUInteger)zx_defaultPageCount{
    defaultPageCount = (int)zx_defaultPageCount;
}

- (NSUInteger)zx_defaultPageCount{
    return defaultPageCount;
}

- (void)setZx_noMoreStr:(NSString *)zx_noMoreStr{
    if(zx_noMoreStr.length && self.mj_footer){
        MJRefreshBackStateFooter *footer = (MJRefreshBackStateFooter *)self.mj_footer;
        if([footer respondsToSelector:@selector(setTitle:forState:)]){
            [footer setTitle:zx_noMoreStr forState:MJRefreshStateNoMoreData];
        }
    }
    objc_setAssociatedObject(self, &zx_noMoreStrKey, zx_noMoreStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)zx_noMoreStr{
    return objc_getAssociatedObject(self, &zx_noMoreStrKey);
}

- (void)setZx_defaultNoMoreStr:(NSString *)zx_defaultNoMoreStr{
    defaultNoMoreStr = zx_defaultNoMoreStr;
}

- (NSString *)zx_defaultNoMoreStr{
    return defaultNoMoreStr;
}

- (void)setZx_lastPageNo:(NSUInteger)zx_lastPageNo{
    objc_setAssociatedObject(self, &zx_lastPageNoKey, [NSNumber numberWithUnsignedInteger:zx_lastPageNo], OBJC_ASSOCIATION_ASSIGN);
}
- (NSUInteger)zx_lastPageNo{
    id pageNoValue = objc_getAssociatedObject(self, &zx_lastPageNoKey);
    NSUInteger pageNo = [pageNoValue unsignedIntegerValue];
    return !pageNoValue ? (defaultPageNo != -1 ? defaultPageNo : 0) : pageNo;
}

- (void)setZx_disbaleAutoCallWhenAddingPaging:(BOOL)disbaleAutoCallWhenAddingPaging{
    objc_setAssociatedObject(self, &zx_disbaleAutoCallWhenAddingPagingKey, [NSNumber numberWithBool:disbaleAutoCallWhenAddingPaging], OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)zx_disbaleAutoCallWhenAddingPaging{
    id disbaleAutoCallWhenAddingPaging = objc_getAssociatedObject(self, &zx_disbaleAutoCallWhenAddingPagingKey);
    return disbaleAutoCallWhenAddingPaging;
}


- (void)setZx_pageDatas:(NSMutableArray *)zx_pageDatas{
    objc_setAssociatedObject(self, &zx_pageDatasKey, zx_pageDatas, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)zx_pageDatas{
    return objc_getAssociatedObject(self, &zx_pageDatasKey);
}

- (void)setZx_lastPageDatas:(NSMutableArray *)zx_lastPageDatas{
    objc_setAssociatedObject(self, &zx_lastPageDatasKey, zx_lastPageDatas, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)zx_lastPageDatas{
    return objc_getAssociatedObject(self, &zx_lastPageDatasKey);
}

- (void)setZx_lastAddedPageDatas:(NSMutableArray *)zx_lastAddedPageDatas{
    objc_setAssociatedObject(self, &zx_lastAddedPageDatasKey, zx_lastAddedPageDatas, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)zx_lastAddedPageDatas{
    return objc_getAssociatedObject(self, &zx_lastAddedPageDatasKey);
}

- (void)setZx_isMJHeaderRef:(BOOL)zx_isMJHeaderRef{
    objc_setAssociatedObject(self, &zx_isMJHeaderRefKey, [NSNumber numberWithBool:zx_isMJHeaderRef], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)zx_isMJHeaderRef{
    return [objc_getAssociatedObject(self, &zx_isMJHeaderRefKey) boolValue];
}

- (void)setZx_pageNoNumber:(NSNumber * _Nonnull)zx_pageNoNumber{
    
}

- (NSNumber *)zx_pageNoNumber{
    return [NSNumber numberWithUnsignedInteger:self.zx_pageNo];
}

- (void)setZx_pageCountNumber:(NSNumber * _Nonnull)zx_pageCountNumber{
    
}

- (NSNumber *)zx_pageCountNumber{
    return [NSNumber numberWithUnsignedInteger:self.zx_pageCount];
}

- (void)setZx_mjHeaderRefreshingBlock:(void (^)(void))zx_mjHeaderRefreshingBlock{
    objc_setAssociatedObject(self, &zx_mjHeaderRefreshingBlockKey, zx_mjHeaderRefreshingBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))zx_mjHeaderRefreshingBlock{
    return objc_getAssociatedObject(self, &zx_mjHeaderRefreshingBlockKey);
}

- (void)setZx_mjFooterRefreshingBlock:(void (^)(void))zx_mjFooterRefreshingBlock{
    objc_setAssociatedObject(self, &zx_mjFooterRefreshingBlockKey, zx_mjFooterRefreshingBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))zx_mjFooterRefreshingBlock{
    return objc_getAssociatedObject(self, &zx_mjFooterRefreshingBlockKey);
}

- (void)setZx_didUpdateScrollViewStatusBlock:(void (^)(ZXDidUpdateScrollViewStatus))zx_didUpdateScrollViewStatusBlock{
    objc_setAssociatedObject(self, &zx_didUpdateScrollViewStatusBlockKey, zx_didUpdateScrollViewStatusBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(ZXDidUpdateScrollViewStatus))zx_didUpdateScrollViewStatusBlock{
    return objc_getAssociatedObject(self, &zx_didUpdateScrollViewStatusBlockKey);
}

- (void)setZx_autoHideMJFooterInGroup:(BOOL)zx_autoHideMJFooterInGroup{
    objc_setAssociatedObject(self, &zx_autoHideMJFooterInGroupKey, [NSNumber numberWithBool:zx_autoHideMJFooterInGroup], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)zx_autoHideMJFooterInGroup{
    return [objc_getAssociatedObject(self, &zx_autoHideMJFooterInGroupKey) boolValue];
}
@end
