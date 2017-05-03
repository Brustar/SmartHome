//
//  UIImageView+Badge.h
//  SmartHome
//
//  Created by Brustar on 2017/4/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Badge)

float degrees2Radians(float degrees);
-(void)badge;
-(void) rotate:(int)degree;
@end
