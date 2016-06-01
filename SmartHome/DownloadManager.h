//
//  DownloadManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyExtensions)
- (NSString *) md5;
@end

@interface DownloadManager : NSObject

+ (id)defaultManager;
-(void)download:(NSURL *)url;
-(void)download:(NSURL *)url completion:(void (^)())completion;

@end
