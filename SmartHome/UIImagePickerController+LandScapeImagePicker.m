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
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
