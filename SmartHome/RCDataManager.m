



//
//  RCDataManager.m
//  RCIM
//
//  Created by 郑文明 on 15/12/30.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "RCDataManager.h"
#import "AppDelegate.h"
#import "SQLManager.h"

@implementation RCDataManager{
        NSMutableArray *dataSoure;
}

- (instancetype)init{
    if (self = [super init]) {
        [RCIM sharedRCIM].userInfoDataSource = self;
    }
    return self;
}

+ (RCDataManager *)shareManager{
    static RCDataManager* manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

#pragma mark
#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    completion([self queryUserInfo:userId]);
}

-(RCUserInfo *) queryUserInfo:(NSString *)userID
{
    RCUserInfo *info = nil;
    NSArray *s = [SQLManager queryChat:userID];
    info = [[RCUserInfo alloc] initWithUserId:userID name:[s objectAtIndex:0] portrait:[s objectAtIndex:1]];
    return info;
}

@end

