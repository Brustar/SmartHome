//
//  UploadFile.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//
@interface UploadManager : NSObject

+ (id)defaultManager;
- (void)uploadImage:(UIImage *) img url:(NSString *) url completion:(void (^)(id responseObject))completion;
- (void)uploadScene:(NSData *)sceneData url:(NSString *) url completion:(void (^)(id responseObject))completion;

@end
