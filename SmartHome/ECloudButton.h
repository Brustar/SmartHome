//
//  ECloudButton.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECloudButton : UIButton

/** 控制器类型 */
@property (nonatomic, assign) NSInteger type;

/** 控制器内的数据类型 */
@property (nonatomic, assign) NSInteger subType;


- (instancetype)initWithTitle:(NSString *)title normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage;

@end
