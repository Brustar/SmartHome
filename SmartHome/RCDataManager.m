



//
//  RCDataManager.m
//  RCIM
//
//  Created by 郑文明 on 15/12/30.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "RCDataManager.h"
#import "AppDelegate.h"

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
    NSLog(@"getUserInfoWithUserId ----- %@", userId);
    
    if ([userId isEqualToString:@"Brustar"]) {
        completion(self.Brustar);
    }else if([userId isEqualToString:@"Ecloud"]){
        completion(self.Ecloud);
    }else{
        completion(self.Kobe);
    }
   
}

-(RCUserInfo *) Brustar
{
    if(!_Brustar)
    {
        _Brustar = [[RCUserInfo alloc] initWithUserId:@"Brustar" name:@"Bruce" portrait:@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2383941727,1702940827&fm=23&gp=0.jpg"];
    }
    
    return _Brustar;
}

-(RCUserInfo *) Ecloud
{
    if(!_Ecloud)
    {
        _Ecloud = [[RCUserInfo alloc] initWithUserId:@"Ecloud" name:@"Company" portrait:@"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3327061392,1889812535&fm=23&gp=0.jpg"];
    }
    
    return _Ecloud;
}

-(RCUserInfo *) Kobe
{
    if(!_Kobe)
    {
        _Kobe = [[RCUserInfo alloc] initWithUserId:@"Kobe" name:@"LY" portrait:@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3729890206,3980454064&fm=23&gp=0.jpg"];
    }
    
    return _Kobe;
}

@end

