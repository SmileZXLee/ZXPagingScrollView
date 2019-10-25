//
//  HttpRequest.m
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import "HttpRequest.h"

@implementation HttpRequest
#pragma mark 模拟从服务器获取数据(分页请求测试)
+(void)reqLocalDtatWithParam:(NSDictionary *)param resultBlock:(reqResultBlock)resultBlock{
    NSUInteger dataCounts = 34;
    NSUInteger pageNo = [param[@"pageNo"] intValue];
    NSUInteger pageCount = [param[@"pageCount"] intValue];
    id backDatas = [NSMutableArray array];
    NSMutableArray *localDatasArr = [NSMutableArray array];
    for(NSUInteger i = 0;i < dataCounts;i++){
        NSDictionary *dic = @{@"title":@"Test",@"msg":[NSString stringWithFormat:@"测试数据-%lu",i]};
        [localDatasArr addObject:dic];
    }
    NSUInteger from = pageNo * pageCount;
    from = from >= localDatasArr.count ? localDatasArr.count - 1 : from;
    NSUInteger to = from + pageCount;
    to = to >= localDatasArr.count ? localDatasArr.count - 1 : to;
    for(NSUInteger i = from;i < to;i++){
        [backDatas addObject:localDatasArr[i]];
    }
    //加一些随机的假的错误情况
    BOOL success = arc4random_uniform(2);
    NSArray *errCodeArr = @[@-1009,@-1000,@-1001,@-1002];
    if(!success){
        //backDatas = [NSDictionary dictionaryWithObjects:@[errCodeArr[(int32_t)arc4random_uniform((int32_t)errCodeArr.count)],@"错误测试"] forKeys:@[@"code",@"message"]];
    }
    //取消网络加载失败的情况
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        resultBlock(YES,backDatas);
    });
    
}
@end
