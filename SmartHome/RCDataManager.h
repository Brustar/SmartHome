//
//  RCDataManager.h
//  RCIM
//
//  Created by 郑文明 on 15/12/30.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
/**
 *  RCDataManager类为核心管理融云一切逻辑的类，包括充当用户信息提供者的代理，同步好友列表，同步群组列表，登录融云服务器，刷新角标badgeValue等等
 *  RCDataManager类为自己写的类，和融云SDK无关（不要以为是SDK内部的类）
 */
@interface RCDataManager : NSObject<RCIMUserInfoDataSource>

@property(nonatomic,strong) RCUserInfo *Brustar;
@property(nonatomic,strong) RCUserInfo *Ecloud;
@property(nonatomic,strong) RCUserInfo *Kobe;

/**
 *  RCDataManager单例对象
 *
 *  @return RCDataManager单例
 */
+(RCDataManager *) shareManager;
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion;
@end
