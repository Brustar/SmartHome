//
//  UploadFile.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadManager : NSObject

+ (id)defaultManager;
- (void)uploadImage:(UIImage *) img url:(NSURL*) url completion:(void (^)())completion;
- (void)uploadScene:(NSString *)sceneFile url:(NSURL*) url completion:(void (^)())completion;

@end
