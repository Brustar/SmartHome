//
//  UIImagePickerController+LandScapeImagePicker.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "UIImagePickerController+LandScapeImagePicker.h"

@implementation UIImagePickerController (LandScapeImagePicker)
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
@end
