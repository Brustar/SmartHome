//
//  UIImage+UiimageToString.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "UIImage+UiimageToString.h"

@implementation UIImage (UiimageToString)
+(NSString *)ImageToBase64Str:(UIImage *) image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
   
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodedImageStr;
}
@end
