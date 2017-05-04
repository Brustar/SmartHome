//
//  UIImageView+Badge.h
//  SmartHome
//
//  Created by Brustar on 2017/4/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Badge)


CGAffineTransform GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle);
float degrees2Radians(float degrees);
-(void)badge;
-(void) rotate:(int)degree;
-(void) sliderRotate:(int)degree;
@end
