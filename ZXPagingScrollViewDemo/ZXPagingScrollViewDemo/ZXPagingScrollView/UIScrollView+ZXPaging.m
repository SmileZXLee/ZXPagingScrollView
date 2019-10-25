//
//  UIScrollView+ZXPaging.m
//  ZXPagingScrollView
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//  https://github.com/SmileZXLee/ZXPagingScrollView

#import "UIScrollView+ZXPaging.h"
#import <objc/runtime.h>
static int defaultPageNo = -1;
static int defaultPageCount = -1;
static NSString *zx_pageNoKey = @"zx_pageNoKey";
static NSString *zx_pageCountKey = @"zx_pageCountKey";
static NSString *zx_noMoreStrKey = @"zx_noMoreStrKey";
static NSString *zx_pageDatasKey = @"zx_pageDatasKey";
static NSString *zx_lastPageDatasKey = @"zx_lastPageDatasKey";
static NSString *zx_mjFooterStyleKey = @"zx_mjFooterStyleKey";
static NSString *zx_isMJHeaderRefKey = @"zx_isMJHeaderRefKey";
static NSString *zx_mjHeaderRefreshingBlockKey = @"zx_mjHeaderRefreshingBlockKey";
static NSString *zx_mjFooterRefreshingBlockKey = @"zx_mjFooterRefreshingBlockKey";
static NSString *zx_didUpdateScrollViewStatusBlockKey = @"zx_didUpdateScrollViewStatusBlockKey";
static NSString *zx_autoHideMJFooterInGroupKey = @"zx_autoHideMJFooterInGroupKey";
@implementation UIScrollView (ZXPaging)
#pragma mark - Public
#pragma mark 添加默认的ZXPaging
- (void)zx_addDefaultPagingWithReqTarget:(id)target sel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas{
    self.zx_pageDatas = pagingDatas;
    [self zx_performSelWithTarget:target sel:sel];
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

#pragma mark 添加默认的ZXPaging
- (void)zx_addDefaultPagingWithSel:(SEL)sel pagingDatas:(NSMutableArray *)pagingDatas{
    self.zx_pageDatas = pagingDatas;
    [self zx_addDefaultPagingWithReqTarget:[self zx_pagingGetCurrentVc] sel:sel pagingDatas:pagingDatas];
}

#pragma mark 添加自定义的ZXPaging
- (void)zx_addCustomPagingWithReqTarget:(id)target sel:(SEL)sel isCustomHeader:(BOOL)isCustomHeader isCustomFooter:(BOOL)isCustomFooter pagingDatas:(NSMutableArray *)pagingDatas{
    [self zx_performSelWithTarget:target sel:sel];
    self.zx_pageDatas = pagingDatas;
    __weak typeof(target)weakTarget = target;
    __weak typeof(self)weakSelf = self;
    if(isCustomHeader){
        if(self.mj_header){
            self.mj_header.refreshingBlock = ^{
                [weakSelf zx_handleMjHeaderRefresh];
                if([weakTarget respondsToSelector:sel]){
                    [weakTarget performSelector:sel withObject:nil afterDelay:0];
                }
            };
        }else{
            NSAssert(self.mj_header, @"请先初始化MJHeader");
        }
    }else{
        [self addDefaultMJHeader:^{
            if([weakTarget respondsToSelector:sel]){
                [weakTarget performSelector:sel withObject:nil afterDelay:0];
            }
        }];
    }
    
    if(isCustomFooter){
        if(self.mj_footer){
            self.mj_footer.refreshingBlock = ^{
                [weakSelf zx_handleMjHeaderRefresh];
                if([weakTarget respondsToSelector:sel]){
                    [weakTarget performSelector:sel withObject:nil afterDelay:0];
                }
            };
        }else{
            NSAssert(self.mj_footer, @"请先初始化MJFooter");
        }
    }else{
        [self addDefaultMJFooter:^{
            if([weakTarget respondsToSelector:sel]){
                [weakTarget performSelector:sel withObject:nil afterDelay:0];
            }
        }];
    }
    
    self.mj_footer.hidden = YES;
}

#pragma mark 添加自定义的ZXPaging
- (void)zx_addCustomPagingWithSel:(SEL)sel isCustomHeader:(BOOL)isCustomHeader isCustomFooter:(BOOL)isCustomFooter pagingDatas:(NSMutableArray *)pagingDatas{
    self.zx_pageDatas = pagingDatas;
    [self zx_addCustomPagingWithReqTarget:[self zx_pagingGetCurrentVc] sel:sel isCustomHeader:isCustomHeader isCustomFooter:isCustomFooter pagingDatas:pagingDatas];
}

#pragma mark 结束MJHeaderView和MJFooter的刷新状态，且自动reloadData
- (void)zx_endMJRef{
    if([self respondsToSelector:@selector(reloadData)]){
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
    }
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

#pragma mark 请求完成调用此方法
- (void)zx_requestResult:(BOOL)success resultArray:(NSArray *)resultArray{
    if(self.zx_pageNo == [self getFinalPageNo]){
        [self.zx_pageDatas removeAllObjects];
    }
    if(!self.zx_pageDatas){
        self.zx_pageDatas = [NSMutableArray array];
    }
    if(success){
        [self.zx_pageDatas addObjectsFromArray:resultArray];
    }
    [self updateScrollViewStatus:success];
    [self zx_endMJRef];
}

#pragma mark - Private
#pragma mark 设置MJFooter
- (void)setMJFooterStyle:(ZXMJFooterStyle)style noMoreStr:(NSString *)noMoreStr{
    self.zx_mjFooterStyle = style;
    self.zx_noMoreStr = noMoreStr;
}

#pragma mark 添加默认的MJHeader
- (void)addDefaultMJHeader:(zx_mjHeaderBlock)block{
    __weak typeof(self)weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf zx_handleMjHeaderRefresh];
        block();
    }];
    self.mj_header = header;
}

#pragma mark 添加默认的MJFooter
- (void)addDefaultMJFooter:(zx_mjFooterBlock)block{
    [self addDefaultMJFooterStyle:self.zx_mjFooterStyle noMoreStr:self.zx_noMoreStr block:block];
}

#pragma mark 添加默认的MJFooter
- (void)addDefaultMJFooterStyle:(ZXMJFooterStyle)style noMoreStr:(NSString *)noMoreStr block:(zx_mjFooterBlock)block{
    __weak typeof(self)weakSelf = self;
    if(style == ZXMJFooterStylePlain){
        self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [weakSelf zx_handleMjFooterRefresh];
            block();
        }];
        MJRefreshBackNormalFooter *foot = (MJRefreshBackNormalFooter *)self.mj_footer;
        [foot setTitle:noMoreStr forState:MJRefreshStateNoMoreData];
    }else{
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf zx_handleMjFooterRefresh];
            block();
        }];
        if(self.zx_noMoreStr.length){
            MJRefreshAutoNormalFooter *foot = (MJRefreshAutoNormalFooter *)self.mj_footer;
            if([foot respondsToSelector:@selector(setTitle: forState:)]){
                [foot setTitle:noMoreStr forState:MJRefreshStateNoMoreData];
            }
        }
    }
}

#pragma mark MJHeader刷新后的处理
- (void)zx_handleMjHeaderRefresh{
    [self setValue:@1 forKey:@"zx_isMJHeaderRef"];
    if(self.zx_pageDatas.count % self.zx_pageCount){
        self.mj_footer.state = MJRefreshStateNoMoreData;
    }
    [self.zx_pageDatas removeAllObjects];
    self.zx_pageNo = [self getFinalPageNo];
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
    ZXDidUpdateScrollViewStatus didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusHasMoreData;
    if(status){
        if(!self.zx_pageDatas.count){
            self.mj_footer.hidden = YES;
            didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusNoMoreData;
        }else{
            self.mj_footer.hidden = NO;
            if(self.zx_pageDatas.count % self.zx_pageCount || (self.zx_lastPageDatas && self.zx_lastPageDatas.count == self.zx_pageDatas.count  && self.zx_lastPageDatas.count != self.zx_pageCount)){
                [self judgeHideMjFooterView];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(self.zx_mjFooterStyle == ZXMJFooterStyleGroup){
                        self.mj_footer.state = MJRefreshStateNoMoreData;
                    }
                });
                didUpdateScrollViewStatus = ZXDidUpdateScrollViewStatusNoMoreData;
            }else{
                [self judgeHideMjFooterView];
            }
        }
        if(!self.zx_isMJHeaderRef){
            [self setValue:[self.zx_pageDatas mutableCopy] forKey:@"zx_lastPageDatas"];
        }
    }else{
        if(!self.zx_pageDatas.count){
            self.mj_footer.hidden = YES;
        }
        if(self.zx_pageNo > [self getFinalPageNo]){
            self.zx_pageNo--;
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

- (void)setZx_pageCount:(NSUInteger)zx_pageCount{
    objc_setAssociatedObject(self, &zx_pageCountKey, [NSNumber numberWithUnsignedInteger:zx_pageCount], OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)zx_pageCount{
    id pageCountValue = objc_getAssociatedObject(self, &zx_pageCountKey);
    NSUInteger pageCount = [pageCountValue unsignedIntegerValue];
    return !pageCountValue ? (defaultPageCount != -1 ? defaultPageCount : 10) : pageCount;
}

- (void)setZx_noMoreStr:(NSString *)zx_noMoreStr{
    objc_setAssociatedObject(self, &zx_noMoreStrKey, zx_noMoreStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)zx_noMoreStr{
    return objc_getAssociatedObject(self, &zx_noMoreStrKey);
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

- (void)setZx_mjFooterStyle:(ZXMJFooterStyle)zx_mjFooterStyle{
    objc_setAssociatedObject(self, &zx_mjFooterStyleKey, [NSNumber numberWithInt:zx_mjFooterStyle], OBJC_ASSOCIATION_ASSIGN);
}

- (ZXMJFooterStyle)zx_mjFooterStyle{
    return [objc_getAssociatedObject(self, &zx_mjFooterStyleKey) intValue];
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
