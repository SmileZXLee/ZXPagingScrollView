//
//  HttpRequest.h
//  ZXPagingScrollViewDemo
//
//  Created by 李兆祥 on 2019/10/24.
//  Copyright © 2019 ZXLee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^reqResultBlock) (BOOL result,id backData);
@interface HttpRequest : NSObject
+(void)reqLocalDtatWithParam:(NSDictionary *)param resultBlock:(reqResultBlock)resultBlock;
@end

NS_ASSUME_NONNULL_END
