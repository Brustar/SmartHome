//
//  DialogManager.h
//  SmartHome
//
//  Created by Brustar on 16/6/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//

//#import <UIKit/UIKit.h>

#define SCREEN_WIDTH 1024
#define SCREEN_HEIGHT 768

@interface DialogManager : NSObject

+ (void)showMessage:(NSString *)message;

+ (void)showWeb:(NSString *)url;

@end
