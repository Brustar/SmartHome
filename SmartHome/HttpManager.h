//
//  HttpManager.h
//  SmartHome
//
//  Created by Brustar on 16/7/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpDelegate <NSObject>

@optional

-(void) httpHandler:(id) responseObject tag:(int) tag;
-(void) httpHandler:(id) responseObject;

@end

@interface HttpManager : NSObject

@property (strong, nonatomic) id delegate;
@property (nonatomic) int tag;
@property(nonatomic,assign)BOOL isPhotoLibrary;
+ (id)defaultManager;
- (void) sendPost:(NSString *)url param:(NSDictionary *)params;
- (void) sendGet:(NSString *)url param:(NSDictionary *)params;

@end
